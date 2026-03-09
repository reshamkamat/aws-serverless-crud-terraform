resource "aws_lambda_function" "task_api" {
  function_name    = "${var.project_name}-task-api"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  timeout          = 10

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attach
  ]
}
