import json
import os

from auth.decorators import is_admin


def user(event, context):
    return {
        "statusCode": 204,
        "headers": {"Access-Control-Allow-Origin": os.environ["FRONTEND_URL"]},
    }


@is_admin
def admin(event, context):
    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": os.environ["FRONTEND_URL"]},
        "body": json.dumps({"data": "Top-secret admin payload!"}),
    }
