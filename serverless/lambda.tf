

module "sg_lambda" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.environment}-sg-lambda"
  description = "sg-lambda"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["https-443-tcp", "ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule                     = "http-80-tcp"
      cidr_blocks              = "0.0.0.0/0"
      source_security_group_id = module.sg_apigateway.security_group_id
    },
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "lambda_function_in_vpc" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.environment}-my-lambda-in-vpc"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  timeout       = 5
  source_path   = "./lambda_code"

  vpc_subnet_ids                          = data.terraform_remote_state.networking.outputs.intra_subnets
  vpc_security_group_ids                  = [module.sg_lambda.security_group_id]
  attach_network_policy                   = true
  cloudwatch_logs_retention_in_days       = 3
  create_current_version_allowed_triggers = false
  environment_variables = {
    Serverless  = "Terraform"
    Environment = var.environment
    Project     = var.project
  }
  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
  attach_policy_statements = true
  policy_statements = {
    # Allow failures to be sent to SQS queue
    sqs_failure = {
      effect    = "Allow",
      actions   = ["sqs:SendMessage"],
      resources = ["*"]
    },
    # Execution role permissions to read records from an Amazon MQ broker
    # https://docs.aws.amazon.com/lambda/latest/dg/with-mq.html#events-mq-permissions
    mq_event_source = {
      effect    = "Allow",
      actions   = ["ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeVpcs"],
      resources = ["*"]
    },
    mq_describe_broker = {
      effect    = "Allow",
      actions   = ["mq:DescribeBroker"],
      resources = ["*"]
    },
    secrets_manager_get_value = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = ["*"]
    },
    dynamodb_get_value = {
      effect    = "Allow",
      actions   = ["dynamodb:*"],
      resources = ["*"]
    },
    kms_encrypt = {
      effect    = "Allow",
      actions   = ["kms:Decrypt", "kms:DescribeKey"],
      resources = ["*"]
    }
  }

  attach_policies    = true
  number_of_policies = 5

  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  tags = merge(module.env.common_tags, {
    Terraform = "true"
  })
}



