from pprint import pprint
import boto3
from botocore.exceptions import ClientError
def lambda_handler(event,context):
    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('dd-test')
    print(event['id'])
    i = event['id']
    l = event['location']
    n = event['name']
    print (i)
    print (l)
    print(n)
    response = table.update_item(
        ExpressionAttributeNames={
        '#LOC': 'location',
        '#NAM' : 'name'
        },
        ExpressionAttributeValues={
            ':l': event['location'],
            ':n': event['name']
        },
        Key={
            'id': event['id']
        },
        UpdateExpression="SET #LOC=:l, #NAM=:n",
        ReturnValues="UPDATED_NEW"
    )
    return response
