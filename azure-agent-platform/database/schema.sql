-- Azure Agentic AI Platform - Database Schema
-- PostgreSQL 13+
-- Description: Schema for storing platform operations, audit trails, and state management

-- ============================================================================
-- SCHEMA CREATION
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS agentic_ai;

SET search_path TO agentic_ai, public;

-- ============================================================================
-- TABLE: resources
-- Description: Catalog of all managed Azure resources
-- ============================================================================

CREATE TABLE IF NOT EXISTS resources (
    resource_id SERIAL PRIMARY KEY,
    resource_type VARCHAR(50) NOT NULL CHECK (resource_type IN ('VirtualMachine', 'AppService', 'Database', 'Network', 'Storage')),
    azure_resource_id VARCHAR(500) UNIQUE NOT NULL,
    resource_name VARCHAR(255) NOT NULL,
    resource_group VARCHAR(255) NOT NULL,
    location VARCHAR(50) NOT NULL,
    subscription_id UUID NOT NULL,
    tags JSONB DEFAULT '{}',
    state VARCHAR(20) DEFAULT 'Unknown' CHECK (state IN ('Running', 'Stopped', 'Deallocated', 'Creating', 'Deleting', 'Unknown')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_resource_name_rg UNIQUE(resource_name, resource_group)
);

CREATE INDEX idx_resources_type ON resources(resource_type);
CREATE INDEX idx_resources_rg ON resources(resource_group);
CREATE INDEX idx_resources_state ON resources(state);
CREATE INDEX idx_resources_azure_id ON resources(azure_resource_id);

-- ============================================================================
-- TABLE: operations_log
-- Description: Audit trail of all operations performed by the platform
-- ============================================================================

CREATE TABLE IF NOT EXISTS operations_log (
    operation_id SERIAL PRIMARY KEY,
    resource_id INTEGER REFERENCES resources(resource_id) ON DELETE SET NULL,
    operation_type VARCHAR(50) NOT NULL CHECK (operation_type IN ('start', 'stop', 'restart', 'scale', 'create', 'delete', 'configure')),
    operation_status VARCHAR(20) NOT NULL CHECK (operation_status IN ('STARTED', 'SUCCESS', 'FAILED', 'PENDING')),
    initiated_by VARCHAR(100) DEFAULT 'system',
    command_executed TEXT,
    result_message TEXT,
    error_details TEXT,
    execution_time_ms INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_operations_resource ON operations_log(resource_id);
CREATE INDEX idx_operations_status ON operations_log(operation_status);
CREATE INDEX idx_operations_timestamp ON operations_log(timestamp DESC);
CREATE INDEX idx_operations_type ON operations_log(operation_type);

-- ============================================================================
-- TABLE: metrics_snapshot
-- Description: Periodic snapshots of resource metrics
-- ============================================================================

CREATE TABLE IF NOT EXISTS metrics_snapshot (
    snapshot_id SERIAL PRIMARY KEY,
    resource_id INTEGER REFERENCES resources(resource_id) ON DELETE CASCADE,
    metric_name VARCHAR(100) NOT NULL,
    metric_value NUMERIC(12, 4),
    unit VARCHAR(20),
    aggregation_type VARCHAR(20) DEFAULT 'Average',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_metrics_resource ON metrics_snapshot(resource_id);
CREATE INDEX idx_metrics_timestamp ON metrics_snapshot(timestamp DESC);
CREATE INDEX idx_metrics_name ON metrics_snapshot(metric_name);

-- ============================================================================
-- TABLE: tosca_nodes
-- Description: Mapping of TOSCA model nodes to actual Azure resources
-- ============================================================================

CREATE TABLE IF NOT EXISTS tosca_nodes (
    node_id SERIAL PRIMARY KEY,
    node_name VARCHAR(255) UNIQUE NOT NULL,
    node_type VARCHAR(100) NOT NULL,
    resource_id INTEGER REFERENCES resources(resource_id) ON DELETE SET NULL,
    properties JSONB DEFAULT '{}',
    state VARCHAR(20) DEFAULT 'Active' CHECK (state IN ('Active', 'Inactive', 'Pending', 'Error')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tosca_name ON tosca_nodes(node_name);
CREATE INDEX idx_tosca_type ON tosca_nodes(node_type);

-- ============================================================================
-- TABLE: configuration_history
-- Description: Track changes to platform configuration
-- ============================================================================

CREATE TABLE IF NOT EXISTS configuration_history (
    config_id SERIAL PRIMARY KEY,
    config_key VARCHAR(255) NOT NULL,
    config_value TEXT NOT NULL,
    changed_by VARCHAR(100) DEFAULT 'system',
    change_reason TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_config_key ON configuration_history(config_key);
CREATE INDEX idx_config_timestamp ON configuration_history(timestamp DESC);

-- ============================================================================
-- TABLE: self_healing_rules
-- Description: Define automated remediation actions
-- ============================================================================

CREATE TABLE IF NOT EXISTS self_healing_rules (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(255) UNIQUE NOT NULL,
    condition_metric VARCHAR(100) NOT NULL,
    condition_operator VARCHAR(10) CHECK (condition_operator IN ('>', '<', '>=', '<=', '==', '!=')),
    condition_threshold NUMERIC(12, 4),
    action_type VARCHAR(50) NOT NULL,
    action_parameters JSONB DEFAULT '{}',
    enabled BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1,
    cooldown_minutes INTEGER DEFAULT 5,
    last_triggered TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_healing_enabled ON self_healing_rules(enabled);
CREATE INDEX idx_healing_metric ON self_healing_rules(condition_metric);

-- ============================================================================
-- TABLE: agent_sessions
-- Description: Track interactive AI agent sessions
-- ============================================================================

CREATE TABLE IF NOT EXISTS agent_sessions (
    session_id SERIAL PRIMARY KEY,
    session_uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    user_identifier VARCHAR(255),
    session_start TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    session_end TIMESTAMP WITH TIME ZONE,
    total_commands INTEGER DEFAULT 0,
    successful_commands INTEGER DEFAULT 0,
    failed_commands INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Error'))
);

CREATE INDEX idx_sessions_uuid ON agent_sessions(session_uuid);
CREATE INDEX idx_sessions_status ON agent_sessions(status);

-- ============================================================================
-- TABLE: agent_commands
-- Description: Log all commands executed in agent sessions
-- ============================================================================

CREATE TABLE IF NOT EXISTS agent_commands (
    command_id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES agent_sessions(session_id) ON DELETE CASCADE,
    user_input TEXT NOT NULL,
    interpreted_intent VARCHAR(255),
    tool_invoked VARCHAR(100),
    parameters_used JSONB,
    result_status VARCHAR(20),
    result_output TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_commands_session ON agent_commands(session_id);
CREATE INDEX idx_commands_timestamp ON agent_commands(timestamp DESC);
CREATE INDEX idx_commands_tool ON agent_commands(tool_invoked);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Active resources summary
CREATE OR REPLACE VIEW v_active_resources AS
SELECT 
    resource_type,
    COUNT(*) as total_count,
    COUNT(*) FILTER (WHERE state = 'Running') as running_count,
    COUNT(*) FILTER (WHERE state = 'Stopped') as stopped_count
FROM resources
GROUP BY resource_type;

-- Recent operations summary
CREATE OR REPLACE VIEW v_recent_operations AS
SELECT 
    o.operation_id,
    r.resource_name,
    r.resource_type,
    o.operation_type,
    o.operation_status,
    o.timestamp,
    o.execution_time_ms
FROM operations_log o
LEFT JOIN resources r ON o.resource_id = r.resource_id
ORDER BY o.timestamp DESC
LIMIT 100;

-- Latest metrics per resource
CREATE OR REPLACE VIEW v_latest_metrics AS
SELECT DISTINCT ON (resource_id, metric_name)
    m.resource_id,
    r.resource_name,
    m.metric_name,
    m.metric_value,
    m.unit,
    m.timestamp
FROM metrics_snapshot m
JOIN resources r ON m.resource_id = r.resource_id
ORDER BY resource_id, metric_name, timestamp DESC;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON resources
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tosca_nodes_updated_at BEFORE UPDATE ON tosca_nodes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON SCHEMA agentic_ai IS 'Schema for Azure Agentic AI Platform data persistence';
COMMENT ON TABLE resources IS 'Central registry of all managed Azure resources';
COMMENT ON TABLE operations_log IS 'Comprehensive audit trail of platform operations';
COMMENT ON TABLE metrics_snapshot IS 'Time-series storage for resource metrics';
COMMENT ON TABLE tosca_nodes IS 'TOSCA model to Azure resource mapping';
COMMENT ON TABLE self_healing_rules IS 'Automated remediation configuration';
COMMENT ON TABLE agent_sessions IS 'Interactive AI agent session tracking';
COMMENT ON TABLE agent_commands IS 'Detailed log of agent command execution';
