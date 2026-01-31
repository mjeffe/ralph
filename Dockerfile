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

# Install cline CLI using npm (RUN THIS AS ROOT BEFORE SWITCHING USERS)
RUN npm install -g cline

# Create a non-root user for better security
RUN useradd -m -s /bin/bash ralph

# Grant sudo privileges without password
RUN echo "ralph ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /app

# Switch to the non-root user
USER ralph
WORKDIR /home/ralph

# Create startup script for automatic cline configuration
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Check if .env file exists\n\
if [ -f "/home/ralph/.env" ]; then\n\
  echo "Loading environment variables from /home/ralph/.env"\n\
  export $(grep -v "^#" /home/ralph/.env | xargs)\n\
fi\n\
\n\
# Configure cline automatically if environment variables are set\n\
if [ -n "$PROVIDER" ] && [ -n "$APIKEY" ] && [ -n "$MODEL" ]; then\n\
  echo "Configuring cline with environment variables..."\n\
  cline auth --provider "$PROVIDER" --apikey "$APIKEY" --model "$MODEL"\n\
else\n\
  echo "Environment variables not fully configured. Please set PROVIDER, APIKEY, and MODEL."\n\
fi\n\
\n\
# Start bash\n\
exec "$@"\n\
' > /home/ralph/startup.sh && chmod +x /home/ralph/startup.sh

# Default command
CMD ["/home/ralph/startup.sh", "/bin/bash"]