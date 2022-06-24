variable "state_machine_name" {
  description = "state_machine_name"
  tyoe        = string
}
variable "state_machine_definition" {
  description = "state_machine_definition"
  tyoe        = string
}
variable "state_machine_additional_policies" {
  description = "additional iam policies for state machine."
  type        = list(string)
  default     = []
}
variable "timeout_sns_topic_arn" {
  description = "SNS Topic ARN when state machine's state is timeout."
  type        = string
  default     = null
}
variable "failed_sns_topic_arn" {
  description = "SNS Topic ARN when state machine's state is failed."
  type        = string
  default     = null
}


variable "fugafuga" {
  description = "fugafugafuga"
  type = list(
    object({
      name = string
      id   = string
      arn  = string
    })
  )
}
