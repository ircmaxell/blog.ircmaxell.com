
staging-terraform-init:
		cd terraform/staging; terraform init

staging-terraform-plan:
		cd terraform/staging; terraform plan -out ./terraform.plan

staging-terraform-apply:
		cd terraform/staging; terraform apply ./terraform.plan

staging-terraform-state-pull:
		cd terraform/staging; terraform state pull > terraform.tfstate

dev:
	  hexo server

deploy-staging:
	  hexo deploy