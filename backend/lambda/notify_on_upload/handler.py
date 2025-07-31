import json
import boto3
import os

sns_client = boto3.client('sns')
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            filename = new_image['filename']['S']
            upload_time = new_image['uploadTime']['S']
            s3_url = new_image['s3Url']['S']

            message = f"📁 New file uploaded:\n\nFilename: {filename}\nUploaded At: {upload_time}\n\nS3 URL:\n{s3_url}"

            sns_client.publish(
                TopicArn=sns_topic_arn,
                Subject='📁 New File Uploaded to S3',
                Message=message
            )
    
    return {"statusCode": 200, "body": "Notifications sent"}
