
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


clean:
		yarn run hexo clean

dev:
		cp _config.staging.yml _config.yml
		yarn run hexo server

dev-prod:
		cp _config.prod.yml _config.yml
		yarn run hexo server

gen:
		cp _config.staging.yml _config.yml
		yarn run hexo generate

gen-prod:
		cp _config.prod.yml _config.yml
		yarn run hexo generage

