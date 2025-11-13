# Dockerfile for containerized OpenCode
#
#   docker build --progress=plain --build-arg OPENCODE_VERSION=1.0.55 -t opencode .
#   docker run -it --rm -v ${HOME}/.opencode:/home/agent/.opencode -v ${PWD}:/workspace:rslave -w /workspace -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix opencode opencode --agent "${agent}"
#
# syntax=docker/dockerfile:1

FROM oven/bun:1.3-debian

##
# APT packages
##
WORKDIR /tmp
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
    # essentials
    ca-certificates \
    curl \
    gnupg \
    unzip \
    # shell utils
    bash-completion \
    jq \
    less \
    nano \
    procps \
    psmisc \
    screen \
    vim \
    yq \
    # network utils
    bind9-dnsutils \
    iproute2 \
    iputils-ping \
    mtr-tiny \
    netcat-openbsd \
    openssh-client \
    rsync \
    socat \
    tsocks \
    # dev utils
    git \
    make \
    man-db \
    htop \
    time \
    python3-pip \
    # clipboard
    xsel \
    # system
    unattended-upgrades \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
    # configure installed
 && echo "${TZ}" > /etc/timezone \
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && update-alternatives --set editor /usr/bin/vim.basic \
 && rm /usr/lib/python*/EXTERNALLY-MANAGED \
 && echo "" > /etc/tsocks.conf \
    # use same tmp
 && rm -rf /var/tmp \
 && ln -s /tmp /var/tmp

##
# NPM packages
##
# https://github.com/sst/opencode/releases
ARG OPENCODE_VERSION=1.0.61

ENV BUN_INSTALL=/usr/local/bun
RUN . /etc/os-release \
    # install opencode
 && bun install -g opencode-ai@${OPENCODE_VERSION} \
    # print versions
 && opencode --version

##
# User configuration
##
ARG USER=agent
ARG USER_UID=1000
ARG USER_GID=1000

RUN userdel -r bun \
    # create non-root user
 && groupadd -g ${USER_GID} ${USER} \
 && useradd --create-home --shell /bin/bash -u ${USER_UID} -g ${USER_GID} ${USER} \
    # create mountable dirs
 && mkdir -p /usr/local/bun /workspace /home/${USER}/.opencode \
 && chown -R ${USER}:${USER} /usr/local/bun /workspace /home/${USER} \
    # reorganize opencode dirs
 && mkdir -p /home/${USER}/.config /home/${USER}/.local/share /home/${USER}/.local/state \
 && ln -snf ../.opencode/ /home/${USER}/.config/opencode \
 && ln -snf ../../.opencode/share/ /home/${USER}/.local/share/opencode \
 && ln -snf ../../.opencode/state/ /home/${USER}/.local/state/opencode \
 && ln -snf ./.opencode/.bash_history /home/${USER}/.bash_history

COPY scripts/* /usr/local/bin/
COPY opencode-defaults/ /home/${USER}/.opencode-defaults
COPY agents/ /home/${USER}/.opencode-defaults/agent

# Customize shell interface
ENV EDITOR=vim
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && echo '# Initialize opencode (gw0)' >> /etc/bash.bashrc \
 && echo '[[ -z "$(ls -A ~/.opencode)" || "${FORCE_DEFAULTS}" =~ ^[1YyTt]$ ]] && cp -vR ~/.opencode-defaults/* ~/.opencode' >> /etc/bash.bashrc \
 && echo 'mkdir -p ~/.opencode/share ~/.opencode/state' >> /etc/bash.bashrc \
 && echo 'export OPENCODE_CONFIG_DIR=~/.opencode' >> /etc/bash.bashrc \
 && echo 'export OPENCODE_DISABLE_AUTOUPDATE=1' >> /etc/bash.bashrc \
 && echo '# Shell customization (gw0)' >> /etc/bash.bashrc \
 && echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc \
 && echo 'git config --global --add safe.directory "${PWD}"' >> /etc/bash.bashrc \
 && echo 'alias ll="ls --color=auto -lA"' >> /etc/bash.bashrc \
 && echo 'alias watch="watch "' >> /etc/bash.bashrc \
 && echo 'alias sshx="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"' >> /etc/bash.bashrc \
 && echo 'alias scpx="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"' >> /etc/bash.bashrc \
 && echo '# Enable PgUp/PgDown history search (gw0)' >> /etc/inputrc \
 && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
 && echo '"\e[6~": history-search-forward' >> /etc/inputrc \
 && echo '# Enable scrollwheel (gw0)' >> /etc/screenrc \
 && echo 'termcapinfo xterm* ti@:te@' >> /etc/screenrc \
 && echo '" Turn off mouse and auto-indent on paste (gw0)' >> /etc/vim/vimrc.local \
 && echo 'set mouse=' >> /etc/vim/vimrc.local \
 && echo 'set ttymouse=' >> /etc/vim/vimrc.local \
 && echo 'set paste' >> /etc/vim/vimrc.local \
 && echo 'set pastetoggle=<F2>' >> /etc/vim/vimrc.local

USER ${USER}:${USER}
WORKDIR /workspace
CMD ["/bin/bash"]
