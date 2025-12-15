# Monitoring Metrics Guide

## Application Metrics

### Request Metrics
- `http_requests_total` - Total HTTP requests received
  - Labels: method, status_code, endpoint
  - Type: Counter
- `http_request_duration_seconds` - Request duration histogram
  - Labels: method, endpoint
  - Type: Histogram

### Database Metrics
- `db_connections_active` - Active database connections
- `db_query_duration_seconds` - Query execution time

## Infrastructure Metrics

### Node Metrics
- `node_cpu_usage` - CPU utilization
- `node_memory_usage` - Memory consumption
- `node_disk_usage` - Disk space utilization

### Pod Metrics
- `pod_restart_count` - Container restart count
- `pod_memory_usage` - Pod memory usage
- `pod_cpu_usage` - Pod CPU usage
