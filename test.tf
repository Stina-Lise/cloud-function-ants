/* The two terraform providers used. Privcon for managing the privacy metadata 
and google for managing the infrastructure in GCP.
*/
terraform {
  required_providers {
    privcon = {
      source  = "ingka.ikea.com/tf/privcon"
    }
     google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

#Configuring the google provider by selecting the HR solution's GCP project.
provider "google" {
  project = "ingka-hr-dev"
}

/* This is the first block of metadata. It describes the characteristics of 
the HR system we are defining privacy metadata for. The metadata includes the 
system's SMC identifier and its organisation. 
*/
resource "privcon_system" "hr" {
  smcid = "SM-001337"
  description = "HR System"
  organisation = "ingka"
}

/* This is the Cloud Run instance running our HR system's microservice.
*/
resource "google_cloud_run_service" "hrservice" {
  name     = "hrservice"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hrservice"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

/* The following metadata block is called a compute container. It contains
information regarding how the HR microservice processes private information
in the Cloud Run instance.

The context field has been set to the Cloud Run instance's name. In this way 
we bind the metadata to the actual terraform resource they describe. Next, the
organisation and system fields have been set to ingka and SM-001337 respectively. 
This defines that this compute container is part of the SM-001337 system.

The processing definitions set is used to describe the different functionalities
of the microservice, as well as how private information is processed in them. Here, 
only one processing definition has been defined. It describes the first 
functionality of the HR microservice. The definition declares that the service 
collects the HR team's emails and passwords in order to provide the HR system's 
services. Finally, the data is generated within the system itself and it's 
stored in the HRteam table in the hrdb database (defined later in the file). The 
latter is defined in the source and destination fields respectively.
*/
resource "privcon_compute_container" hrservice {
    name = "hrservice"
    description = "The HR microservice."
    context = google_cloud_run_service.hrservice.name
    organisation = privcon_system.hr.organisation
    system = privcon_system.hr.smcid

    processing_definitions {
        data_categories = ["user.contact.email","user.credentials.password"]
         data_uses = ["essential.service"]
         data_subject = "employee"
         #where does the data come from
         sources = ["self"]
         #where does the data go
         destinations = [privcon_data_container.hrdb.datasets[0].name]
     }
}

/* The Cloud SQL instance used for storing the data of the HR microservice.
*/
resource "google_sql_database_instance" "hrdb" {
  name             = "hrdb"
  database_version = "POSTGRES_15"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}

/* The following metadata block is a data container. It describes how the HR 
microservice stores private information in the Cloud SQL instance. 

Again here, the context field has been set to the Cloud SQL instance's name. 
This binds the metadata to the actual terraform resource they describe. Next, the 
organisation and system fields have been set to ingka and SM-001337 respectively.
The retention period is set to 365 denoting that the data is held for 365 days. 

Finally, there is one dataset definition. Datasets are used to describe database
tables for relational databases and documents in non-relational databases. Here,
the HRteam dataset describes a SQL table with the two fields email and password.
*/
resource "privcon_data_container" hrdb {
    name = "hrdb"
    description = "The HR's service database."
    context = google_sql_database_instance.hrdb.name
    organisation = privcon_system.hr.organisation
    system = privcon_system.hr.smcid
    retention_period = 365

    datasets {
      name = "HRteam"
      description = "HR team credentials"
      fields {
        name = "email"
        description = "HR team member's email"
        data_categories = ["user.contact.email"]
      }
      fields {
        name = "password"
        description = "HR team member's passwords"
        data_categories = ["user.credentials.password"]
      }
    }

}
