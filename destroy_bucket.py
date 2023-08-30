import os
import boto3
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')

bucket_name = os.environ.get('BUCKET_NAME')

if bucket_name:
    try:
        s3_client.head_bucket(Bucket=bucket_name)
    except ClientError as e:
        if e.response['Error']['Code'] == '404':
            print(f"S3 bucket '{bucket_name}' does not exist.")
        else:
            print(f"An error occurred: {e}")
    else:
        try:
            objects = s3_client.list_objects(Bucket=bucket_name)
            if 'Contents' in objects:
                for obj in objects['Contents']:
                    s3_client.delete_object(Bucket=bucket_name, Key=obj['Key'])
            s3_client.delete_bucket(Bucket=bucket_name)
            print(f'S3 bucket "{bucket_name}" deleted successfully!')
        except ClientError as e:
            print(f"An error occurred while deleting the bucket: {e}")
else:
    print("Environment variable 'BUCKET_NAME' not set.")
