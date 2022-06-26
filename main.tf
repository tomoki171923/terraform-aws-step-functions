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
  role_arn = module.iam_role_step_function.iam_role_arn
  type     = var.state_machine_type

  definition = var.state_machine_definition
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.this.arn}:*"
    include_execution_data = true
    level                  = var.state_machine_log_level
  }
  tags = var.tags
}
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/vendedlogs/states/${var.state_machine_name}"
  retention_in_days = var.state_machine_log_retention_in_days

  tags = var.tags
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
      "logs:ListLogDeliveries",
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
  name        = "CloudWatchLogsDeliveryFullAccessPolicy-${var.state_machine_name}"
  description = "cloudwatch logs full access permission for ${var.state_machine_name} State Machine."
  policy      = data.aws_iam_policy_document.logs.json
  tags        = var.tags
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
  tags        = var.tags
}
module "iam_role_step_function" {
  # remote module
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.1.0"

  trusted_role_services = [
    "states.amazonaws.com"
  ]
  create_role       = true
  role_name         = "StepFunctions-${var.state_machine_name}-role"
  role_description  = "Step Functions (${var.state_machine_name}) IAM Role."
  role_requires_mfa = false

  custom_role_policy_arns = concat([
    data.aws_iam_policy.AWSLambdaRole.arn,
    aws_iam_policy.sns.arn,
  aws_iam_policy.logs.arn], var.state_machine_additional_policies)
  tags = var.tags
}


/*
  CloudWatch Memetric Alarm
*/
locals {
  state_machine_url = "https://${data.aws_region.this.name}.console.aws.amazon.com/states/home?region=${data.aws_region.this.name}#/statemachines/view/arn:aws:states:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:stateMachine:${var.state_machine_name}"
}
resource "aws_cloudwatch_metric_alarm" "timedout" {
  count               = var.timedout_sns_topic_arn == null ? 0 : 1
  alarm_name          = "step_functions_${var.state_machine_name}_timedout"
  alarm_description   = "StepFunctions ${var.state_machine_name} Execution TimedOut. StateMachine: <${local.state_machine_url}>"
  alarm_actions       = [var.timedout_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.this.arn
  }
  evaluation_periods = 1
  metric_name        = "ExecutionsTimedOut"
  namespace          = "AWS/States"
  period             = 60
  statistic          = "Average"
  threshold          = 0
  treat_missing_data = "missing"
  tags               = var.tags
}
resource "aws_cloudwatch_metric_alarm" "failed" {
  count               = var.failed_sns_topic_arn == null ? 0 : 1
  alarm_name          = "step_functions_${var.state_machine_name}_failed"
  alarm_description   = "StepFunctions ${var.state_machine_name} Execution Failed. StateMachine: <${local.state_machine_url}>"
  alarm_actions       = [var.failed_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.this.arn
  }
  evaluation_periods = 1
  metric_name        = "ExecutionsFailed"
  namespace          = "AWS/States"
  period             = 60
  statistic          = "Average"
  threshold          = 0
  treat_missing_data = "missing"
  tags               = var.tags
}
resource "aws_cloudwatch_metric_alarm" "succeeded" {
  count               = var.succeeded_sns_topic_arn == null ? 0 : 1
  alarm_name          = "step_functions_${var.state_machine_name}_succeeded"
  alarm_description   = "StepFunctions ${var.state_machine_name} Execution Succeeded. StateMachine: <${local.state_machine_url}>"
  alarm_actions       = [var.succeeded_sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.this.arn
  }
  evaluation_periods = 1
  metric_name        = "ExecutionsSucceeded"
  namespace          = "AWS/States"
  period             = 60
  statistic          = "Average"
  threshold          = 0
  treat_missing_data = "missing"
  tags               = var.tags
}


/*
  Event Bridge
*/
module "events" {
  count              = var.event_params == null ? 0 : 1
  source             = "./modules/events/"
  event_params       = var.event_params
  state_machine_name = aws_sfn_state_machine.this.name
  state_machine_arn  = aws_sfn_state_machine.this.arn
  aws_account_id     = data.aws_caller_identity.this.account_id
  aws_region         = data.aws_region.this.name
  tags               = var.tags
}
