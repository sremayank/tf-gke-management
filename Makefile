SHELL := /usr/bin/env bash

ENV ?= dev
TF_DIR := live/$(ENV)
PLAN_FILE := $(TF_DIR)/tfplan

.PHONY: fmt init validate lint checkov plan clean

fmt:
	terraform fmt -recursive

init:
	terraform -chdir=$(TF_DIR) init -upgrade

validate:
	terraform -chdir=$(TF_DIR) validate

lint:
	tflint --recursive

checkov:
	checkov --directory . --framework terraform --quiet

plan:
	terraform -chdir=$(TF_DIR) plan -out=tfplan

clean:
	find . -type d -name .terraform -prune -exec rm -rf {} +
	find . -type f \( -name '*.tfplan' -o -name 'tfplan' \) -delete
