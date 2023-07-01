module "sg_apigateway" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.environment}-sg-apigateway"
  description = "sg-apigateway"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

}



module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name                 = "${var.environment}-apigateway"
  description          = "My awesome HTTP API Gateway"
  protocol_type        = "HTTP"
  create_api_gateway   = true # to control creation of API Gateway
  create_vpc_link      = true
  create_default_stage = false # to control creation of "$default" stage
  # create_default_stage_api_mapping = true
  create_routes_and_integrations = true

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }


  # Access logs
  default_stage_access_log_destination_arn = "arn:aws:logs:eu-west-1:657177457547:log-group:debug-apigateway"
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"


  create_api_domain_name = false # to control creation of API Gateway Domain Name
  # Routes and integrations
  integrations = {
    "GET /test" = {
      lambda_arn             = module.lambda_function_in_vpc.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
    "GET /test4" = {
      lambda_arn             = module.lambda_function_in_vpc.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
    "GET /test3" = {
      lambda_arn             = module.lambda_function_in_vpc.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
    "GET /test2" = {
      lambda_arn             = module.lambda_function_in_vpc.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
    "GET /test1" = {
      lambda_arn             = module.lambda_function_in_vpc.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = module.lambda_function_in_vpc.lambda_function_arn
    }
  }

  vpc_links = {
    my-vpc = {
      name               = "example"
      security_group_ids = [module.sg_apigateway.security_group_id]
      subnet_ids         = data.terraform_remote_state.networking.outputs.public_subnets
    }
  }
  tags = {
    Name = "http-apigateway"
  }
}

resource "aws_apigatewayv2_stage" "example" {
  api_id      = module.api_gateway.apigatewayv2_api_id
  name        = "example-stage"
  auto_deploy = true
}





