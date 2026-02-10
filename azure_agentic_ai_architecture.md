# Agentic AI Azure Operations Platform

## Architecture, Tasks, Prompts, MCP + Terraform Extension Guide

------------------------------------------------------------------------

## 1. Solution Overview

This platform enables **AI‑Driven Remote Management and Infrastructure
Provisioning** for:

-   Azure Virtual Machines
-   Azure App Services
-   Infrastructure as Code (Terraform)
-   MCP (Model Context Protocol) Tool Servers
-   Agentic AI Orchestration

Goal: Build **Self‑Healing, Scalable, and Secure Azure Operations &
Deployment Apps** using AI + Automation + IaC.

------------------------------------------------------------------------

## 2. High Level Architecture

    +-----------------------+
    |   User / Chat UI      |
    +-----------+-----------+
                |
                v
    +-----------------------+
    |   LLM Agent           |
    | (Azure OpenAI / GPT)  |
    +-----------+-----------+
                |
                v
    +-----------------------+
    |   MCP Server          |
    | (Orchestrator Logic)  |
    +-----+-----------+-----+
          |           |
          v           v
    +---------+   +---------+
    |  TOSCA  |   | Tools   |
    |  Model  |-->| Registry|
    +----+----+   +----+----+
         |             |
         v             v
    +---------+   +---------+
    |PowerShell|  |Terraform|
    | Tools    |  | Tools    |
    +----+----+   +----+----+
         |             |
         v             v
    +-----------------------+
    | Azure APIs / Cloud    |
    +-----------------------+

------------------------------------------------------------------------

## 3. Core Components

### 3.0 TOSCA Modeling Layer (New)
Responsibilities: - Define Infrastructure Nodes (VMs, Web Apps) - Map High-Level Intents ("Start") to Concrete Scripts - Enforce Policies - Abstract Implementation Details

### 3.1 PowerShell Automation Layer

Responsibilities: - VM Start / Stop / Restart - App Service Restart /
Scale - Slot Swap - Diagnostics - Log Collection

### 3.2 Terraform Infrastructure Layer

Responsibilities: - Provision VMs - Create App Services - Networking
(VNet, Subnets) - Load Balancers - Storage & Databases - Destroy /
Recreate Environments

### 3.3 MCP Server Layer

Responsibilities: - Tool Discovery - Secure Execution - Context
Management - Audit Logging - Prompt Library Exposure

### 3.4 AI Agent Layer

Responsibilities: - Intent Understanding - Decision Making - Task
Chaining - Terraform Plan Review - Response Summaries

------------------------------------------------------------------------

## 4. Folder Structure

    /azure-agent-platform
     ├── mcp-server/
     │   ├── tools.json
     │   └── tosca_processor.py
     ├── modeling/
     │   └── service_template.yaml
     ├── tools/
     │   ├── powershell/
     │   │   ├── vm-start.ps1
     │   │   ├── vm-stop.ps1
     │   │   └── app-scale.ps1
     │   ├── terraform/
     │   │   ├── main.tf
     │   │   ├── variables.tf
     │   │   └── outputs.tf
     ├── prompts/
     ├── logs/
     └── config/

------------------------------------------------------------------------

## 5. Task Breakdown

### Phase 1 -- Environment Setup & Skeleton [DONE]
-   [x] Create Folder Structure
-   [x] Create Initial PowerShell Scripts
-   [x] Create Basic Terraform Template
-   [x] Define MCP Tool Registry (`tools.json`)

### Phase 1.5 -- Modeling Layer Integration [DONE]
-   [x] Define TOSCA Node Types
-   [x] Create `service_template.yaml`
-   [x] Implement TOSCA Processor in Python
-   [x] Map TOSCA Interfaces to PowerShell Scripts

### Phase 2 -- Script Development
-   [x] Monitoring scripts (Azure Monitor: `get-metric.ps1`)
-   [x] Logging scripts (Activity Log: `get-logs.ps1`)
-   [x] Terraform modules expansion (Compute, Network, Database modules created)
-   [ ] Error handling enhancements

### Phase 3 -- MCP Integration
-   [x] Register PowerShell tools
-   [x] Register Terraform tools
-   [x] Register TOSCA Execution tool
-   [x] Register Monitoring & Logging tools
-   [x] Enable deep audit logs (via `tosca_processor.py`)
-   [ ] Add safety constraints to wrappers

