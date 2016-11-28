# Usage example of Packer and Terraform with GoogleCloud
## Requirements
1. [Google Cloud Account](https://cloud.google.com/)
2. Google Cloud API Credentials
3. [Packer](https://www.packer.io/) installed
4. [Terraform](https://www.terraform.io/) installed

## Download example
`git clone https://github.com/Extor/terraform-packer-googlecloud`

## Preparing Google Cloud
1. Create new project
2. Create and download [Google API Credentials](https://support.google.com/cloud/answer/6158862) as account.json to `terraform-packer-googlecloud` directory

## Packer and terraform config
1. Edit `packer/packer-gcloud.json`
2. Edit `terraform/gcloud.tf`

## Usage
1. `cd terraform-packer-googlecloud`
2. `packer build packer/packer-gcloud.json`
3. `terraform apply terraform`
