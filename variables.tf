variable "state_machine_name" {
  description = "state_machine_name"
  type        = string
}
variable "state_machine_type" {
  description = "Determines whether a Standard or Express state machine is created. The default is STANDARD. "
  type        = string
  default     = "STANDARD"
}
variable "state_machine_definition" {
  description = "state_machine_definition"
  type        = string
}
variable "state_machine_additional_policies" {
  description = "additional iam policies for state machine."
  type        = list(string)
  default     = []
}
variable "state_machine_log_level" {
  description = "Defines which category of execution history events are logged. Valid values: ALL, ERROR, FATAL, OFF"
  type        = string
  default     = "ALL"
}
variable "state_machine_log_retention_in_days" {
  description = "Specifies the number of days you want to retain state machine log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 120
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
variable "succeeded_sns_topic_arn" {
  description = "SNS Topic ARN when state machine's state is succeeded."
  type        = string
  default     = null
}
