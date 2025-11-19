# Reticulum Transport Node Docker Setup

A complete Docker setup for running a Reticulum transport node with LoRa, TCP, and optional I2P interfaces.

## Prerequisites

- Docker and Docker Compose installed
- RNode-compatible device (e.g., Heltec LoRa32 V3) connected via USB
- Port 4242 forwarded if you want external TCP connections

## Quick Start

### 1. Find Your Serial Device

First, identify your RNode device:

```bash
# List USB serial devices
ls -l /dev/serial/by-id/

# You should see something like:
# usb-Heltec_LoRa32_V3_XXXXXX-if00 -> ../../ttyUSB0
```

### 2. Update docker-compose.yml

Edit `docker-compose.yml` and update the device mapping with your actual device ID:

```yaml
devices:
  - "/dev/serial/by-id/usb-Heltec_LoRa32_V3_YOUR_ID-if00:/dev/ttyUSB0"
```

### 3. Build and Run

```bash
# Build the image
docker-compose build

# Start the container
docker-compose up -d

# View logs
docker-compose logs -f
```

## Configuration

### Initial Setup

On first run, a default config will be created at `./config/config`. You can customize it by editing this file and restarting:

```bash
nano ./config/config
docker-compose restart
```

### Adding Passphrases (Private Network)

To create a private network, add these lines to your interface configurations:

```
network_name = family_network_2024
passphrase = your_secure_passphrase_here
```

### Enabling I2P

1. Uncomment the I2P interface section in the config
2. Restart the container
3. Wait 5-10 minutes for I2P to bootstrap
4. Check logs for your I2P address: `docker-compose logs | grep "I2P"`

## Connecting Clients

### TCP Connection (for remote family/friends)

Share this config snippet:

```
[[Family Node]]
type = TCPClientInterface
enabled = yes
target_host = your.ip.address.or.domain
target_port = 4242
network_name = family_network_2024  # if using passphrases
passphrase = your_secure_passphrase_here  # if using passphrases
```

### I2P Connection

Share your I2P base32 address (found in logs):

```
[[Family I2P Node]]
type = I2PInterface
enabled = yes
peers = xxxxxx.b32.i2p
```

## Useful Commands

```bash
# View logs
docker-compose logs -f

# Check Reticulum status
docker-compose exec reticulum rnstatus

# Restart container
docker-compose restart

# Stop container
docker-compose down

# Rebuild after changes
docker-compose up -d --build
```

## Troubleshooting

### Serial device not found

1. Check device is connected: `ls -l /dev/ttyUSB*`
2. Check permissions: `groups` (should include `dialout`)
3. Verify device mapping in docker-compose.yml
4. Try using `/dev/ttyUSB0` directly instead of by-id path

### Port forwarding issues

1. Verify port 4242 is forwarded on your router
2. Check firewall rules: `sudo ufw status`
3. Test externally: `telnet your-ip 4242`

### I2P not working

1. Wait 10-15 minutes for initial bootstrap
2. Check I2P logs: `docker-compose logs i2pd`
3. Verify I2P interface is uncommented and enabled in config

### Container won't start

1. Check logs: `docker-compose logs`
2. Verify all volumes are accessible
3. Check for port conflicts: `sudo netstat -tlnp | grep 4242`

## Security Notes

- Change default passphrases immediately
- Use strong, unique passphrases (20+ characters)
- Keep the container updated: `docker-compose pull && docker-compose up -d`
- Consider running on isolated VLAN if exposing to internet
- Monitor resource usage: `docker stats`

## File Structure

```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service configuration
├── start.sh               # Container startup script
├── config/                # Reticulum config (auto-created)
│   └── config
├── i2pd_data/            # I2P data (auto-created)
└── logs/                 # Application logs (auto-created)
```

## Updates

To update Reticulum:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Additional Resources

- [Reticulum Documentation](https://markqvist.github.io/Reticulum/manual/)
- [RNode Documentation](https://unsigned.io/rnode/)
- [I2P Documentation](https://geti2p.net/en/docs)