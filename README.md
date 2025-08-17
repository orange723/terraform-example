# Terraform Example Project

This project provides example Terraform configurations for managing resources on AWS and GCP.

## Project Structure

The repository is organized by cloud provider:

- `aws/`: Contains Terraform configurations for AWS resources.
  - `alb/`: Intended for Application Load Balancer configurations. (Directory exists, content not specified)
  - `ec2/`: Intended for EC2 instance configurations. (Directory exists, content not specified)
- `gcp/`: Contains Terraform configurations for Google Cloud Platform resources.
  - `compute/`: Manages a Google Compute Engine (GCE) instance, including firewall rules and a static IP address.
  - `loadbalancing/`: Manages a Google Cloud Load Balancer, including health checks, backend services, and forwarding rules.

## Usage

Navigate to the desired configuration directory (e.g., `gcp/compute`) and run the standard Terraform commands:

```bash
# Initialize the backend and download providers
terraform init

# See what changes will be applied
terraform plan

# Apply the changes
terraform apply
```

Each module uses a GCS backend for remote state storage, as defined in the `terraform` block of each `main.tf` file.
