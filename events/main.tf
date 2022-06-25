resource "aws_cloudwatch_event_rule" "this" {
  for_each = {
    for key in var.event_params : key.name => {
      name                = key.name
      description         = key.description
      schedule_expression = key.schedule_expression
    }
  }
  name                = each.value.name
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
  is_enabled          = true
  tags                = var.tags
}
resource "aws_cloudwatch_event_target" "this" {
  for_each = {
    for key in var.event_params : key.name => {
      name  = key.name
      input = key.input
    }
  }
  rule     = aws_cloudwatch_event_rule.this[each.value.name].name
  arn      = module.iam_role_event.iam_role_arn
  role_arn = var.state_machine_arn
  input    = each.value.input
}
module "iam_role_event" {
  # remote module
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.1.0"

  trusted_role_services = [
    "events.amazonaws.com"
  ]
  create_role       = true
  role_name         = "EventBridgeInvokeStepFunctions_${var.state_machine_name}"
  role_description  = "EventBridge execution role for ${var.state_machine_name} Step Functions."
  role_requires_mfa = false

  custom_role_policy_arns = []
  tags                    = var.tags
}
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      "${var.state_machine_arn}"
    ]
  }
}
resource "aws_iam_policy" "this" {
  name        = "InvokeStepFunctions_${var.state_machine_name}"
  description = "publish sns topic permission for ${var.state_machine_name} State Machine."
  policy      = data.aws_iam_policy_document.this.json
  tags        = var.tags
}
