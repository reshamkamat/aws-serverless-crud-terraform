output "api_base_url" {
  value = "https://${aws_api_gateway_rest_api.task_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}"
}
