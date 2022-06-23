# terraform-aws-ModuleName

Terraform module, which ModuleName.

[Terraform Registry](https://registry.terraform.io/modules/tomoki171923/ModuleName/aws/latest)

## Usage

hogehoge.

```terraform
module "ModuleName" {
  source  = "tomoki171923/ModuleName/aws"
}
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

| Name       | Description                                                                                                                | Type                                                                                                  | Default                                                                                                                                                                                                                                                                                                                         | Required |
| ---------- | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| hogehoge   | hogehogehoge                                                                                  | `string` | `""` |   yes    |
| fugafuga    | fugafugafuga          | <pre>list(object({<br> name = string<br> id = string<br> arn = string<br>}))</pre> | `[]` |   yes    |

## Outputs

| Name               | Description                                                                                                                                                               |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| hogehoge           | hogehogehoge. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/) for details. |
| fugafuga           | fugafugafuga. See [official](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/) for details. |

## Authors

Module managed by [tomoki171923](https://github.com/tomoki171923).

## License

MIT Licensed. See LICENSE for full details.
