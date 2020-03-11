import functools
import json


def is_admin(func):
    @functools.wraps(func)
    def wrapper(event, context):
        if "admin" in event["requestContext"]["authorizer"].get(
            "cognito:groups", ""
        ).split(","):
            return func(event, context)

        return {
            "statusCode": 403,
            "body": json.dumps({"message": "Unauthorized"}),
        }

    return wrapper
