## Configure GCP

In this section, we define Terraform scripts - `main.tf` and `variables.tf` - that are used to create a Google Cloud Storage bucket and a Google BigQuery dataset. In order to create these resources using Terraform, we need to create a service account that contains the necessary permissions. 

To create a service account:
- In the Google Cloud Console, we go to *IAM and admin* and then *Service accounts*.
- Next, we click on *Create Service Account*, give it a name, and grant it the following roles:
    - BigQuery Admin
    - Compute Admin
    - Storage Admin
    - Storage Object Admin
    - Viewer
    - *Note*: These are high privileges that are alright for learning during a course but should never be provided in a work environment.
- Once the account is created, we click on it in the table, navigate to the *Keys* tab and click on *Add Key*. We select *JSON* and download the generated JSON file.

The service account now contains the credentials and permissions to modify our storage bucket and BigQuery dataset. We copy the downloaded JSON file to our Mage project and add it to `.gitignore`. When a Mage container is created, this file gets automatically copied to the container in the `/home/src` directory as specified in `docker-compose.yml`.

To provide Mage with GCP access, we specify the path to the service account JSON inside the container in the `io_config.yaml` file (property `GOOGLE_SERVICE_ACC_KEY_FILEPATH`). We also delete the configuration above this property till `# Google`.