provider "aws" {
  region  = "ap-northeast-3"
  profile = "private"
}

/*
  Lambda Function
*/
data "aws_iam_role" "LambdaExecute" {
  name = "LambdaExecute"
}
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  create_function = true
  create_layer    = false
  create_role     = false

  function_name = "example"
  description   = "example function"
  handler       = "example.lambda_handler"
  runtime       = "python3.9"

  source_path = [
    "${path.module}/example.py"
  ]
  layers                 = []
  lambda_role            = data.aws_iam_role.LambdaExecute.arn
  memory_size            = 128
  timeout                = 3
  maximum_retry_attempts = 2
  environment_variables = {
    AWS_LAMBDA_FUNCTION_ALIAS = "dev"
  }
  publish = true

  use_existing_cloudwatch_log_group = false
  cloudwatch_logs_retention_in_days = 30
  cloudwatch_logs_tags = {
    Terraform = true
  }
  tags = {
    Terraform = true
  }
}

module "lambda_alias" {
  source           = "terraform-aws-modules/lambda/aws//modules/alias"
  version          = "3.3.1"
  create           = true
  refresh_alias    = false
  name             = "dev"
  function_name    = module.lambda_function.lambda_function_name
  function_version = module.lambda_function.lambda_function_version
}


/*
  State Machine
*/
locals {
  state_machine_name = "example"
}
data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
data "aws_sns_topic" "this" {
  name = "states_alarms"
}
module "state_machine" {
  source                = "../../"
  state_machine_name    = local.state_machine_name
  timeout_sns_topic_arn = data.aws_sns_topic.this.arn
  failed_sns_topic_arn  = data.aws_sns_topic.this.arn
  tags = {
    Terraform   = true
    Environment = "dev"
  }
  event_params = [
    {
      name                = "${local.state_machine_name}_execution"
      description         = "execute ${local.state_machine_name} state machine."
      input               = <<EOF
{
  "index": 0
}
EOF
      schedule_expression = "rate(1 day)"
    }
  ]
  state_machine_definition = <<EOF
{
  "Comment": "Example State Machine",
  "TimeoutSeconds": 60,
  "StartAt": "FunctionExample",
  "States": {
    "FunctionExample": {
      "Type": "Task",
      "Comment": "Lambda Function: Example",
      "InputPath": "$",
      "Resource": "${module.lambda_alias.lambda_alias_arn}",
      "ResultPath": "$",
      "Next": "CheckCompletion",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "Fail"
        }
      ]
    },
    "CheckCompletion": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.isCompleted",
          "BooleanEquals": true,
          "Next": "Succeed"
        },
        {
          "Variable": "$.isCompleted",
          "BooleanEquals": false,
          "Next": "Wait"
        }
      ],
      "Default": "Fail"
    },
    "Wait": {
      "Type": "Wait",
      "Comment": "Waitting",
      "Seconds": 5,
      "Next": "FunctionExample"
    },
    "Succeed": {
      "Type": "Succeed",
      "Comment": "Succeed State."
    },
    "Fail": {
      "Type": "Fail",
      "Comment": "Fail State.",
      "Error": "STATE MACHINE ERROR: ${local.state_machine_name}",
      "Cause": "Caused By Message."
    }
  }
}
EOF
}
