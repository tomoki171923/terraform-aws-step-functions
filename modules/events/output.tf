output "aws_cloudwatch_event_rule" {
  value = aws_cloudwatch_event_rule.this
}
output "aws_cloudwatch_event_target" {
  value = aws_cloudwatch_event_target.this
}
output "aws_iam_policy" {
  value = aws_iam_policy.this
}
output "aws_iam_role" {
  value = module.iam_role_event
}
