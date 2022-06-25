variable "state_machine_name" {
  description = "state machine name"
  type        = string
}
variable "state_machine_arn" {
  description = "state machine arn"
  type        = string
}
variable "event_params" {
  description = "event bridge parameters. name: event name, input: input data to event, schedule_expression: schedule expression(cron format)."
  type = list(
    object({
      name                = string
      input               = string
      schedule_expression = string
    })
  )
}
variable "aws_account_id" {
  description = "aws account id"
  type        = string
}
variable "aws_region" {
  description = "aws region"
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
