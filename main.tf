# ********************************* #
# ref:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
# ********************************* #


/*
 State Machine
*/
resource "aws_sfn_state_machine" "this" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.iam_for_sfn.arn
  type     = var.state_machine_type

  definition = var.state_machine_definition
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.this.arn}:*"
    include_execution_data = true
    level                  = var.state_machine_log_level
  }
  tags = {
    Terraform = true
  }
}
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/vendedlogs/states/${var.state_machine_name}"
  retention_in_days = var.state_machine_log_retention_in_days

  tags = {
    Terraform = true
  }
}

/*
 IAM Role For State Machine
*/
data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliverys",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "logs" {
  name        = "WriteLogs_${var.state_machine_name}"
  description = "write cloudwatch logs permission for ${var.state_machine_name} State Machine."
  policy      = data.aws_iam_policy_document.logs.json
  tags = {
    Terraform = true
  }
}
data "aws_iam_policy_document" "sns" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "arn:aws:sns:*:${data.aws_caller_identity.this.account_id}:*"
    ]
  }
}
resource "aws_iam_policy" "sns" {
  name        = "PublishSNS_${var.state_machine_name}"
  description = "publish sns topic permission for ${var.state_machine_name} State Machine."
  policy      = data.aws_iam_policy_document.sns.json
  tags = {
    Terraform = true
  }
}
module "iam_role" {
  # remote module
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.1.0"

  trusted_role_services = [
    "states.amazonaws.com"
  ]
  create_role       = true
  role_name         = "StepFunctionsRole_${var.state_machine_name}"
  role_description  = "Step Functions (${var.state_machine_name}) IAM Role."
  role_requires_mfa = false

  custom_role_policy_arns = concat([
    aws_iam_policy_document.sns.arn,
  aws_iam_policy_document.logs.arn], var.state_machine_additional_policies)
  tags = {
    Terraform = true
  }
}


/*
 CloudWatch Memetric Alarm
*/
resource "aws_cloudwatch_metric_alarm" "timeout" {
  count               = var.timeout_sns_topic_arn == null ? 0 : 1
  alarm_name          = "step_functions_${var.state_machine_name}_timeout"
  alarm_description   = "StepFunctions ${var.state_machine_name} Execution TimeOut. "
  alarm_actions       = [var.timeout_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.this.name
  }
  evaluation_periods = 1
  metric_name        = "ExecutionsTimeOut"
  namespace          = "AWS/States"
  period             = 60
  statistic          = "Average"
  threshold          = 0
  treat_missing_data = "missing"
  tags = {
    Terraform = true
  }
}
resource "aws_cloudwatch_metric_alarm" "failed" {
  count               = var.failed_sns_topic_arn == null ? 0 : 1
  alarm_name          = "step_functions_${var.state_machine_name}_failed"
  alarm_description   = "StepFunctions ${var.state_machine_name} Execution Failed. "
  alarm_actions       = [var.failed_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.this.name
  }
  evaluation_periods = 1
  metric_name        = "ExecutionsFailed"
  namespace          = "AWS/States"
  period             = 60
  statistic          = "Average"
  threshold          = 0
  treat_missing_data = "missing"
  tags = {
    Terraform = true
  }
}
resource "aws_cloudwatch_metric_alarm" "succeeded" {
  count               = var.succeeded_sns_topic_arn == null ? 0 : 1
  alarm_name          = "step_functions_${var.state_machine_name}_succeeded"
  alarm_description   = "StepFunctions ${var.state_machine_name} Execution Succeeded. "
  alarm_actions       = [var.succeeded_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.this.name
  }
  evaluation_periods = 1
  metric_name        = "ExecutionsSucceeded"
  namespace          = "AWS/States"
  period             = 60
  statistic          = "Average"
  threshold          = 0
  treat_missing_data = "missing"
  tags = {
    Terraform = true
  }
}
