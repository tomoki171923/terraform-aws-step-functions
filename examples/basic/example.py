# -*- coding: utf-8 -*-
"""
Arguments Requirement :
{
    index: Required
}
Argument example :
{
    "index": 0
}
"""

completionCount: int = 3


def lambda_handler(event, context):
    print(event)
    is_args_correct: bool = event.keys() >= {"index"}
    if is_args_correct is False:
        return {"statusCode": 500, "body": "Invalid arguments"}
    index: int = int(event["index"])
    print(f"hello world {index}")
    index += 1
    is_completed: bool = False
    if completionCount <= index:
        is_completed = True
    return {
        "statusCode": 200,
        "isCompleted": is_completed,
        "index": index,
    }
