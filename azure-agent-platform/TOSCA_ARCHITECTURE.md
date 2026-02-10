# Architecture Update: TOSCA Model-Driven Operations

## Overview
This architecture introduces a **TOSCA (Topology and Orchestration Specification for Cloud Applications)** layer to abstract the relationship between the AI Agent and the underlying execution scripts.

## The Stack
| Layer | Component | Role |
|-------|-----------|------|
| **Modeling** | **TOSCA YAML** | Defines the "What" (Nodes, Relationships, Interfaces, Policies). |
| **Orchestration** | **MCP Server / AI** | The "Brain" that reads the model and decides "When" to act. |
| **Execution** | **PowerShell / Terraform** | The "How". Performs the actual API calls to Azure. |
| **Cloud** | **Azure** | The destination environment. |

## Workflow
1.  **Define**: Engineer defines `service_template.yaml` (see `modeling/`).
2.  **Parse**: AI Agent reads the TOSCA file to understand available nodes (e.g., `MyOperationsVM`) and capabilities (e.g., `start`, `stop`, `configure`).
3.  **Map**: The MCP Server maps a TOSCA Interface operation (e.g., `Standard.start`) to a specific artifact (e.g., `tools/powershell/vm-start.ps1`).
4.  **Execute**: AI Agent invokes the MCP tool `tosca_execute_node_op`, which triggers the mapped script.

## Benefits
-   **Model-Driven**: The AI doesn't need to know *which* script to run; it just knows it needs to "start" the "Compute Node".
-   **Policies**: Policies defined in TOSCA (e.g., "Auto-Scale if CPU > 80%") can be parsed by the AI to set up monitoring rules automatically.
