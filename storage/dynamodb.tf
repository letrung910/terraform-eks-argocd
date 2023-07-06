resource "aws_dynamodb_table" "lambda_dynamodb" {
  name           = "${var.project}-${var.environment}-lambda-dynamodb"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
  server_side_encryption { enabled = true }

  tags = merge(module.env.common_tags, {
    Terraform = "true"
  })
}
