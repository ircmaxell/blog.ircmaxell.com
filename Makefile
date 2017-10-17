
staging-terraform-init:
		cd terraform/staging; terraform init

staging-terraform-plan:
		cd terraform/staging; terraform plan -out ./terraform.plan

staging-terraform-apply:
		cd terraform/staging; terraform apply ./terraform.plan

staging-terraform-state-pull:
		cd terraform/staging; terraform state pull > terraform.tfstate

staging-terraform-state-push:
		cd terraform/staging; terraform state push terraform.tfstate

prod-terraform-init:
		cd terraform/prod; terraform init

prod-terraform-plan:
		cd terraform/prod; terraform plan -out ./terraform.plan

prod-terraform-apply:
		cd terraform/prod; terraform apply ./terraform.plan

prod-terraform-state-pull:
		cd terraform/prod; terraform state pull > terraform.tfstate


dev:
	  hexo server

deploy-staging:
		cp _config.staging.yaml _config.yaml
		hexo deploy

deploy-prod:
		cp _config.prod.yaml _config.yaml
		hexo deploy