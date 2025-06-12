# PowerShell script to clean up AWS resources

# Set your VPC ID
$VPC_ID = "vpc-0379120c66b090c2f"

# Find and delete all ELBs in the VPC
Write-Host "Finding and deleting ELBs..." -ForegroundColor Yellow
$elbs = aws elb describe-load-balancers --query "LoadBalancerDescriptions[?VPCId=='$VPC_ID'].LoadBalancerName" --output text
if ($elbs) {
    $elbs -split "\s+" | ForEach-Object {
        if ($_) {
            Write-Host "Deleting ELB: $_" -ForegroundColor Cyan
            aws elb delete-load-balancer --load-balancer-name $_
        }
    }
}

# Find and delete all ALBs/NLBs in the VPC
Write-Host "Finding and deleting ALBs/NLBs..." -ForegroundColor Yellow
$albs = aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text
if ($albs) {
    $albs -split "\s+" | ForEach-Object {
        if ($_) {
            Write-Host "Deleting ALB/NLB: $_" -ForegroundColor Cyan
            aws elbv2 delete-load-balancer --load-balancer-arn $_
        }
    }
}

# Find and release all Elastic IPs in the VPC
Write-Host "Finding and releasing Elastic IPs..." -ForegroundColor Yellow
$eips = aws ec2 describe-addresses --query "Addresses[?Domain=='vpc'].AllocationId" --output text
if ($eips) {
    $eips -split "\s+" | ForEach-Object {
        if ($_) {
            Write-Host "Releasing Elastic IP: $_" -ForegroundColor Cyan
            aws ec2 release-address --allocation-id $_
        }
    }
}

# Find and delete NAT Gateways
Write-Host "Finding and deleting NAT Gateways..." -ForegroundColor Yellow
$nats = aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[?State!='deleted'].NatGatewayId" --output text
if ($nats) {
    $nats -split "\s+" | ForEach-Object {
        if ($_) {
            Write-Host "Deleting NAT Gateway: $_" -ForegroundColor Cyan
            aws ec2 delete-nat-gateway --nat-gateway-id $_
        }
    }
}

Write-Host "Waiting for NAT Gateways to be deleted..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Now try terraform destroy
Write-Host "Running terraform destroy..." -ForegroundColor Green
terraform destroy -lock=false -auto-approve