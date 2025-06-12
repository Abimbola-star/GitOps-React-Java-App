# PowerShell script to destroy AWS resources in the correct order

# First, remove any load balancers created by Kubernetes
Write-Host "Removing Kubernetes load balancers..." -ForegroundColor Yellow
aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text | ForEach-Object {
    Write-Host "Deleting load balancer: $_" -ForegroundColor Cyan
    aws elb delete-load-balancer --load-balancer-name $_
}

# Delete any NLBs/ALBs created by Kubernetes
Write-Host "Removing Network/Application load balancers..." -ForegroundColor Yellow
aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text | ForEach-Object {
    if ($_) {
        Write-Host "Deleting load balancer: $_" -ForegroundColor Cyan
        aws elbv2 delete-load-balancer --load-balancer-arn $_
    }
}

# Wait a bit for resources to be deleted
Write-Host "Waiting for load balancers to be deleted..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Now try terraform destroy with lock=false
Write-Host "Running terraform destroy..." -ForegroundColor Green
terraform destroy -lock=false -auto-approve