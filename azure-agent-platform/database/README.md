# Database Setup Guide

## Overview
This directory contains the database schema and seed data for the Azure Agentic AI Platform. The database is used for:
- Resource inventory management
- Operation audit trails
- Metrics storage and trend analysis
- TOSCA model persistence
- Self-healing rule configuration
- Agent session tracking

## Database: PostgreSQL 13+

### Quick Start

#### 1. Deploy PostgreSQL using Terraform (Recommended)
```bash
cd ../tools/terraform
# Uncomment the database module in main.tf
terraform init
terraform plan
terraform apply
```

#### 2. Connect to Database
```bash
# Using psql
psql -h <server-fqdn> -U dbadmin -d postgres

# Or using Azure CLI
az postgres flexible-server connect \
  --name demo-psql-server \
  --admin-user dbadmin \
  --database-name postgres
```

#### 3. Create Schema
```sql
\i schema.sql
```

#### 4. Load Seed Data (Optional - for development)
```sql
\i seed_data.sql
```

### Manual Setup (Local Development)

#### Using Docker
```bash
docker run --name agentic-postgres \
  -e POSTGRES_PASSWORD=YourSecurePassword \
  -e POSTGRES_DB=agentic_ai \
  -p 5432:5432 \
  -d postgres:13
```

#### Apply Schema
```bash
psql -h localhost -U postgres -d agentic_ai -f schema.sql
psql -h localhost -U postgres -d agentic_ai -f seed_data.sql
```

## Schema Overview

### Core Tables

#### `resources`
Central registry of all managed Azure resources.
- **Key Fields**: `azure_resource_id`, `resource_name`, `resource_type`, `state`
- **Use Case**: Inventory management, state tracking

#### `operations_log`
Comprehensive audit trail of all platform operations.
- **Key Fields**: `operation_type`, `operation_status`, `timestamp`, `execution_time_ms`
- **Use Case**: Compliance, debugging, performance analysis

#### `metrics_snapshot`
Time-series storage for Azure Monitor metrics.
- **Key Fields**: `metric_name`, `metric_value`, `timestamp`
- **Use Case**: Trend analysis, alerting, dashboards

#### `tosca_nodes`
Maps TOSCA model definitions to actual Azure resources.
- **Key Fields**: `node_name`, `node_type`, `resource_id`
- **Use Case**: Model-driven orchestration

#### `self_healing_rules`
Configuration for automated remediation actions.
- **Key Fields**: `condition_metric`, `condition_threshold`, `action_type`
- **Use Case**: Automated incident response

#### `agent_sessions` & `agent_commands`
Tracks interactive AI agent usage and command history.
- **Use Case**: User analytics, debugging AI routing

### Views

#### `v_active_resources`
Summary of resources grouped by type and state.

#### `v_recent_operations`
Last 100 operations with execution details.

#### `v_latest_metrics`
Most recent metric value per resource.

## Integration with Platform

### PowerShell Integration
Add database logging to scripts:
```powershell
# Example: Log operation to database
$query = @"
INSERT INTO agentic_ai.operations_log 
(resource_id, operation_type, operation_status, command_executed, result_message)
VALUES (1, 'start', 'SUCCESS', '$($MyInvocation.MyCommand)', 'VM started')
"@

Invoke-SqlCmd -ServerInstance $server -Database agentic_ai -Query $query
```

### Python Integration (TOSCA Processor)
```python
import psycopg2

conn = psycopg2.connect(
    host="demo-psql-server.postgres.database.azure.com",
    database="postgres",
    user="dbadmin",
    password=os.environ['DB_PASSWORD']
)

# Log operation
cursor = conn.cursor()
cursor.execute("""
    INSERT INTO agentic_ai.operations_log 
    (operation_type, operation_status, result_message)
    VALUES (%s, %s, %s)
""", (operation_name, "SUCCESS", result_msg))
conn.commit()
```

## Useful Queries

### View Recent Operations
```sql
SELECT * FROM agentic_ai.v_recent_operations LIMIT 20;
```

### Check Resource Health
```sql
SELECT resource_name, resource_type, state, updated_at
FROM agentic_ai.resources
WHERE state NOT IN ('Running', 'Stopped')
ORDER BY updated_at DESC;
```

### Analyze Operation Success Rate
```sql
SELECT 
    operation_type,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE operation_status = 'SUCCESS') as success,
    ROUND(100.0 * COUNT(*) FILTER (WHERE operation_status = 'SUCCESS') / COUNT(*), 2) as success_rate
FROM agentic_ai.operations_log
WHERE timestamp > NOW() - INTERVAL '7 days'
GROUP BY operation_type;
```

### Latest Metrics Dashboard
```sql
SELECT * FROM agentic_ai.v_latest_metrics
WHERE metric_name IN ('Percentage CPU', 'Memory Percentage')
ORDER BY resource_id;
```

### Agent Usage Statistics
```sql
SELECT 
    user_identifier,
    COUNT(*) as sessions,
    SUM(total_commands) as total_commands,
    SUM(successful_commands) as successful,
    ROUND(100.0 * SUM(successful_commands) / SUM(total_commands), 2) as success_rate
FROM agentic_ai.agent_sessions
GROUP BY user_identifier;
```

## Backup & Maintenance

### Backup Database
```bash
pg_dump -h <server-fqdn> -U dbadmin -d postgres -n agentic_ai > backup.sql
```

### Restore Database
```bash
psql -h <server-fqdn> -U dbadmin -d postgres < backup.sql
```

### Archive Old Data (Recommended Monthly)
```sql
-- Archive operations older than 90 days
CREATE TABLE agentic_ai.operations_log_archive AS
SELECT * FROM agentic_ai.operations_log
WHERE timestamp < NOW() - INTERVAL '90 days';

DELETE FROM agentic_ai.operations_log
WHERE timestamp < NOW() - INTERVAL '90 days';
```

## Security Best Practices

1. **Use Azure Key Vault** for database credentials
2. **Enable connection encryption** (SSL/TLS)
3. **Restrict firewall rules** to specific IPs or VNets
4. **Use Managed Identity** when possible
5. **Regular backups** (Azure automated backups enabled by default)
6. **Monitor audit logs** in Azure Portal

## Troubleshooting

### Connection Issues
```bash
# Test connectivity
telnet demo-psql-server.postgres.database.azure.com 5432

# Check firewall rules
az postgres flexible-server firewall-rule list \
  --resource-group agentic-ai-rg \
  --name demo-psql-server
```

### Performance Tuning
```sql
-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM agentic_ai.operations_log WHERE timestamp > NOW() - INTERVAL '1 day';

-- Identify missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'agentic_ai'
ORDER BY abs(correlation) DESC;
```

## Future Enhancements

- [ ] Implement time-series database (TimescaleDB) for metrics
- [ ] Add GraphQL API layer for querying
- [ ] Implement data retention policies
- [ ] Create Grafana dashboards connected to this database
- [ ] Add ML model storage tables for predictive scaling

---

**Version**: 1.0.0  
**Last Updated**: February 10, 2026
