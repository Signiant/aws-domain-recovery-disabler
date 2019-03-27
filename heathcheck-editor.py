import boto3
import json
import logging
import os
import argparse

# import requests
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    A lambda function that trigger on primary DNS failover through alarm and SNS.
    Once failed over. Set the healthcheck on original DNS to always unhealthy so it prevent auto recovery to
    primary once primary is up.
    This prevent unexpected behaviour on Primary on automatic recovery.
    :param event:
    :param context:
    :return:
    """
    if 'DEBUG' in os.environ and os.environ['DEBUG'].lower() == "true":
        print("Received event: " + json.dumps(event, indent=2))

    if 'REGION' in os.environ:
        region = os.environ['REGION']

    message = event['Records'][0]['Sns']['Message']
    if type(message) is str:
        try:
            message = json.loads(message)
        except json.JSONDecodeError as err:
            logging.exception(f'JSON decode error: {err}')

    if message['Trigger']['Dimensions'][0]['name'] == "HealthCheckId":
        healthcheck_id = message['Trigger']['Dimensions'][0]['value']

    # set aws client session and
    SESSION = boto3.session.Session(region_name=region)
    cf = SESSION.client('route53')

    # disabled: set healthcheck to always healthy. inverted: invert always healthy to always unhealthy
    cf.update_health_check(HealthCheckId=healthcheck_id, Disabled=True, Inverted=True)


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Perform deletion on AWS cloudformation stacks based on criterias '
                                                 'listed ')

    parser.add_argument("--region", help="The AWS region the stack is in", dest='region', required=True)
    parser.add_argument("--profile", help="The name of an aws cli profile to use.", dest='profile', default=None,
                        required=False)

    args = parser.parse_args()

    # create the session for the boto3 with profile and region from user parameters
    SESSION = boto3.session.Session(profile_name=args.profile, region_name=args.region)
    cf = SESSION.client('route53')

    healthcheck_id="12345"

    cf.update_health_check(HealthCheckId=healthcheck_id, Disabled=True, Inverted=True)