### Phase 4 -- AI Agent Integration
-   [x] Connect LLM (Simulated in `interactive_agent_cli.py`)
-   [x] Define system prompts
-   [x] Add tool‑use instructions
-   [x] Enable conversational UI (CLI-based)

### Phase 5 -- Observability
-   Enable Log Analytics (Azure Side)
-   [ ] Dashboard Creation

### Phase 6 -- Security [HOLD]
-   [ ] Key Vault integration
-   [ ] Managed Identity config check

------------------------------------------------------------------------

## 6. MCP Tool Definition Examples

### PowerShell Tool

``` json
{
  "name": "restart_vm",
  "description": "Restart Azure Virtual Machine",
  "parameters": ["resourceGroup", "vmName"],
  "command": "powershell ./tools/powershell/vm-restart.ps1"
}
```

### Terraform Tool

``` json
{
  "name": "terraform_apply",
  "description": "Apply Terraform Infrastructure",
  "parameters": ["workingDir"],
  "command": "terraform -chdir=${workingDir} apply -auto-approve"
}
```

------------------------------------------------------------------------

## 7. Terraform Integration via MCP

### Workflow

    User Prompt → AI Agent → MCP Tool → Terraform Plan → User Approval → Terraform Apply → Azure Resources

### Recommended Tools

  Tool                Purpose
  ------------------- -------------------------
  terraform-init      Initialize modules
  terraform-plan      Show diff before change
  terraform-apply     Apply infrastructure
  terraform-destroy   Remove infra
  terraform-output    Read outputs

### Safety Controls

-   Mandatory `plan` before `apply`
-   User approval prompts
-   Environment tagging (dev/test/prod)
-   Cost estimation tools

------------------------------------------------------------------------

## 8. PowerShell Template

``` powershell
param($resourceGroup, $vmName)

try {
    Restart-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
    Write-Output "VM Restarted Successfully"
}
catch {
    Write-Error $_
}
```

------------------------------------------------------------------------

## 9. AI Prompts Library

### System Prompt

    You are an Azure Cloud Operations and Infrastructure Agent.
    You can manage VMs, App Services, and Terraform Infrastructure.
    Always verify permissions and log every action.
    Never execute destructive operations without confirmation.

### User Intent Prompts

**Restart VM**

    Restart VM <vmName> in resource group <rgName>

**Deploy Infrastructure**

    Deploy a production web app using terraform module webapp-prod

**Diagnostics**

    Check CPU usage and scale app if above 80%

### Safety Prompt

    Confirm if this action impacts production.
    Request approval before deletion or shutdown.

------------------------------------------------------------------------

## 10. Observability Design

Metrics: - CPU / Memory - App Response Time - Error Rates - Cost
Metrics - Terraform Drift

Tools: - Azure Monitor - Log Analytics - OpenSearch - Grafana

------------------------------------------------------------------------

## 11. Self‑Healing Scenarios

  Scenario         Action
  ---------------- -------------------
  High CPU         Scale App
  VM Crash         Restart VM
  Memory Leak      Restart Service
  Cost Spike       Schedule Shutdown
  Drift Detected   Terraform Apply

------------------------------------------------------------------------

## 12. Security Best Practices

-   Managed Identity
-   Key Vault Secrets
-   RBAC Least Privilege
-   Audit Trails
-   Encryption at Rest & Transit
-   Environment Isolation

------------------------------------------------------------------------

## 13. Future Enhancements

-   Predictive Scaling
-   Cost Optimization AI
-   Multi‑Cloud Support
-   ChatOps (Teams/Slack Bots)
-   Auto‑Patch Management
-   Policy as Code (OPA)

------------------------------------------------------------------------

## 14. Success Checklist

-   Scripts Tested
-   Terraform Modules Validated
-   MCP Tools Registered
-   AI Prompts Validated
-   Logs Enabled
-   Alerts Configured
-   Security Policies Applied

------------------------------------------------------------------------

**Outcome:**\
A fully automated **Agentic AI Azure Operations & Infrastructure
Platform** capable of managing infrastructure, provisioning
environments, scaling applications, and self‑healing using AI‑driven
decisions with PowerShell + Terraform + MCP.
