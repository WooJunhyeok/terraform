terraform {
  required_providers {
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "createuser" {
  # count = length(var.user_names)
  for_each = toset(var.user_names)

  # Make sure to update this to your own user name!
  # name = var.user_names[count.index]
  name = each.key
}

