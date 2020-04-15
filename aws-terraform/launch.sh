#!/bin/bash
set -e
terraform init
terraform validate
terraform apply
