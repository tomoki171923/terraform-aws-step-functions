data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
// AWS managed policy
data "aws_iam_policy" "AWSLambdaRole" {
  name = "AWSLambdaRole"
}
