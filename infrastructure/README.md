# Infrastructure

Terraform for the tallyo AWS resources (account `555411961606`, region `sa-east-1`).

| File | Resources |
|---|---|
| `main.tf` | App assets bucket, SQS FIFO queues, IAM users and policies for `tallyo-api` and `whatsapp` |
| `landing_page.tf` | Landing page at `tallyo.platformoon.com`: S3 website bucket, ACM certificate (us-east-1), CloudFront, Route53 records, GitHub Actions deployer user |
| `outputs.tf` | Queue URLs, bucket names, CloudFront distribution ID |

## Usage

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

All variables have defaults in `variables.tf`, so no `.tfvars` file is needed.

## State

State lives in the `tallyo-platformoon-tfstate` S3 bucket (versioned, encrypted, public access blocked) with S3 native locking. The bucket is created outside Terraform because it must exist before `terraform init`.

## Credentials

Access keys for the IAM users are not managed by Terraform, so they never end up in the state. Create them with `aws iam create-access-key --user-name <user>` and store them where they are used:

- `tallyo-landing-page-gh-actions` → GitHub secrets `LANDING_PAGE_AWS_ACCESS_KEY` / `LANDING_PAGE_AWS_SECRET_KEY`
- `tallyo-api-app` / `tallyo-whatsapp-app` → the services' AWS credentials, with the queue URLs from `terraform output`
