# import json
# import boto3
# import subprocess
# import os
# import time


# def lambda_handler(event, context):
#     # Trigger some really time consuming code <---- RUN IT AFTER RETURNING
#     print ("hello lambda")
#     return {  #         <---- RETURN THIS RIGHT AWAY
#         'statusCode': 200,
#         'body': json.dumps('Hello from Lambda! Real Test')
#     }

import json
import boto3
import os

Project = os.environ.get('Project', 'workshop111')
Environment = os.environ.get('Environment', 'DEV111')
dynamodb = boto3.resource("dynamodb")
table_name =  Project+'-'+Environment+'-lambda-dynamodb'
table = dynamodb.Table(table_name)

def lambda_handler(event, context):

    data = table.get_item(
        Key={
            "id": "1"
        }
    )

#   data = client.scan(
#     TableName='dev111-lambda-dynamodb'
#   )
    response = {
        'statusCode': 200,
        'body': json.dumps(data),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }

    return response