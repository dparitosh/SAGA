import json
import os
import subprocess
import sys
import shlex
import re

# Configuration
TOOLS_FILE = "mcp-server/tools.json"
TOSCA_FILE = "modeling/service_template.yaml"
CONFIG_FILE = "config/platform_config.json"

class AgenticCLI:
    def __init__(self):
        self.config = self.load_config()
        self.tools = self.load_tools()
        self.history = []
        print("\n🤖 Azure Agentic AI - Interactive Orchestrator")
        print("------------------------------------------------")
        print(f"Loaded {len(self.tools)} tools from {TOOLS_FILE}")
        print(f"Loaded Config: Resource Group '{self.config['azure']['resource_group']}'")
        print("Type 'help' for examples or 'exit' to quit.\n")

    def load_config(self):
        try:
            with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: Could not find {CONFIG_FILE}. Using defaults.")
            return {
                "azure": {
                    "subscription_id": "00000000-0000-0000-0000-000000000000",
                    "resource_group": "agentic-ai-rg"
                }
            }

    def load_tools(self):
        try:
            with open(TOOLS_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: Could not find {TOOLS_FILE}")
            sys.exit(1)

    def find_tool(self, name):
        for tool in self.tools:
            if tool['name'] == name:
                return tool
        return None

    def execute_tool_command(self, tool, params):
        command_template = tool['command']
        
        # Replace placeholders like ${resourceGroup} with actual values
        # If the command uses python or powershell, we need to handle that
        cmd_str = command_template
        for key, value in params.items():
            cmd_str = cmd_str.replace(f"${{{key}}}", str(value))
        
        # Naive check for unreplaced variables
        if "${" in cmd_str:
            print(f"⚠️  Warning: Not all parameters were replaced in command: {cmd_str}")
        
        print(f"⚡ Executing Component: {tool['name']}...")
        print(f"   Command: {cmd_str}")
        
        # Split command correctly for subprocess
        # We need to handle 'powershell' and 'python' prefixes if they exist in the JSON command
        # The JSON commands are like "powershell ./tools/..."
        
        args = shlex.split(cmd_str)
        
        try:
            result = subprocess.run(args, capture_output=True, text=True, check=False)
            if result.returncode == 0:
                print("✅ Success:")
                print(result.stdout.strip())
            else:
                print("❌ Failed:")
                print(result.stderr.strip())
        except (subprocess.SubprocessError, OSError) as e:
            print(f"❌ Execution Error: {e}")

    def nlp_router(self, user_input):
        """
        Simulates the LLM routing logic. 
        In a real scenario, this would send `user_input` + `tools.json` to GPT-4.
        Here we use regex to map common intents to our specific tools.
        """
        user_input = user_input.lower()

        # INTENT: Start/Stop/Restart VM via TOSCA
        # Matches: "start vm MyOperationsVM", "restart operations vm"
        vm_match = re.search(r"(start|stop|restart)\s+(?:the\s+)?(?:vm\s+)?(\w+)", user_input)
        if vm_match:
            action = vm_match.group(1)
            target = vm_match.group(2)
            
            # Map common nicknames to TOSCA IDs
            if "ops" in target or "operations" in target:
                node_name = "MyOperationsVM"
            elif "prod" in target:
                node_name = "MyProdApp" # Just for example, though app checks are often different
            else:
                node_name = target # Assume user typed the exact node name

            print(f"🧠 AI: Mapped intent '{action}' on '{target}' -> TOSCA Node '{node_name}'")
            
            return "tosca_execute_node_op", {"node_name": node_name, "operation": action}

        # INTENT: Check Metrics
        # Matches: "check cpu for MyVM", "show memory metrics"
        metric_match = re.search(r"(check|get|show)\s+(cpu|memory)\s+(?:for\s+)?(\S+)", user_input)
        if metric_match:
            metric_type = metric_match.group(2)
            
            # Construct Resource ID dynamically from Config
            sub_id = self.config['azure']['subscription_id']
            rg_name = self.config['azure']['resource_group']
            # Note: For a real app, we would look up the specific VM's ID from a state file or list.
            # Here we default to the known 'ops-vm-01' for the demo context.
            vm_name = "ops-vm-01" 
            
            resource_id_placeholder = f"/subscriptions/{sub_id}/resourceGroups/{rg_name}/providers/Microsoft.Compute/virtualMachines/{vm_name}"
            
            metric_name = "Percentage CPU" if "cpu" in metric_type else "Available Memory Bytes"
            
            print(f"🧠 AI: Mapped intent 'Metric Check' -> Azure Monitor: {metric_name}")
            return "get_metric", {
                "resourceId": resource_id_placeholder, 
                "metricName": "Percentage CPU", # Simplified for demo
                "aggregation": "Average", 
                "timeRangeHours": 1
            }

        # INTENT: Help
        if "help" in user_input:
            print("\nAvailable Commands ( Natural Language Examples ):")
            print(" - 'Start the Operations VM'")
            print(" - 'Restart MyOperationsVM'")
            print(" - 'Check CPU for the ops vm'")
            print(" - 'Show activity logs'")
            return None, None

        print("❓ AI: I didn't understand that intent. Try 'help'.")
        return None, None

    def run(self):
        while True:
            try:
                user_input = input("\nUser: > ").strip()
                if not user_input: continue
                if user_input.lower() in ['exit', 'quit']:
                    print("Goodbye.")
                    break
                
                tool_name, params = self.nlp_router(user_input)
                
                if tool_name:
                    tool = self.find_tool(tool_name)
                    if tool:
                        self.execute_tool_command(tool, params)
            except KeyboardInterrupt:
                print("\nGoodbye.")
                break

if __name__ == "__main__":
    # Ensure we are in the right directory for relative paths to work
    if os.path.exists("azure-agent-platform"):
        os.chdir("azure-agent-platform")
    
    app = AgenticCLI()
    app.run()
