# Agentic AI Azure Operations Platform

## Overview
This platform enables **AI‑Driven Remote Management and Infrastructure Provisioning** for Azure.

## Prerequisities (Phase 1)
- Install PowerShell 7
- Install Az Modules (`Install-Module -Name Az`)
- Install Terraform CLI
- Create Azure Service Principal
- Configure RBAC Roles
- Enable Log Analytics

## Structure
- `mcp-server/`: Configuration for Model Context Protocol tools.
- `tools/powershell/`: Scripts for VM management and App scaling.
- `tools/terraform/`: Infrastructure as Code templates.
- `modeling/`: TOSCA YAML service definitions (Architecture Layer 1).
- `prompts/`: System and user prompts for the AI agent.

## Architecture (Model-Driven)
The platform uses **TOSCA** to define infrastructure models.
- **Model**: `modeling/service_template.yaml`
- **Executor**: `mcp-server/tosca_processor.py`
- **Scripts**: `tools/`

## Usage
1. **Configure Environment**: Ensure you are logged in to Azure (`Connect-AzAccount`).
2. **Interactive UI**: Run the Python CLI to start the simulated agent.
   ```bash
   python interactive_agent_cli.py
   ```
   *Try commands like: "Start the Operations VM" or "Check CPU metrics".*

3. **Manual Execution**:
   - **MCP Server**: Load the `mcp-server/tools.json` definitions into your MCP-compatible agent.
   - **Run Tools**: Use the defined prompts to trigger actions.

## Security
- Always review plans before applying Terraform changes.
- Ensure the running identity has least-privilege access.
