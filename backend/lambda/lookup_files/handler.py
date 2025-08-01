import boto3
import json
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('FileMetadata')

def lambda_handler(event, context):
    try:
        # Scan all items in the table
        response = table.scan()
        items = response.get('Items', [])

        # 格式化时间和文件大小（可选）
        for item in items:
            if 'uploadTime' in item:
                item['uploadTime'] = item['uploadTime'][:19].replace('T', ' ')
            if 'size' in item:
                item['size'] = f"{round(int(item['size']) / 1024, 2)} KB"

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(items)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }
