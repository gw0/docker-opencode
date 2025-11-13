#!/bin/bash
# Bash aliases for containerized OpenCode
#
#   echo 'source /path/to/opencode-aliases.bashrc' >> ~/.bashrc

# Create opencode-{agent} aliases
AGENTS=(code debug docs plan2 refactor research review test security)
for agent in "${AGENTS[@]}"; do
  alias opencode-${agent}="docker run -it --rm -v \${HOME}/.opencode:/home/agent/.opencode -v \${PWD}:/workspace:rslave -w /workspace -e DISPLAY=\${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix opencode opencode --agent ${agent}"
done
