# platform-circuit-breaker


Here is a cloudformation stack that will prevent failover automatic recovery as listed in this aws post
[How can I prevent failover automatic recovery?](https://forums.aws.amazon.com/thread.jspa?threadID=128432)

This issue has never been resolved and this is just [our][www.signiant.com] take to the solution.

When properly deployed this aws cloudformation stack will do the following:

1) create a health check for a specific domain specified by the user that notifies an alarm on domain failover
2) create the alarm that sends an event to SNS topic on failover
3) create the SNS topic to receive alarm event
4) create an SNS Subscription that sends an event from topic to a lambda function
5) create a lambda function that when detect the SNS subscription event will set healthcheck to always fail.

To deploy this cloudformation stack, simply clone the repo locally and run `./deploy.sh [1] [2] [3] [4] [5]`

the `./deploy.sh` script will need the following parameters
1) s3 bucket to store the lambda function
2) the profile of aws to be deployed on
3) the region of the aws to be deployed on
4) the prefix name (the domain the stack will cover) of the newly created stack (`route53-prevent-switch-primary-${prefix_name}`)
5) override parameters that are required to specify the region (same as number 3) and domain name (the domain the user want to perform a health check on)


An example of the `./deploy.sh`:

```./deploy.sh dev2-useast1-lambda-deploy dev2 us-east-1  my-domain-check-name "Region=us-east-1 DomainName=test-microservice-domain.com"```

The above command will execute the stack packing and stack deploy automatically. Take of the closer look of the deploy.sh to see if it matches your need.



