-- Azure Agentic AI Platform - Seed Data
-- PostgreSQL 13+
-- Description: Sample data for development and testing
-- ⚠️  WARNING: Replace all placeholder UUIDs (00000000-...) with your actual Azure subscription ID before use

SET search_path TO agentic_ai, public;

-- ============================================================================
-- SEED DATA: resources
-- ============================================================================

INSERT INTO resources (resource_type, azure_resource_id, resource_name, resource_group, location, subscription_id, tags, state) VALUES
('VirtualMachine', '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/agentic-ai-rg/providers/Microsoft.Compute/virtualMachines/ops-vm-01', 'ops-vm-01', 'agentic-ai-rg', 'East US', '00000000-0000-0000-0000-000000000000', '{"environment": "production", "managed_by": "agentic-ai"}', 'Running'),
('VirtualMachine', '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/agentic-ai-rg/providers/Microsoft.Compute/virtualMachines/dev-vm-01', 'dev-vm-01', 'agentic-ai-rg', 'East US', '00000000-0000-0000-0000-000000000000', '{"environment": "development", "managed_by": "agentic-ai"}', 'Stopped'),
('AppService', '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/agentic-ai-rg/providers/Microsoft.Web/sites/prod-cloud-app-01', 'prod-cloud-app-01', 'agentic-ai-rg', 'East US', '00000000-0000-0000-0000-000000000000', '{"environment": "production", "tier": "Standard"}', 'Running'),
('Database', '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/agentic-ai-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/demo-psql-server', 'demo-psql-server', 'agentic-ai-rg', 'East US', '00000000-0000-0000-0000-000000000000', '{"environment": "production", "database_type": "postgresql"}', 'Running'),
('Network', '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/agentic-ai-rg/providers/Microsoft.Network/virtualNetworks/demo-network', 'demo-network', 'agentic-ai-rg', 'East US', '00000000-0000-0000-0000-000000000000', '{"cidr": "10.0.0.0/16"}', 'Running');

-- ============================================================================
-- SEED DATA: tosca_nodes
-- ============================================================================

INSERT INTO tosca_nodes (node_name, node_type, resource_id, properties, state) VALUES
('MyOperationsVM', 'azure.nodes.VirtualMachine', 1, '{"resourceGroup": "agentic-ai-rg", "vmName": "ops-vm-01", "vmSize": "Standard_DS1_v2"}', 'Active'),
('MyProdApp', 'azure.nodes.AppService', 3, '{"resourceGroup": "agentic-ai-rg", "appName": "prod-cloud-app-01", "tier": "Standard", "size": "S1"}', 'Active');

-- ============================================================================
-- SEED DATA: operations_log
-- ============================================================================

