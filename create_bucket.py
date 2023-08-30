import os
import boto3
from botocore.exceptions import ClientError

s3_client = boto3.client('s3', region_name='eu-central-1')

bucket_name = os.environ.get('BUCKET_NAME')

try:
    s3_client.head_bucket(Bucket=bucket_name)
    print(f'S3 bucket "{bucket_name}" already exists.')
except ClientError as e:
    if e.response['Error']['Code'] == '404':
        s3_client.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={'LocationConstraint': 'eu-central-1'}
        )
        print(f'S3 bucket "{bucket_name}" created successfully!')
    else:
        print(f'An error occurred while checking the bucket: {e}')