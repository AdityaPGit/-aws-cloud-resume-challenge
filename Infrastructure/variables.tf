variable "bucketName" {
  type = string
  default = "objects-holder-for-crc"
}
variable "region" {
  type = string
  default = "ap-south-1"
}
variable "tableName" {
  type = string
  default = "views-counter-table"
}
variable "lambdaName" {
  type = string
  default = "incremental-lambda"
}
variable "arnLambdaRole" {
  type = string
  default = "" #Lambda Function's role's ARN
}
variable "apiGateway" {
  type = string
  default = "lambda-incrementer-api"
}
variable "lambdaARN" {
  type = string
  default = "" #Lambda Function's ARN
}
variable "cloudfrontOrigin" {
  type = string
  default = "" #URL of S3 to which cloudfront is pointing
}
variable "cache_policy_id" {
  type = string
  default = "" #Cache Policy ID
}
variable "originaccessid" {
  type = string
  default = ""
}