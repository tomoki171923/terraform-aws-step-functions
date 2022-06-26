# Complete Simple Step Functions

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

## Examples

* [basic](https://github.com/tomoki171923/terraform-aws-ModuleName/tree/main/examples/basic/)

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

| Name                                | Description                                                                                                                                                                                                                                                                                    | Type                                                                                                                           | Default      | Required |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------ | :------: |
| state_machine_name                  | state machine name                                                                                                                                                                                                                                                                             | `string` | ``           |   yes    |
| state_machine_type                  | Determines whether a Standard or Express state machine is created. The default is STANDARD.                                                                                                                                                                                                    | `string` | `"STANDARD"` |   yes    |
| state_machine_definition            | The Amazon States Language definition of the state machine. See [official](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html) for details.                                                                                                             | `string` | ``           |   yes    |
| state_machine_additional_policies   | additional iam policies for state machine.                                                                                                                                                                                                                                                     | `list(string)` | `[]` |    no    |
| state_machine_log_level             | Defines which category of execution history events are logged. Valid values: ALL, ERROR, FATAL, OFF.                                                                                                                                                                                           | `string` | `"ALL"` |    no    |
| state_machine_log_retention_in_days | Specifies the number of days you want to retain state machine log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `120` |    no    |
| timedout_sns_topic_arn              | SNS Topic ARN when state machine's state is timedout.                                                                                                                                                                                                                                          | `string` | null         |    no    |
| failed_sns_topic_arn                | SNS Topic ARN when state machine's state is failed.                                                                                                                                                                                                                                            | `string` | null         |    no    |
| succeeded_sns_topic_arn             | SNS Topic ARN when state machine's state is succeeded.                                                                                                                                                                                                                                         | `string` | null         |    no    |
| event_params                        | event bridge parameters. name: event name, description: event description, input: input data to event, schedule_expression: schedule expression.                                                                                                                                               | <pre>list(object({<br> name = string<br> description = string<br> input = string<br> schedule_expression = string<br>}))</pre> | null         |    no    |
| tags                                | A map of tags to assign to resources.                                                                                                                                                                                                                                                          | <pre>map(string)</pre>                                                                                                         | {}           |    no    |

## Outputs

| Name                        | Description                                                                                                                                                                   |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| aws_sfn_state_machine       | Provides a Step Function State Machine resource. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) for details.   |
| aws_iam_policy              | Provides an IAM policy. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) for details.                                   |
| aws_iam_role                | Provides an IAM Role. See [official](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role) for details.                   |
| aws_cloudwatch_metric_alarm | Provides a CloudWatch Metric Alarm resource. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) for details. |
| events                      | Provides an EventBridge Rule resource and others. See [the module](https://github.com/tomoki171923/terraform-aws-step-functions/tree/main/modules/events/) for details.       |

## Authors

Module managed by [tomoki171923](https://github.com/tomoki171923).

## License

MIT Licensed. See LICENSE for full details.
