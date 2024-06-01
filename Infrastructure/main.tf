#Provider
provider "aws"{
    profile = "default"
    region = var.region
}

#CloudFront
resource "aws_cloudfront_distribution" "cloudresumecloudfront" {
    enabled = false
    is_ipv6_enabled = true
    default_root_object = "index.html"
    origin {
      domain_name = var.cloudfrontOrigin
      origin_id   = var.cloudfrontOrigin
      origin_access_control_id = var.originaccessid
      connection_attempts = 3
      connection_timeout = 10
    }
    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }
    viewer_certificate {
      acm_certificate_arn = null
      cloudfront_default_certificate = true
      iam_certificate_id = null
      minimum_protocol_version = "TLSv1"
      ssl_support_method = null
    }
    default_cache_behavior {
            allowed_methods            = [
            "DELETE",
            "GET",
            "HEAD",
            "OPTIONS",
            "PATCH",
            "POST",
            "PUT",
        ]
        cached_methods             = [
            "GET",
            "HEAD",
        ]
        target_origin_id           = var.cloudfrontOrigin
        viewer_protocol_policy     = "https-only"
        cache_policy_id = var.cache_policy_id
        compress = true
    }
}

#s3 bucket
resource "aws_s3_bucket" "crc_bucket" {
    bucket = var.bucketName
}

#DynamoDB
resource "aws_dynamodb_table" "counterdb" {
    name = var.tableName
}

#Lambda
resource "aws_lambda_function" "counterLambda" {
    filename = "packed.zip"
    function_name = var.lambdaARN
    role         =  var.arnLambdaRole
    handler      = "lambda_function.lambda_handler"
    runtime      = "python3.10"
}

#API Gateway
resource "aws_apigatewayv2_api" "callerAPI" {
    name          = var.apiGateway
    protocol_type = "HTTP"
    cors_configuration {
      allow_origins = [""] #Contains url for access to the CloudFront Distribution
      allow_credentials = false
      allow_headers = ["*"]
      allow_methods = ["*"]
      expose_headers = ["*"]
      max_age = 1
    }
}

resource "aws_apigatewayv2_integration" "callerAPIIntegration" {
    api_id             = aws_apigatewayv2_api.callerAPI.id
    integration_type   = "AWS_PROXY"
    integration_method = "POST"
    payload_format_version = "2.0"
    integration_uri    = aws_lambda_function.counterLambda.arn
}

resource "aws_apigatewayv2_route" "callerAPIRoute" {
    api_id    = aws_apigatewayv2_api.callerAPI.id
    route_key = "GET /incrementer"
    target    = "integrations/${aws_apigatewayv2_integration.callerAPIIntegration.id}"
}

resource "aws_apigatewayv2_stage" "deploymentStage" {
    api_id  = aws_apigatewayv2_api.callerAPI.id
    name = "deployer"
}
