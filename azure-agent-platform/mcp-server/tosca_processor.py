import yaml
import subprocess
import os
import json

class ToscaOrchestrator:
    def __init__(self, tosca_file):
        self.tosca_file = tosca_file
        self.base_path = os.path.dirname(os.path.abspath(tosca_file))

    def load_model(self):
        with open(self.tosca_file, 'r', encoding='utf-8') as f:
            self.model = yaml.safe_load(f)
        return self.model

    def get_interface_operation(self, node_name, interface, operation):
        node = self.model['topology_template']['node_templates'].get(node_name)
        if not node:
            return None
        
        node_type = node['type']
        # In a real parser, we would look up the type definition. 
        # Here we mock looking up the type in the same file for simplicity
        type_def = self.model['node_types'].get(node_type)
        
        if type_def and 'interfaces' in type_def:
            ops = type_def['interfaces'].get(interface, {})
            return ops.get(operation)
        return None

    def execute_operation(self, node_name, operation_name):
        """
        AI Agent calls this to trigger an action defined in TOSCA.
        """
        op_def = self.get_interface_operation(node_name, 'Standard', operation_name)
        if not op_def:
            return {"status": "error", "message": f"Operation {operation_name} not defined for {node_name}"}

        script_path = op_def['implementation']
        # Resolve relative path
        abs_script_path = os.path.normpath(os.path.join(self.base_path, script_path))
        
        # Detect file type and construct command appropriately
        file_ext = os.path.splitext(abs_script_path)[1].lower()
        
        if file_ext == '.tf':
            # Terraform file - use terraform command
            tf_dir = os.path.dirname(abs_script_path)
            cmd = ["terraform", "-chdir=" + tf_dir, "apply", "-auto-approve"]
        elif file_ext == '.ps1':
            # PowerShell script
            cmd = ["pwsh", abs_script_path]
            # Inject properties as arguments
            node_props = self.model['topology_template']['node_templates'][node_name]['properties']
            for key, value in node_props.items():
                cmd.append(f"-{key}")
                cmd.append(str(value))
            # Inject operation inputs if defined
            if 'inputs' in op_def:
                for key, value in op_def['inputs'].items():
                    cmd.append(f"-{key}")
                    cmd.append(str(value))
        else:
            return {"status": "error", "message": f"Unsupported file type: {file_ext}"}

        print(f"Executing: {' '.join(cmd)}")
        
        self.log_audit(node_name, operation_name, "STARTED", f"Command: {' '.join(cmd)}")

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            self.log_audit(node_name, operation_name, "SUCCESS", result.stdout)
            return {"status": "success", "output": result.stdout}
        except subprocess.CalledProcessError as e:
            self.log_audit(node_name, operation_name, "FAILED", e.stderr)
            return {"status": "failed", "error": e.stderr}

    def log_audit(self, node, operation, status, details):
        import datetime
        timestamp = datetime.datetime.now().isoformat()
        log_entry = {
            "timestamp": timestamp,
            "node": node,
            "operation": operation,
            "status": status,
            "details": details.strip() if details else ""
        }
        
        log_file = os.path.join(self.base_path, "../logs/audit.log")
        # Ensure directory exists
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
        
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(log_entry) + "\n")

# Example Usage for MCP Tool
if __name__ == "__main__":
    # This would be part of the MCP Tool Handler
    orchestrator = ToscaOrchestrator("../modeling/service_template.yaml")
    orchestrator.load_model()
    
    # AI decides to "start" the "MyOperationsVM" based on the model
    print("Agent triggering 'start' on 'MyOperationsVM'...")
    # result = orchestrator.execute_operation("MyOperationsVM", "start") # Commented out to prevent actual execution during generation
