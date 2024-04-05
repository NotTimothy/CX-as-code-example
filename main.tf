provider "genesyscloud" {
  oauthclient_id = "ec17cd8a-8e7a-42eb-a418-646e21d0ef7f"
  oauthclient_secret = "GghqamoGM5lhSaUC53mTVFj03uFhTt7l3NgP6PEz5BU"
  aws_region = "us-west-2"
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud",
      version = ">= 1.6.0"
    }
  }
}

// The names listed here have to be created inside of Genesys Cloud
data "genesyscloud_architect_schedules" "open" {
  name = "Open Schedule"
}

data "genesyscloud_architect_schedules" "closed" {
  name = "Closed Schedule"
}

data "genesyscloud_architect_schedules" "holiday" {
  name = "Holiday Schedule"
}

// This creates the resources for Schedule Groups, Schedules, and a Flow.
resource "genesyscloud_architect_schedulegroups" "open_messaging_schedulegroups" {
  name                 = "CX as Code Schedule Group"
  description          = "Sample Schedule Group by CX as Code using Terraform"
  time_zone            = "America/Indianapolis"
  open_schedules_id    = [data.genesyscloud_architect_schedules.open.id]
  closed_schedules_id  = [data.genesyscloud_architect_schedules.closed.id]
  holiday_schedules_id = [data.genesyscloud_architect_schedules.holiday.id]
}   

resource "genesyscloud_architect_schedules" "open_messaging_schedule" {
  name        = "CX as Code Schedule"
  description = "Sample Schedule by CX as Code using TerraForm"
  start       = "2024-04-04T08:00:00.000000"
  end         = "2025-04-04T17:00:00.000000"
  rrule       = "FREQ=DAILY;INTERVAL=1"
}

resource "genesyscloud_flow" "open_messaging" {
  filepath          = "./flow.yaml"
  file_content_hash = filesha256("./flow.yaml")
}

resource "genesyscloud_architect_ivr" "simple_ivr" {
  name               = "A simple IVR built using Terraform"
  description        = "This is a simple IVR that was built using Terraform"
  dnis               = ["+13129718321", "+13129718321"]  # This needs to be changed
  // The flow you want to be used during these hours.
  open_hours_flow_id    = genesyscloud_flow.open_messaging.id
  closed_hours_flow_id  = data.genesyscloud_architect_schedules.closed.id
  holiday_hours_flow_id = data.genesyscloud_architect_schedules.holiday.id
  depends_on         = [
    genesyscloud_architect_schedulegroups.open_messaging_schedulegroups,
    genesyscloud_architect_schedules.open_messaging_schedule,
    genesyscloud_flow.open_messaging,
  ]
}