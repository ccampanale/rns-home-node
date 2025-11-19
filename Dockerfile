FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    i2pd \
    udev \
    && rm -rf /var/lib/apt/lists/*

# Install Reticulum and related packages
RUN pip install --no-cache-dir \
    rns \
    rnsh \
    nomadnet \
    lxmf

# Create reticulum user and necessary directories
RUN useradd -m -s /bin/bash reticulum && \
    usermod -a -G dialout reticulum && \
    mkdir -p /home/reticulum/.reticulum && \
    chown -R reticulum:reticulum /home/reticulum

# Copy configuration files (these will be mounted as volumes)
VOLUME ["/home/reticulum/.reticulum", "/var/lib/i2pd"]

# Expose ports
# 4242 for TCP interface
# 7656 for I2P SAM API (if needed)
EXPOSE 4242 7656

# Switch to reticulum user
USER reticulum
WORKDIR /home/reticulum

# Start script will be created separately
COPY --chown=reticulum:reticulum start.sh /home/reticulum/
RUN chmod +x /home/reticulum/start.sh

CMD ["/home/reticulum/start.sh"]