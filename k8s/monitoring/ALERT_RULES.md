# Monitoring Alert Rules Configuration

## Critical Alerts

### Application Health
- ServiceDown: Triggers when application is unreachable for >2 minutes
- HighErrorRate: Triggers when 5xx errors exceed 5% of total requests
- DatabaseConnectionFailure: Triggers on DB connection pool exhaustion

### Infrastructure
- NodeCPUHigh: CPU usage >85% for 5 minutes
- NodeMemoryHigh: Memory usage >90% for 5 minutes
- DiskSpaceLow: Available disk space <15%

### Performance
- ResponseTimeSlow: P95 response time >1 second for 10 minutes
- RequestRateHigh: Request rate >1000 req/s sustained

## Warning Alerts

### Application
- ModerateErrorRate: 4xx errors >10% of requests
- SlowQueries: Database query time >500ms average

### Infrastructure
- PodRestartFrequent: Pod restarts >5 in past hour
- MemoryLeakSuspected: Memory usage increasing >10% per hour

## Alert Actions
1. Send to Slack #alerts channel
2. Create PagerDuty incident for critical alerts
3. Email on-call engineer
4. Log to monitoring dashboard
