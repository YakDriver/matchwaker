# Matchwaker
Dead simple Watchmaker Windows EC2 builder.

## Prerequisites

1. Terraform
2. AWS credentials

## How to Use

### 1. Override input variables (optional)

Export any variables that you want to override. Default values are available for each. For example, to override the Python version used, export this environment variable:

```console
$ export TF_VAR_python_version="3.6.6"
```

Variables that you can override:
* `TF_VAR_wam_args`
* `TF_VAR_python_version`
* `TF_VAR_git_version`
* `TF_VAR_windows_version`
* `TF_VAR_aws_region`
* `TF_VAR_az_to_find_subnet`
* `TF_VAR_subnet_id`
* `TF_VAR_instance_profile`
* `TF_VAR_instance_type`
* `TF_VAR_name_prefix`

Or, you can create a dotenv (`.env`) file with your regularly used values. Simply `source` your dotenv before applying with Terraform.

Example dotenv (`.env`) file:
```
export TF_VAR_python_version="3.6.6"
```

To use the file:
```console
$ source .env
```

### 2. Run Terraform

```console
$ terraform init
$ terraform apply
```

### 3. Do your stuff

If you need to log into the EC2 with RDP, you'll see the public DNS in the output from Terraform. To see the `Administrator` password, type `terraform output win_pass`.

### 4. Tear down

Clobber everything with a simple command:

```console
$ terraform destroy
```
