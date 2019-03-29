#!/bin/bash


deploy_bucket=$1
profile=$2
region=$3
parameters=$4

rm -rf package

mkdir package

cp heathcheck-editor.py package/

cd package
    echo "Gathering requirements..."
    pip install -r ../requirements.txt --target .
cd ..

# Package up lambda code example:
# --s3-bucket dev2-useast1-lambda-deploy
# --profile dev2 --region us-east-1

echo "Packaging up lambda for deployment..."
aws cloudformation package \
    --template-file template.yaml \
    --s3-bucket $deploy_bucket \
    --s3-prefix lambda-healthcheck-editor \
    --output-template-file packaged-template.yaml \
    --profile $profile --region $region
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
    echo "Failed to create package"
    exit $RETCODE
fi

# Deploy the lambda
# --parameter-overrides Region=us-east-1 DomainName=https://example.com
echo "Deploying lambda..."
aws cloudformation deploy --capabilities CAPABILITY_IAM  --template-file ./packaged-template.yaml  --stack-name route53-disable-healthcheck-on-failover  --parameter-overrides $parameters --profile $profile  --region $region
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
    echo "Failed to deploy lambda package"
    exit $RETCODE
fi
