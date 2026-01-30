FROM ubuntu:latest

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update package list and install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    nodejs \
    python3 \
    git \
    jq \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js using NodeSource repository for latest version
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Install Python pip
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for better security
RUN useradd -m -s /bin/bash ralph

# Grant sudo privileges without password
RUN echo "ralph ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /app

# Switch to the non-root user
USER ralph
WORKDIR /home/ralph

# Install cline CLI using npm
RUN npm install -g cline

# Default command
CMD ["/bin/bash"]
