# Azure Agentic AI Platform - User Guide

## Table of Contents
1. [Overview](#overview)
2. [Capabilities](#capabilities)
3. [Features](#features)
4. [Getting Started](#getting-started)
5. [Configuration](#configuration)
6. [Usage Examples](#usage-examples)
7. [Tool Reference](#tool-reference)
8. [Troubleshooting](#troubleshooting)

---

## Overview

The Azure Agentic AI Platform is a **model-driven, AI-powered orchestration system** for managing Azure cloud infrastructure. It combines:
- **TOSCA (Topology and Orchestration Specification)** for declarative modeling
- **MCP (Model Context Protocol)** for tool orchestration
- **PowerShell** for Azure resource operations
- **Terraform** for infrastructure provisioning
- **AI-driven natural language interface** for user interaction

---

## Capabilities

### 1. Virtual Machine Management
- **Start/Stop/Restart** Azure VMs
- Health monitoring and diagnostics
- Automated recovery actions

### 2. App Service Operations
- **Scale** App Service Plans (Tier, Size, Instance Count)
- Performance monitoring
- Cost optimization

### 3. Infrastructure Provisioning
- **Deploy** VMs, VNets, Subnets, and Databases using Terraform
- **Modular architecture** (Network, Compute, Database modules)
- **Plan before Apply** safety controls

### 4. Monitoring & Observability
- **Retrieve Azure Monitor metrics** (CPU, Memory, Disk, Network)
- **Query Activity Logs** for audit trails
- Real-time diagnostics

### 5. AI-Driven Orchestration
- **Natural language commands** (e.g., "Start the operations VM")
- Intent recognition and routing
- Automated decision-making

---

## Features

### Model-Driven Architecture (TOSCA)
Define your infrastructure as nodes with lifecycle operations:
```yaml
node_templates:
  MyOperationsVM:
    type: azure.nodes.VirtualMachine
    properties:
      resourceGroup: "agentic-ai-rg"
      vmName: "ops-vm-01"
```

### Centralized Configuration
All settings managed in `config/platform_config.json`:
```json
{
  "azure": {
    "subscription_id": "your-sub-id",
    "resource_group": "agentic-ai-rg",
    "location": "East US"
  }
}
```

### Structured JSON Responses
All tools return machine-readable JSON:
```json
{
  "status": "success",
  "message": "VM 'ops-vm-01' started successfully.",
  "timestamp": "2026-02-10T14:30:00Z"
}
```

### Audit Logging
Every operation is logged to `logs/audit.log`:
```json
{
  "timestamp": "2026-02-10T14:30:00Z",
  "node": "MyOperationsVM",
  "operation": "start",
  "status": "SUCCESS"
}
```

---

## Getting Started

### Prerequisites
1. **Azure CLI** - `az login`
2. **PowerShell 7+** with Az Module - `Install-Module -Name Az`
3. **Terraform CLI** - `terraform --version`
4. **Python 3.8+** with PyYAML - `pip install pyyaml`

### Installation
```bash
cd d:\SAGA\azure-agent-platform
python -m pip install pyyaml
```

### Configuration
1. **Edit Azure Settings**:
   ```bash
   notepad config/platform_config.json
   ```
   Update `subscription_id`, `resource_group`, and `location`.

2. **Configure Terraform Variables**:
   ```bash
   notepad tools/terraform/terraform.tfvars
   ```
   Update `resource_group_name`, `location`, and `ssh_public_key_path`.

3. **Authenticate to Azure**:
   ```powershell
   Connect-AzAccount
   ```

### Launch the Interactive Agent
```bash
python interactive_agent_cli.py
```

---

## Configuration

### Platform Configuration (`config/platform_config.json`)
| Property | Description | Example |
|----------|-------------|---------|
| `azure.subscription_id` | Azure subscription GUID | `"00000000-0000-0000-0000-000000000000"` |
| `azure.resource_group` | Target resource group | `"agentic-ai-rg"` |
| `azure.location` | Azure region | `"East US"` |
| `network.vnet_cidr` | Virtual network CIDR | `["10.0.0.0/16"]` |
| `network.subnet_cidr` | Subnet CIDR | `["10.0.2.0/24"]` |
| `defaults.vm_size` | Default VM SKU | `"Standard_DS1_v2"` |

### TOSCA Model (`modeling/service_template.yaml`)
Define your infrastructure topology:
```yaml
node_templates:
  MyProdApp:
    type: azure.nodes.AppService
    properties:
      resourceGroup: "agentic-ai-rg"
      appName: "prod-cloud-app-01"
```

### MCP Tools (`mcp-server/tools.json`)
Tool registry with command templates:
```json
{
  "name": "start_vm",
  "description": "Start Azure Virtual Machine",
  "parameters": ["resourceGroup", "vmName"],
  "command": "powershell ./tools/powershell/vm-start.ps1 ..."
}
```

---

## Usage Examples

### Example 1: Start a VM via Natural Language
```
User: > Start the operations VM
🧠 AI: Mapped intent 'start' on 'operations' -> TOSCA Node 'MyOperationsVM'
⚡ Executing Component: tosca_execute_node_op...
✅ Success:
{
  "status": "success",
  "message": "VM 'ops-vm-01' started successfully."
}
```

### Example 2: Check CPU Metrics
```
User: > Check CPU for the ops vm
🧠 AI: Mapped intent 'Metric Check' -> Azure Monitor: Percentage CPU
⚡ Executing Component: get_metric...
✅ Success:
{
  "status": "success",
  "metric": "Percentage CPU",
  "value": 45.2,
  "unit": "Percent",
  "timestamp": "2026-02-10T14:30:00Z"
}
```

### Example 3: Scale an App Service
Using direct tool invocation:
```powershell
pwsh ./tools/powershell/app-scale.ps1 `
  -resourceGroup "agentic-ai-rg" `
  -appName "prod-cloud-app-01" `
  -newTier "Standard" `
  -newSize "S2" `
  -instanceCount 3
```

### Example 4: Deploy Infrastructure with Terraform
```bash
cd tools/terraform
terraform init
terraform plan
terraform apply
```

---

## Tool Reference

### VM Management Tools
| Tool | Parameters | Description |
|------|-----------|-------------|
| `start_vm` | `resourceGroup`, `vmName` | Start a stopped VM |
| `stop_vm` | `resourceGroup`, `vmName` | Stop a running VM |
| `restart_vm` | `resourceGroup`, `vmName` | Restart a VM |

### App Service Tools
| Tool | Parameters | Description |
|------|-----------|-------------|
| `scale_app` | `resourceGroup`, `appName`, `newTier`, `newSize`, `instanceCount` | Scale App Service Plan |

### Monitoring Tools
| Tool | Parameters | Description |
|------|-----------|-------------|
| `get_metric` | `resourceId`, `metricName`, `aggregation`, `timeRangeHours` | Retrieve Azure Monitor metrics |
| `get_activity_logs` | `resourceGroup`, `maxRecords` | Get Activity Logs |

### Infrastructure Tools
| Tool | Parameters | Description |
|------|-----------|-------------|
| `terraform_plan` | `workingDir` | Preview infrastructure changes |
| `terraform_apply` | `workingDir` | Apply infrastructure changes |

### TOSCA Orchestration
| Tool | Parameters | Description |
|------|-----------|-------------|
| `tosca_execute_node_op` | `node_name`, `operation` | Execute TOSCA lifecycle operation |

---

## Troubleshooting

### Issue: "Could not find config/platform_config.json"
**Solution**: Create the file with default values:
```json
{
  "azure": {
    "subscription_id": "00000000-0000-0000-0000-000000000000",
    "resource_group": "agentic-ai-rg",
    "location": "East US"
  }
}
```

### Issue: PowerShell scripts return errors
**Solution**: Ensure you're authenticated:
```powershell
Connect-AzAccount
Set-AzContext -Subscription "your-subscription-id"
```

### Issue: Terraform commands fail
**Solution**: Initialize Terraform first:
```bash
cd tools/terraform
terraform init
```

### Issue: "Operation not defined for node"
**Solution**: Check that the operation exists in `modeling/service_template.yaml`:
```yaml
interfaces:
  Standard:
    start:
      implementation: ../tools/powershell/vm-start.ps1
```

### Issue: AI doesn't understand my command
**Solution**: Use clearer phrasing or check supported patterns:
- "Start the operations VM"
- "Restart MyOperationsVM"
- "Check CPU for ops vm"
- Type `help` for examples

---

## Security Best Practices

1. **Never commit secrets** - Use Azure Key Vault (Phase 6 feature - pending)
2. **Use Managed Identity** - Assign RBAC roles to the executing identity
3. **Review Terraform Plans** - Always run `terraform plan` before `apply`
4. **Monitor Audit Logs** - Check `logs/audit.log` regularly
5. **Restrict Network Access** - Use VNet integration and NSGs

---

## Advanced Configuration

### Adding a New TOSCA Node
1. Define the node type in `modeling/service_template.yaml`
2. Create PowerShell/Terraform implementation in `tools/`
3. Register in `mcp-server/tools.json` (if new tool needed)
4. Test with the interactive CLI

### Custom Terraform Modules
Create new modules in `tools/terraform/modules/`:
```hcl
module "my_module" {
  source = "./modules/my_module"
  ...
}
```

### Extending the AI Router
Edit `interactive_agent_cli.py` -> `nlp_router()`:
```python
if "deploy" in user_input:
    return "terraform_apply", {"workingDir": "./tools/terraform"}
```

---

## Support & Resources

- **Documentation**: See `README.md` and `TOSCA_ARCHITECTURE.md`
- **Logs**: Check `logs/audit.log` for operation history
- **GitHub**: https://github.com/dparitosh/SAGA
- **Azure Docs**: https://docs.microsoft.com/azure

---

**Version**: 1.0.0  
**Last Updated**: February 10, 2026
