provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy1" {
  name        = "dd-test-1"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy2" {
  name        = "dd-test-2"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach1" {
  name       = "attachment1"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy1.arn
}

resource "aws_iam_policy_attachment" "attach2" {
  name       = "attachment2"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy2.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "create.py"
  function_name = "createItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "${var.lambda_timeout}"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_lambda_function" "test_lambda2" {
  filename      = "read.py"
  function_name = "readItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "${var.lambda_timeout}"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_lambda_function" "test_lambda3" {
  filename      = "update.py"
  function_name = "updateItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "${var.lambda_timeout}"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_lambda_function" "test_lambda4" {
  filename      = "delete.py"
  function_name = "deleteItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "${var.lambda_timeout}"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}


resource "aws_s3_bucket" "bucket" {

  bucket = "${var.bucket_name}"
  acl    = "private"   
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "profile"
  acl    = "private" 
  source = "myfiles/dd-test.csv"
  etag = filemd5("myfiles/dd-test.csv")

}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.table_name}"
  hash_key       = "id"
}

resource "aws_api_gateway_rest_api" "test" {
  name = "${var.api_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_api_key" "MyDemoApiKey" {
  name = "dd-test"
}

resource "aws_api_gateway_usage_plan" "MyUsagePlan" {
  name         = "my-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.test.id
    stage  = aws_api_gateway_deployment.MyDemoDeployment.stage_name
  }

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_lambda_function" "authorizer" {
  filename      = "lambda-function.zip"
  function_name = "authorizer"
  role          = aws_iam_role.iam_for_lambda.arn

  source_code_hash = filebase64sha256("lambda-function.zip")
}


## Deploy Swagger file for the API
locals{
  "get_test_arn" = "${aws_lambda_function.get-tips-lambda.invoke_arn}"

  "x-amazon-test-apigateway-integration" = <<EOF
#
uri = "${local.get_test_arn}"
passthroughBehavior: when_no_match
httpMethod: POST
type: aws_proxy
credentials: "${aws_iam_role.iam_for_lambda.arn}"
EOF
}

data "template_file" test_api_swagger{
  template = "${file("./swagger.json")}"

  vars {
    apiIntegration = "${indent(8, local.x-amazon-test-apigateway-integration)}"
  }
}

resource "aws_api_gateway_deployment" "test-api-gateway-deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.test.id}"
  stage_name  = "test"
}
