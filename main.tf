resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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
  lambda_timeout= "120"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_lambda_function" "test_lambda2" {
  filename      = "read.py"
  function_name = "readItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "120"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_lambda_function" "test_lambda3" {
  filename      = "update.py"
  function_name = "updateItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "120"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_lambda_function" "test_lambda3" {
  filename      = "delete.py"
  function_name = "deleteItem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  lambda_timeout= "120"
  source_code_hash = filebase64sha256("dd-test.py")
  runtime = "python3.8"

}

resource "aws_s3_bucket" "bucket" {

  bucket = "dd-test-nv"
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
  name           = "dd-test"
  hash_key       = "id"
}

resource "aws_api_gateway_rest_api" "test" {
  name = "dd-test"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}