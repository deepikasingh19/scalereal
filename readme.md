1. Run build process to generate Lambda ZIP file locally to match lambda_zip_path variable path
2. Provide all needed variables from variables.tf file or copy paste and change example below
3. Create/Select Terraform workspace before deployment
4. Run terraform plan -var-file="<.tfvars file> to check for any errors and see what will be built
5. Run terraform apply -var-file="<.tfvars file> to deploy infrastructure
