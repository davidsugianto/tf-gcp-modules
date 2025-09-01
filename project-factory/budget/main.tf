# Budget Sub-module
# This module handles billing budgets and cost management

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Create billing budgets for projects
resource "google_billing_budget" "project_budgets" {
  for_each = {
    for name, project in var.projects : name => project
    if lookup(project, "budget", null) != null
  }

  billing_account = var.billing_account
  display_name   = "${var.names_prefix}${each.key}-budget${var.names_suffix}"

  # Budget amount configuration
  amount {
    dynamic "specified_amount" {
      for_each = each.value.budget.amount.specified_amount != null ? [each.value.budget.amount.specified_amount] : []
      content {
        currency_code = var.currency_code
        units         = specified_amount.value.units
        nanos         = specified_amount.value.nanos
      }
    }

    dynamic "last_period_amount" {
      for_each = lookup(each.value.budget.amount, "last_period_amount", false) ? [1] : []
      content {}
    }
  }

  # Budget filters
  budget_filter {
    projects = ["projects/${each.value.project_id}"]

    # Resource labels filter (optional)
    dynamic "labels" {
      for_each = lookup(each.value, "budget_labels_filter", {})
      content {
        key    = labels.key
        values = labels.value
      }
    }

    # Services filter (optional)
    services = lookup(each.value, "budget_services_filter", null)

    # Calendar period or custom period
    calendar_period = lookup(each.value, "budget_calendar_period", "MONTH")
    
    dynamic "custom_period" {
      for_each = lookup(each.value, "budget_custom_period", null) != null ? [each.value.budget_custom_period] : []
      content {
        start_date {
          year  = custom_period.value.start_date.year
          month = custom_period.value.start_date.month
          day   = custom_period.value.start_date.day
        }
        end_date {
          year  = custom_period.value.end_date.year
          month = custom_period.value.end_date.month
          day   = custom_period.value.end_date.day
        }
      }
    }
  }

  # Threshold rules
  dynamic "threshold_rules" {
    for_each = lookup(each.value.budget, "threshold_rules", var.default_budget_alert_thresholds)
    content {
      threshold_percent   = threshold_rules.value.threshold_percent
      spend_basis        = lookup(threshold_rules.value, "spend_basis", "CURRENT_SPEND")
      
      dynamic "forecast_options" {
        for_each = lookup(threshold_rules.value, "forecast_options", null) != null ? [threshold_rules.value.forecast_options] : []
        content {
          forecast_period {
            start_date {
              year  = forecast_options.value.forecast_period.start_date.year
              month = forecast_options.value.forecast_period.start_date.month
              day   = forecast_options.value.forecast_period.start_date.day
            }
            end_date {
              year  = forecast_options.value.forecast_period.end_date.year
              month = forecast_options.value.forecast_period.end_date.month
              day   = forecast_options.value.forecast_period.end_date.day
            }
          }
        }
      }
    }
  }

  # Budget alert rules
  dynamic "all_updates_rule" {
    for_each = lookup(each.value.budget, "all_updates_rule", null) != null ? [each.value.budget.all_updates_rule] : []
    content {
      monitoring_notification_channels   = all_updates_rule.value.monitoring_notification_channels
      pubsub_topic                      = all_updates_rule.value.pubsub_topic
      schema_version                    = all_updates_rule.value.schema_version
      disable_default_iam_recipients    = all_updates_rule.value.disable_default_iam_recipients
    }
  }
}

# Create notification channels for budget alerts (optional)
resource "google_monitoring_notification_channel" "budget_notification_channels" {
  for_each = var.budget_notification_channels

  project      = each.value.project_id
  display_name = "${var.names_prefix}${each.key}${var.names_suffix}"
  type         = each.value.type
  description  = each.value.description

  labels = each.value.labels

  user_labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "project-factory-budget"
  })
}

# Create Pub/Sub topics for budget notifications (optional)
resource "google_pubsub_topic" "budget_topics" {
  for_each = var.budget_pubsub_topics

  project = each.value.project_id
  name    = "${var.names_prefix}${each.key}${var.names_suffix}"

  labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "project-factory-budget"
    purpose    = "budget-notifications"
  })

  message_retention_duration = lookup(each.value, "message_retention_duration", "86400s")
}

# Create Pub/Sub subscriptions for budget topics (optional)
resource "google_pubsub_subscription" "budget_subscriptions" {
  for_each = var.budget_pubsub_subscriptions

  project = each.value.project_id
  name    = "${var.names_prefix}${each.key}${var.names_suffix}"
  topic   = google_pubsub_topic.budget_topics[each.value.topic_key].name

  # Delivery configuration
  message_retention_duration = lookup(each.value, "message_retention_duration", "86400s")
  ack_deadline_seconds      = lookup(each.value, "ack_deadline_seconds", 20)
  
  # Push configuration (optional)
  dynamic "push_config" {
    for_each = lookup(each.value, "push_config", null) != null ? [each.value.push_config] : []
    content {
      push_endpoint = push_config.value.push_endpoint
      
      dynamic "attributes" {
        for_each = lookup(push_config.value, "attributes", {})
        content {
          key   = attributes.key
          value = attributes.value
        }
      }
    }
  }

  labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "project-factory-budget"
  })

  depends_on = [google_pubsub_topic.budget_topics]
}

# Create Cloud Functions for budget processing (optional)
resource "google_cloudfunctions_function" "budget_processors" {
  for_each = var.budget_cloud_functions

  project = each.value.project_id
  name    = "${var.names_prefix}${each.key}${var.names_suffix}"
  region  = each.value.region

  runtime     = each.value.runtime
  entry_point = each.value.entry_point
  
  # Source code
  source_archive_bucket = each.value.source_bucket
  source_archive_object = each.value.source_object

  # Event trigger for Pub/Sub
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.budget_topics[each.value.pubsub_topic_key].name
    
    failure_policy {
      retry = lookup(each.value, "retry_on_failure", true)
    }
  }

  # Environment variables
  environment_variables = merge(
    lookup(each.value, "environment_variables", {}),
    {
      PROJECT_ID = each.value.project_id
    }
  )

  labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "project-factory-budget"
  })

  depends_on = [google_pubsub_topic.budget_topics]
}
