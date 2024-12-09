terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }

  backend "s3" {
    workspace_key_prefix = "dm"
    key                  = "tfstate"
  }
}

provider "aws" {
  region = var.region
}
