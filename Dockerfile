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

# Ensure /app directory exists with correct permissions
RUN mkdir -p /app && chown -R ralph:ralph /app

# Switch to the non-root user and set working directory to /app
USER ralph
WORKDIR /app

# Create startup script for automatic cline configuration
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Check if .env file exists at /app\n\
if [ -f "/app/.env" ]; then\n\
  echo "Loading environment variables from /app/.env"\n\
  export $(grep -v "^#" /app/.env | xargs)\n\
fi\n\
\n\
# Configure cline automatically if environment variables are set\n\
if [ -n "$PROVIDER" ] && [ -n "$APIKEY" ] && [ -n "$MODEL" ]; then\n\
  echo "Configuring cline with environment variables..."\n\
  cline auth --provider "$PROVIDER" --apikey "$APIKEY" --model "$MODEL"\n\
  echo "Cline authentication complete. You can now run: cline"\n\
else\n\
  echo "Environment variables not fully configured. Please set PROVIDER, APIKEY, and MODEL in /app/.env"\n\
fi\n\
\n\
# Execute any additional commands passed to the script\n\
exec "$@"\n\
' > /home/ralph/startup.sh && chmod +x /home/ralph/startup.sh

# Default command - run startup script with tail to keep container alive
CMD ["/home/ralph/startup.sh", "tail", "-f", "/dev/null"]
