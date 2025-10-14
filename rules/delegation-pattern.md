# Delegation Pattern Rules
- Declare allowed sub-agents in `delegates:` metadata or a Delegation table.
- Pass minimal context (inputs and identifiers, not chain-of-thought).
- Require structured responses from sub-agents.
- Avoid circular references; terminate in a leaf agent.
- Prioritize MCP tools over bash commands for external integrations; check MCP availability before delegation.
