## Deploying Mage to GCP

In this section, we will deploy Mage to GCP using Terraform. To do so, we use the templates provided in [mage-ai-terraform-templates](https://github.com/mage-ai/mage-ai-terraform-templates).   

In order to deploy Mage to GCP using Terraform, the prerequisites are:

- Terraform
- `gcloud cli`
    - [Installation instructions](https://cloud.google.com/sdk/docs/install)
    - To check the installation, run `gcloud auth list`  and ensure that our email address is shown.
    - In case of any errors, login using the command `gcloud auth login` .
- Google Cloud permissions
    - In the *IAM and admin* section, we edit the permissions of our service account by adding the following roles:
        - Artifact Registry Reader
        - Artifact Registry Writer
        - Cloud Run Developer
        - Cloud SQL Admin
        - Service Account Token Creator
    - Enable *Cloud Firestore API*
- Mage Terraform templates
    - [mage-ai-terraform-templates](https://github.com/mage-ai/mage-ai-terraform-templates)
    - This directory is a clone of the above repository with modifications made to `README.md` and `variables.tf` in the `gcp` directory.

Once all the prerequisites are fulfilled, we navigate to the `gcp` directory in the Terraform templates repository or directory and update the default value of the following variables in `variables.tf` :

- `project_id`
- `region`
- `zone`

Next, we create the resources using the following commands:

```bash
terraform init
terraform plan
terraform apply
```

While creating the resources, we need to provide a password for our Postgres database. In total, 21 resources are added. Creation of the SQL instance `mage-data-prep-db-instance`  can take a long time, up to 10 minutes.
