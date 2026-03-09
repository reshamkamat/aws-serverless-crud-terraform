import json
import boto3
import uuid

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("serverless-crud-tasks")

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }

def lambda_handler(event, context):
    http_method = event.get("httpMethod")
    path_parameters = event.get("pathParameters") or {}
    task_id = path_parameters.get("id")

    if http_method == "POST":
        body = json.loads(event.get("body", "{}"))
        item = {
            "taskId": str(uuid.uuid4()),
            "title": body.get("title", ""),
            "status": body.get("status", "pending")
        }
        table.put_item(Item=item)
        return response(201, item)

    elif http_method == "GET" and task_id:
        result = table.get_item(Key={"taskId": task_id})
        item = result.get("Item")
        if not item:
            return response(404, {"message": "Task not found"})
        return response(200, item)

    elif http_method == "GET":
        result = table.scan()
        return response(200, result.get("Items", []))

    elif http_method == "PUT" and task_id:
        body = json.loads(event.get("body", "{}"))
        table.update_item(
            Key={"taskId": task_id},
            UpdateExpression="SET title = :t, #s = :s",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={
                ":t": body.get("title", ""),
                ":s": body.get("status", "pending")
            }
        )
        return response(200, {"message": "Task updated"})

    elif http_method == "DELETE" and task_id:
        table.delete_item(Key={"taskId": task_id})
        return response(200, {"message": "Task deleted"})

    return response(400, {"message": "Unsupported route"})
