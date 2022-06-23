variable "hogehoge" {
  description = "hogehogehoge"
  tyoe        = string
  default     = ""
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
