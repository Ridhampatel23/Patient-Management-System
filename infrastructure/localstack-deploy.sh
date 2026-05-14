#!/bin/bash

export AWS_PAGER=""

STACK_NAME="patient-management"
TEMPLATE_FILE="./cdk.out/localstack.template.json"
ENDPOINT_URL="http://localhost:4566"

echo ""
echo "=== Checking synthesized template ==="

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "ERROR: Template file not found: $TEMPLATE_FILE"
  echo "Run: cdk synth --output cdk.out"
  exit 1
fi

echo "Template: $TEMPLATE_FILE"

echo ""
echo "Kafka version in template:"
grep -n '"KafkaVersion"' "$TEMPLATE_FILE" || true

echo ""
echo "Checking for old Kafka version 2.8.0:"
if grep -nF "2.8.0" "$TEMPLATE_FILE"; then
  echo ""
  echo "ERROR: Template still contains Kafka 2.8.0."
  echo "Fix your CDK code, then run: cdk synth --output cdk.out"
  exit 1
else
  echo "OK: 2.8.0 not found."
fi

echo ""
echo "=== Deleting old failed stack if it exists ==="

aws --no-cli-pager --endpoint-url="$ENDPOINT_URL" cloudformation delete-stack \
  --stack-name "$STACK_NAME" 2>/dev/null || true

sleep 5

echo ""
echo "=== Cleaning leftover ECS log groups ==="

for LOG_GROUP in \
  "/ecs/api-gateway" \
  "/ecs/auth-service" \
  "/ecs/billing-service" \
  "/ecs/analytics-service" \
  "/ecs/patient-service"
do
  echo "Deleting log group if present: $LOG_GROUP"
  aws --no-cli-pager --endpoint-url="$ENDPOINT_URL" logs delete-log-group \
    --log-group-name "$LOG_GROUP" 2>/dev/null || true
done

echo ""
echo "=== Deploying CloudFormation stack ==="

aws --no-cli-pager --endpoint-url="$ENDPOINT_URL" cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE"

DEPLOY_EXIT_CODE=$?

echo ""
echo "=== Failed CloudFormation events ==="

aws --no-cli-pager --endpoint-url="$ENDPOINT_URL" cloudformation describe-stack-events \
  --stack-name "$STACK_NAME" \
  --query "StackEvents[?contains(ResourceStatus, 'FAILED')].[LogicalResourceId,ResourceType,ResourceStatus,ResourceStatusReason]" \
  --output table 2>/dev/null || true

echo ""
echo "=== Stack status ==="

aws --no-cli-pager --endpoint-url="$ENDPOINT_URL" cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].[StackName,StackStatus]" \
  --output table 2>/dev/null || true

echo ""
echo "=== Load balancer DNS ==="

aws --no-cli-pager --endpoint-url="$ENDPOINT_URL" elbv2 describe-load-balancers \
  --query "LoadBalancers[0].DNSName" \
  --output text 2>/dev/null || true

exit $DEPLOY_EXIT_CODE