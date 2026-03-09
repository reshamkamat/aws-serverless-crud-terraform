resource "aws_api_gateway_rest_api" "task_api" {
  name = "${var.project_name}-api"
}

resource "aws_api_gateway_resource" "tasks" {
  rest_api_id = aws_api_gateway_rest_api.task_api.id
  parent_id   = aws_api_gateway_rest_api.task_api.root_resource_id
  path_part   = "tasks"
}

resource "aws_api_gateway_resource" "task_id" {
  rest_api_id = aws_api_gateway_rest_api.task_api.id
  parent_id   = aws_api_gateway_resource.tasks.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "post_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.task_api.id
  resource_id   = aws_api_gateway_resource.tasks.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.task_api.id
  resource_id   = aws_api_gateway_resource.tasks.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_task_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.task_api.id
  resource_id   = aws_api_gateway_resource.task_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "put_task_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.task_api.id
  resource_id   = aws_api_gateway_resource.task_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_task_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.task_api.id
  resource_id   = aws_api_gateway_resource.task_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_tasks" {
  rest_api_id             = aws_api_gateway_rest_api.task_api.id
  resource_id             = aws_api_gateway_resource.tasks.id
  http_method             = aws_api_gateway_method.post_tasks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.task_api.invoke_arn
}

resource "aws_api_gateway_integration" "get_tasks" {
  rest_api_id             = aws_api_gateway_rest_api.task_api.id
  resource_id             = aws_api_gateway_resource.tasks.id
  http_method             = aws_api_gateway_method.get_tasks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.task_api.invoke_arn
}

resource "aws_api_gateway_integration" "get_task_by_id" {
  rest_api_id             = aws_api_gateway_rest_api.task_api.id
  resource_id             = aws_api_gateway_resource.task_id.id
  http_method             = aws_api_gateway_method.get_task_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.task_api.invoke_arn
}

resource "aws_api_gateway_integration" "put_task_by_id" {
  rest_api_id             = aws_api_gateway_rest_api.task_api.id
  resource_id             = aws_api_gateway_resource.task_id.id
  http_method             = aws_api_gateway_method.put_task_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.task_api.invoke_arn
}

resource "aws_api_gateway_integration" "delete_task_by_id" {
  rest_api_id             = aws_api_gateway_rest_api.task_api.id
  resource_id             = aws_api_gateway_resource.task_id.id
  http_method             = aws_api_gateway_method.delete_task_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.task_api.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.task_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.task_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "task_api" {
  rest_api_id = aws_api_gateway_rest_api.task_api.id

  depends_on = [
    aws_api_gateway_integration.post_tasks,
    aws_api_gateway_integration.get_tasks,
    aws_api_gateway_integration.get_task_by_id,
    aws_api_gateway_integration.put_task_by_id,
    aws_api_gateway_integration.delete_task_by_id
  ]
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.task_api.id
  deployment_id = aws_api_gateway_deployment.task_api.id
  stage_name    = "dev"
}
