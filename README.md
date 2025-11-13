# Containerized OpenCode TUI and AI agents

Docker environment for running OpenCode TUI with isolated AI agents.

## Build

```bash
docker build --build-arg OPENCODE_VERSION=1.0.61 -t opencode .
```

## Usage

### OpenCode with agent

```bash
$ docker run -it --rm \
  -v ${HOME}/.opencode:/home/agent/.opencode \
  -v ${PWD}:/workspace:rslave \
  -w /workspace \
  -e DISPLAY=${DISPLAY} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  opencode opencode --agent "research"
```

## Available specialized agents

| Agent | Description |
|-------|-------------|
| `code` | Code writer/developer |
| `debug` | Code debugger |
| `docs` | Documentation writer/maintainer |
| `plan2` | Solution planner/architect |
| `refactor` | Code refactorer |
| `research` | Researcher/advisor |
| `review` | Code reviewer |
| `test` | Test runner and validator |
| `security` | Security auditor |

## Shell integration

Add to `~/.bashrc` and restart shell:

```bash
source /path/to/opencode-aliases.bashrc
```

Usage:

```bash
cd ~/my-project
opencode-code
# or
opencode-review "Review recent changes"
```

## License

Copyright &copy; 2025 *gw0* [<http://gw.tnode.com/>] &lt;<gw.2025@ena.one>&gt;

All code is licensed under the GNU Affero General Public License 3.0+ (`AGPL-3.0-or-later`). Note that it is mandatory to make all modifications and complete source code publicly available to any user.
