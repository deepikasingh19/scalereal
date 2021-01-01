variable "role_name" {
    default = "iam_for_lambda"
  }
variable "lambda_timeout" {
  description = "Lambda timeout"
  default = "120"
}
variable "bucket_name" {
  description = "Bucket Name"
  default = "dd-test-nv"
}
variable "table_name" {
  description = "Dynamo DB table name"
  default = "dd-test"
}
variable "api_name" {
  description = "API name"
  default = "dd-test"
}