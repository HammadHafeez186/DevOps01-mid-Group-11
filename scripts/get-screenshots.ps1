# Screenshot Commands for Exam Submission
# Run these commands and capture screenshots

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TERRAFORM SCREENSHOTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "1. Terraform Output:" -ForegroundColor Yellow
Write-Host "   cd infra" -ForegroundColor Green
Write-Host "   terraform output" -ForegroundColor Green
Write-Host "`n2. AWS Console Screenshots Needed:" -ForegroundColor Yellow
Write-Host "   - VPC Dashboard" -ForegroundColor White
Write-Host "   - EKS Cluster" -ForegroundColor White
Write-Host "   - RDS Instance" -ForegroundColor White
Write-Host "   - EC2 Instances" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ANSIBLE SCREENSHOTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "3. Run Ansible Playbook:" -ForegroundColor Yellow
Write-Host "   cd ansible" -ForegroundColor Green
Write-Host "   ansible-playbook playbook.yaml -v" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "KUBERNETES SCREENSHOTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "4. Get all resources:" -ForegroundColor Yellow
kubectl get all -n devops-articles

Write-Host "`n5. Get pods:" -ForegroundColor Yellow
kubectl get pods -n devops-articles -o wide

Write-Host "`n6. Get services:" -ForegroundColor Yellow
kubectl get svc -n devops-articles

Write-Host "`n7. Describe a pod (copy pod name from above):" -ForegroundColor Yellow
$pods = kubectl get pods -n devops-articles -o jsonpath='{.items[0].metadata.name}'
kubectl describe pod $pods -n devops-articles

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "MONITORING SCREENSHOTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "8. Get monitoring services:" -ForegroundColor Yellow
kubectl get svc -n monitoring

$prometheusUrl = kubectl get svc prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
$grafanaUrl = kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

Write-Host "`n9. Prometheus URL:" -ForegroundColor Yellow
Write-Host "   http://$prometheusUrl:9090" -ForegroundColor Green
Write-Host "   Navigate to /targets to see all monitored endpoints" -ForegroundColor White

Write-Host "`n10. Grafana URL:" -ForegroundColor Yellow
Write-Host "   http://$grafanaUrl:3000" -ForegroundColor Green
Write-Host "   Login: admin / admin123" -ForegroundColor White
Write-Host "   Import dashboard IDs: 7249, 6417, 1860" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CI/CD SCREENSHOTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "11. GitHub Actions:" -ForegroundColor Yellow
Write-Host "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/actions" -ForegroundColor Green
Write-Host "   Screenshot the latest successful pipeline run" -ForegroundColor White
Write-Host "   Show all stages with green checkmarks" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "APPLICATION VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$appUrl = kubectl get svc app-service -n devops-articles -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
Write-Host "12. Application URL:" -ForegroundColor Yellow
Write-Host "   http://$appUrl" -ForegroundColor Green

Write-Host "`n13. Test application:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$appUrl" -UseBasicParsing -TimeoutSec 10
    Write-Host "   ✅ Application is responding (HTTP $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️ Waiting for LoadBalancer DNS propagation..." -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DOCKER IMAGES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "14. List local Docker images:" -ForegroundColor Yellow
docker images | Select-String "devops-articles"

Write-Host "`n15. ECR images (if logged in):" -ForegroundColor Yellow
Write-Host "   aws ecr list-images --repository-name devops-articles --region us-east-1" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CLEANUP COMMANDS (FOR TERRAFORM DESTROY SCREENSHOT)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "16. Before destroying, take screenshots of all resources!" -ForegroundColor Red
Write-Host "    Then run:" -ForegroundColor Yellow
Write-Host "    cd infra" -ForegroundColor Green
Write-Host "    terraform destroy" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ALL URLS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Application:  http://$appUrl" -ForegroundColor Green
Write-Host "Prometheus:   http://$prometheusUrl:9090" -ForegroundColor Green
Write-Host "Grafana:      http://$grafanaUrl:3000" -ForegroundColor Green
Write-Host "              (admin / admin123)" -ForegroundColor Gray

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ Screenshot checklist complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
