#!/bin/bash


rm -rf package

mkdir package

cp heathcheck-editor.py package/

cd package
    echo "Gathering requirements..."
    pip install -r ../requirements.txt --target .
cd ..

# Package up lambda code
echo "Packaging up lambda for deployment..."
aws cloudformation package \
    --template-file template.yaml \
    --s3-bucket dev2-useast1-lambda-deploy \
    --s3-prefix lambda-healthcheck-editor \
    --output-template-file packaged-template.yaml \
    --profile dev2
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
    echo "Failed to create package"
    exit $RETCODE
fi

# Deploy the lambda
echo "Deploying lambda..."
aws cloudformation deploy     --capabilities CAPABILITY_IAM  --template-file ./packaged-template.yaml  --stack-name route53-disable-healthcheck-on-failover    --parameter-overrides Region=us-east-1 --profile dev2  --region us-east-1
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
    echo "Failed to deploy lambda package"
    exit $RETCODE
fi