INSERT INTO operations_log (resource_id, operation_type, operation_status, initiated_by, command_executed, result_message, execution_time_ms, timestamp) VALUES
(1, 'start', 'SUCCESS', 'system', 'pwsh ./tools/powershell/vm-start.ps1 -resourceGroup "agentic-ai-rg" -vmName "ops-vm-01"', 'VM started successfully', 2340, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(1, 'restart', 'SUCCESS', 'admin@example.com', 'pwsh ./tools/powershell/vm-restart.ps1 -resourceGroup "agentic-ai-rg" -vmName "ops-vm-01"', 'VM restarted successfully', 3120, CURRENT_TIMESTAMP - INTERVAL '1 hour'),
(3, 'scale', 'SUCCESS', 'system', 'pwsh ./tools/powershell/app-scale.ps1 -resourceGroup "agentic-ai-rg" -appName "prod-cloud-app-01" -newTier "Standard" -newSize "S2" -instanceCount 3', 'App scaled to Standard S2 (3 instances)', 4560, CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
(2, 'stop', 'SUCCESS', 'system', 'pwsh ./tools/powershell/vm-stop.ps1 -resourceGroup "agentic-ai-rg" -vmName "dev-vm-01"', 'VM stopped successfully', 1890, CURRENT_TIMESTAMP - INTERVAL '10 minutes'),
(1, 'start', 'FAILED', 'system', 'pwsh ./tools/powershell/vm-start.ps1 -resourceGroup "agentic-ai-rg" -vmName "ops-vm-01"', 'VM already running', 150, CURRENT_TIMESTAMP - INTERVAL '5 minutes');

-- ============================================================================
-- SEED DATA: metrics_snapshot
-- ============================================================================

-- CPU Metrics
INSERT INTO metrics_snapshot (resource_id, metric_name, metric_value, unit, aggregation_type, timestamp) VALUES
(1, 'Percentage CPU', 45.2, 'Percent', 'Average', CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
(1, 'Percentage CPU', 52.8, 'Percent', 'Average', CURRENT_TIMESTAMP - INTERVAL '10 minutes'),
(1, 'Percentage CPU', 38.4, 'Percent', 'Average', CURRENT_TIMESTAMP - INTERVAL '15 minutes'),
(2, 'Percentage CPU', 0.0, 'Percent', 'Average', CURRENT_TIMESTAMP - INTERVAL '5 minutes');

-- Memory Metrics
INSERT INTO metrics_snapshot (resource_id, metric_name, metric_value, unit, aggregation_type, timestamp) VALUES
(1, 'Available Memory Bytes', 3221225472, 'Bytes', 'Average', CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
(1, 'Available Memory Bytes', 3087007744, 'Bytes', 'Average', CURRENT_TIMESTAMP - INTERVAL '10 minutes'),
(3, 'Memory Percentage', 68.5, 'Percent', 'Average', CURRENT_TIMESTAMP - INTERVAL '5 minutes');

-- Network Metrics
INSERT INTO metrics_snapshot (resource_id, metric_name, metric_value, unit, aggregation_type, timestamp) VALUES
(1, 'Network In Total', 524288000, 'Bytes', 'Total', CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
(1, 'Network Out Total', 262144000, 'Bytes', 'Total', CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
(3, 'Http5xx', 2, 'Count', 'Total', CURRENT_TIMESTAMP - INTERVAL '5 minutes');

-- ============================================================================
-- SEED DATA: self_healing_rules
-- ============================================================================

INSERT INTO self_healing_rules (rule_name, condition_metric, condition_operator, condition_threshold, action_type, action_parameters, enabled, priority, cooldown_minutes) VALUES
('High CPU - Scale App', 'Percentage CPU', '>', 80.0, 'scale', '{"tier": "Standard", "size": "S2", "instanceCount": 3}', TRUE, 1, 10),
('VM Crash - Restart', 'VM Health Status', '==', 0, 'restart', '{}', TRUE, 2, 5),
('Memory Leak - Restart Service', 'Memory Percentage', '>', 90.0, 'restart', '{}', TRUE, 3, 15),
('Cost Spike - Schedule Shutdown', 'Daily Cost', '>', 100.0, 'stop', '{"scheduleTime": "18:00"}', FALSE, 4, 60);

-- ============================================================================
-- SEED DATA: configuration_history
-- ============================================================================

INSERT INTO configuration_history (config_key, config_value, changed_by, change_reason, timestamp) VALUES
('azure.subscription_id', '00000000-0000-0000-0000-000000000000', 'admin@example.com', 'Initial configuration', CURRENT_TIMESTAMP - INTERVAL '7 days'),
('azure.resource_group', 'agentic-ai-rg', 'admin@example.com', 'Initial configuration', CURRENT_TIMESTAMP - INTERVAL '7 days'),
('azure.location', 'East US', 'admin@example.com', 'Initial configuration', CURRENT_TIMESTAMP - INTERVAL '7 days'),
('network.vnet_cidr', '["10.0.0.0/16"]', 'system', 'Default network configuration', CURRENT_TIMESTAMP - INTERVAL '6 days'),
('defaults.vm_size', 'Standard_DS1_v2', 'system', 'Default VM size for cost optimization', CURRENT_TIMESTAMP - INTERVAL '6 days');

-- ============================================================================
-- SEED DATA: agent_sessions
-- ============================================================================

INSERT INTO agent_sessions (session_uuid, user_identifier, session_start, session_end, total_commands, successful_commands, failed_commands, status) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'admin@example.com', CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour 30 minutes', 5, 4, 1, 'Completed'),
('650e8400-e29b-41d4-a716-446655440001', 'operator@example.com', CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL, 3, 3, 0, 'Active');

-- ============================================================================
-- SEED DATA: agent_commands
-- ============================================================================

INSERT INTO agent_commands (session_id, user_input, interpreted_intent, tool_invoked, parameters_used, result_status, result_output, timestamp) VALUES
(1, 'Start the operations VM', 'start_vm', 'tosca_execute_node_op', '{"node_name": "MyOperationsVM", "operation": "start"}', 'success', '{"status": "success", "message": "VM started successfully"}', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(1, 'Check CPU for ops vm', 'get_metrics', 'get_metric', '{"resourceId": "/subscriptions/.../ops-vm-01", "metricName": "Percentage CPU"}', 'success', '{"status": "success", "value": 45.2}', CURRENT_TIMESTAMP - INTERVAL '1 hour 50 minutes'),
(1, 'Scale the production app to S2', 'scale_app', 'scale_app', '{"resourceGroup": "agentic-ai-rg", "appName": "prod-cloud-app-01", "newSize": "S2"}', 'success', '{"status": "success", "message": "App scaled successfully"}', CURRENT_TIMESTAMP - INTERVAL '1 hour 45 minutes'),
(1, 'Restart MyOperationsVM', 'restart_vm', 'tosca_execute_node_op', '{"node_name": "MyOperationsVM", "operation": "restart"}', 'success', '{"status": "success", "message": "VM restarted"}', CURRENT_TIMESTAMP - INTERVAL '1 hour 40 minutes'),
(1, 'Deploy new infrastructure', 'terraform_apply', 'terraform_apply', '{"workingDir": "./tools/terraform"}', 'error', '{"status": "error", "message": "Terraform not initialized"}', CURRENT_TIMESTAMP - INTERVAL '1 hour 35 minutes'),
(2, 'Show activity logs', 'get_logs', 'get_activity_logs', '{"resourceGroup": "agentic-ai-rg", "maxRecords": 10}', 'success', '{"status": "success", "logs": [...]}', CURRENT_TIMESTAMP - INTERVAL '25 minutes'),
(2, 'Check CPU metrics', 'get_metrics', 'get_metric', '{"metricName": "Percentage CPU"}', 'success', '{"status": "success", "value": 52.8}', CURRENT_TIMESTAMP - INTERVAL '20 minutes'),
(2, 'Stop dev vm', 'stop_vm', 'tosca_execute_node_op', '{"node_name": "dev-vm-01", "operation": "stop"}', 'success', '{"status": "success", "message": "VM stopped"}', CURRENT_TIMESTAMP - INTERVAL '15 minutes');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify data insertion
DO $$
DECLARE
    resource_count INTEGER;
    operation_count INTEGER;
    metric_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO resource_count FROM resources;
    SELECT COUNT(*) INTO operation_count FROM operations_log;
    SELECT COUNT(*) INTO metric_count FROM metrics_snapshot;
    
    RAISE NOTICE 'Seed data loaded successfully:';
    RAISE NOTICE '  Resources: %', resource_count;
    RAISE NOTICE '  Operations: %', operation_count;
    RAISE NOTICE '  Metrics: %', metric_count;
END $$;

-- Display summary
SELECT 'Active Resources' as summary_type, resource_type, COUNT(*) as count 
FROM resources 
GROUP BY resource_type
UNION ALL
SELECT 'Recent Operations', operation_type, COUNT(*) 
FROM operations_log 
GROUP BY operation_type
ORDER BY summary_type, count DESC;
