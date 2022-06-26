# terraform-aws-step-functions

Terraform module, which creates step-functions resources.

[Terraform Registry](https://registry.terraform.io/modules/tomoki171923/step-functions/aws/latest)

## Usage

```terraform
locals {
  state_machine_name = "example"
}
data "aws_sns_topic" "this" {
  name = "alarm_name"
}
data "aws_lambda_alias" "this" {
  function_name = "function_name"
  name          = "prod"
}

module "state_machine" {
  source  = "tomoki171923/step-functions/aws"
  version = "0.1.0"
  state_machine_name    = local.state_machine_name
  timedout_sns_topic_arn = data.aws_sns_topic.this.arn
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
      "Resource": "${data.aws_lambda_alias.this.arn}",
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
      "Comment": "Waiting",
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

```

## Examples

* [basic](https://github.com/tomoki171923/terraform-aws-step-functions/tree/main/examples/basic/)

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | ~> 4.19 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | ~> 4.19 |

## Inputs

| Name       | Description                                                                                                                | Type                                                                                                  | Default                                                                                                                                                                                                                                                                                                                         | Required |
| ---------- | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| state_machine_name   | state machine name                                                                                  | `string` | `` |   yes    |
| state_machine_type    | Determines whether a Standard or Express state machine is created. The default is STANDARD.          | `string` | `"STANDARD"` |   yes    |
| state_machine_definition    | The Amazon States Language definition of the state machine. See [official](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html) for details.        | `string` | `` |   yes    |
| state_machine_additional_policies    | additional iam policies for state machine.          | `list(string)` | `[]` |   no    |
| state_machine_log_level    | Defines which category of execution history events are logged. Valid values: ALL, ERROR, FATAL, OFF.          | `string` | `"ALL"` |   no    |
| state_machine_log_retention_in_days    | Specifies the number of days you want to retain state machine log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.          | `number` | `120` |   no    |
| timedout_sns_topic_arn    | SNS Topic ARN when state machine's state is timedout.          | `string` | null |   no    |
| failed_sns_topic_arn    | SNS Topic ARN when state machine's state is failed.          | `string` | null |   no    |
| succeeded_sns_topic_arn    | SNS Topic ARN when state machine's state is succeeded.          | `string` | null |   no    |
| event_params    | event bridge parameters. name: event name, description: event description, input: input data to event, schedule_expression: schedule expression.          | <pre>list(object({<br> name = string<br> description = string<br> input = string<br> schedule_expression = string<br>}))</pre>                                                                                                                                | null |   no    |
| tags    | A map of tags to assign to resources.          | <pre>map(string)</pre>  | {} |   no    |

## Outputs

| Name               | Description                                                                                                                                                               |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| hogehoge           | hogehogehoge. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/) for details. |
| fugafuga           | fugafugafuga. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/) for details. |

## Authors

Module managed by [tomoki171923](https://github.com/tomoki171923).

## License

MIT Licensed. See LICENSE for full details.
