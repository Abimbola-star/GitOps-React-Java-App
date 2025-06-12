#!/bin/bash

# Set your VPC ID
VPC_ID="vpc-0379120c66b090c2f"

# Find and delete all ELBs in the VPC
echo "Finding and deleting ELBs..."
aws elb describe-load-balancers --query "LoadBalancerDescriptions[?VPCId=='$VPC_ID'].LoadBalancerName" --output text | while read -r lb; do
  if [ ! -z "$lb" ]; then
    echo "Deleting ELB: $lb"
    aws elb delete-load-balancer --load-balancer-name "$lb"
  fi
done

# Find and delete all ALBs/NLBs in the VPC
echo "Finding and deleting ALBs/NLBs..."
aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text | while read -r lb; do
  if [ ! -z "$lb" ]; then
    echo "Deleting ALB/NLB: $lb"
    aws elbv2 delete-load-balancer --load-balancer-arn "$lb"
  fi
done

# Find and release all Elastic IPs in the VPC
echo "Finding and releasing Elastic IPs..."
aws ec2 describe-addresses --query "Addresses[?Domain=='vpc'].AllocationId" --output text | while read -r eip; do
  if [ ! -z "$eip" ]; then
    echo "Releasing Elastic IP: $eip"
    aws ec2 release-address --allocation-id "$eip"
  fi
done

# Find and delete NAT Gateways
echo "Finding and deleting NAT Gateways..."
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[?State!='deleted'].NatGatewayId" --output text | while read -r nat; do
  if [ ! -z "$nat" ]; then
    echo "Deleting NAT Gateway: $nat"
    aws ec2 delete-nat-gateway --nat-gateway-id "$nat"
  fi
done

echo "Waiting for NAT Gateways to be deleted..."
sleep 30

# Now try terraform destroy
echo "Running terraform destroy..."
terraform destroy -lock=false -auto-approve