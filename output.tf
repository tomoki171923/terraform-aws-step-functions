output "aws_sfn_state_machine" {
  value = aws_sfn_state_machine.this
}
output "aws_iam_policy" {
  value = {
    sns  = aws_iam_policy.sns
    logs = aws_iam_policy.logs
  }
}
output "aws_iam_role" {
  value = module.iam_role
}
