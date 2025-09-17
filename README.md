# LF9 - Multi-Service Docker Learning Environment

## 🇩🇪 Deutsch | 🇬🇧 English

This project provides a comprehensive multi-service Docker environment for educational purposes (Lernfeld 9). It includes various services commonly used in enterprise environments.

Dieses Projekt stellt eine umfassende Multi-Service-Docker-Umgebung für Bildungszwecke (Lernfeld 9) bereit. Es umfasst verschiedene Dienste, die häufig in Unternehmensumgebungen verwendet werden.

## 🚀 Quick Start

### Prerequisites / Voraussetzungen

- Modern Linux computer with ~4GB RAM, 15GB storage, and 2 CPU cores
- Docker and Docker Compose
- Git

**Ubuntu/Debian:**
```bash
sudo apt install docker.io docker-compose-plugin git
```

### Installation

### Quick Setup (Recommended)

Use the management script for easy setup:

```bash
git clone https://github.com/pilz0/LF9
cd LF9
./manage.sh setup
./manage.sh validate
./manage.sh start
```

### Manual Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/pilz0/LF9
   cd LF9
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your preferred passwords and settings
   nano .env
   ```

3. **Start services:**
   ```bash
   docker compose up -d
   ```

4. **Verify installation:**
   ```bash
   docker compose ps
   ```

## 📋 Services Overview

| Service | URL/Access | Default Credentials | Purpose |
|---------|------------|-------------------|---------|
| **WordPress** | http://localhost:8080 | user: `user`, pass: `bitnami` | Web CMS |
| **Grafana** | http://localhost:3000 | user: `admin`, pass: `admin` | Monitoring Dashboard |
| **VNC/Desktop** | http://localhost:6901 | password: `vncpassword` | Virtual Desktop |
| **WikiJS** | http://localhost:3001 | Setup required | Documentation |
| **FTP Server** | ftp://localhost:21 | users: `user1`/`user2` | File Transfer |
| **Samba/SMB** | `\\localhost\` | users: `Benutzer1`/`Benutzer2` | File Sharing |
| **Prometheus** | http://localhost:9090 | No auth | Metrics Collection |

### Network Configuration

| Service | DNS | IPv4 | IPv6 | Port |
|---------|-----|------|------|------|
| WordPress | wordpress.local | 10.13.12.42 | fd69:acab:1312::42 | 8080 |
| MariaDB | mariadb.local | 10.13.12.50 | fd69:acab:1312::50 | 3306 |
| FTP | ftp.local | 10.13.12.116 | IPv6 issues | 20, 21 |
| VNC/Client | vm.local | 10.13.12.55 | fd69:acab:1312::55 | 5901, 6901 |
| DNS | unbound.local | 10.13.12.69 | fd69:acab:1312::69 | 53 |
| Grafana | grafana.local | 10.13.12.99 | fd69:acab:1312::99 | 3000 |
| Prometheus | prometheus.local | 10.13.12.98 | fd69:acab:1312::98 | 9090 |

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

- `*_PASSWORD`: Set secure passwords for all services
- `NETWORK_SUBNET_*`: Customize network configuration
- `*_VERSION`: Pin specific service versions

### ARM64 Support

For ARM64 systems (Raspberry Pi, Apple Silicon), uncomment the ARM64 image in docker-compose.yml:

```yaml
# Line 68-69 in docker-compose.yml
# image: "mvance/unbound:latest" # comment out for ARM64
image: "mvance/unbound-rpi:latest" # uncomment for ARM64
```

## 📝 Management

### Using the Management Script (Recommended)

The project includes a comprehensive management script:

```bash
# Setup the environment
./manage.sh setup

# Validate configuration
./manage.sh validate

# Start all services
./manage.sh start

# Check status
./manage.sh status

# View all service URLs
./manage.sh urls

# Stop services
./manage.sh stop

# Show help
./manage.sh --help
```

### Manual Management

#### Updates

#### Updates

```bash
./manage.sh update
# OR manually:
docker compose down
git pull
docker compose pull
docker compose up -d
```

#### Logs

#### Logs

```bash
# Using management script
./manage.sh logs
./manage.sh logs wordpress

# Manual
# View all logs
docker compose logs

# View specific service logs
docker compose logs wordpress
```

#### Backup

#### Backup

```bash
# Using management script
./manage.sh backup

# Manual backup
# Backup volumes
docker compose down
tar -czf backup.tar.gz wiki_data ftp1 ftp2 smb_user1 smb_user2

# Restore
./manage.sh restore backup.tar.gz
# OR manually:
tar -xzf backup.tar.gz
docker compose up -d
```

## 🔒 Security Considerations

⚠️ **Important**: This setup is for educational purposes. For production use:

- Change all default passwords
- Enable HTTPS/TLS
- Configure proper firewall rules
- Regular security updates
- Use secrets management
- Enable audit logging

## 🐛 Troubleshooting

## 🐛 Troubleshooting

### Quick Diagnostics

Run the validation script to check your setup:
```bash
./validate.sh
```

### Common Issues

#### 1. Port Conflicts
**Problem**: "Port already in use" errors
```bash
# Check which process is using the port
netstat -tulpn | grep :8080
# Or use the management script
./manage.sh status
```
**Solution**: Stop conflicting services or change ports in docker-compose.yml

#### 2. Permission Issues
**Problem**: "Permission denied" when accessing files
```bash
# Fix ownership of data directories
sudo chown -R $USER:$USER ftp1 ftp2 smb_user1 smb_user2 wiki_data
chmod -R 755 ftp1 ftp2 smb_user1 smb_user2
```

#### 3. Docker Daemon Issues
**Problem**: "Cannot connect to Docker daemon"
```bash
# Check Docker status
sudo systemctl status docker

# Start Docker if stopped
sudo systemctl start docker

# Add user to docker group (requires logout/login)
sudo usermod -aG docker $USER
```

#### 4. DNS Resolution Issues
**Problem**: Services can't resolve each other
```bash
# Check unbound service logs
./manage.sh logs unbound

# Test DNS resolution inside network
docker compose exec wordpress nslookup mariadb.local
```

#### 5. IPv6 Issues
**Problem**: IPv6 connectivity problems
```bash
# Disable IPv6 in docker-compose.yml by commenting out IPv6 addresses
# Then restart services
./manage.sh restart
```

#### 6. Service Won't Start
**Problem**: Individual service fails to start
```bash
# Check specific service logs
./manage.sh logs [service-name]

# Restart specific service
./manage.sh restart [service-name]

# Check service health
docker compose ps
```

#### 7. Database Connection Issues
**Problem**: WordPress/WikiJS can't connect to database
```bash
# Check if database is healthy
docker compose ps
./manage.sh logs mariadb
./manage.sh logs postgres_db

# Verify database environment variables
docker compose config | grep -A 5 -B 5 "DATABASE"
```

#### 8. VNC Connection Issues
**Problem**: Can't connect to VNC desktop
```bash
# Check VNC service logs
./manage.sh logs vm_debian

# Test noVNC web interface
curl -I http://localhost:6901

# Check if VNC password is set correctly
docker compose exec vm_debian printenv VNC_PW
```

#### 9. Resource Issues
**Problem**: Services running slowly or crashing
```bash
# Check system resources
free -h
df -h
docker system df

# Monitor container resource usage
docker stats

# Clean up unused resources
./manage.sh clean
```

#### 10. Network Issues
**Problem**: Services can't communicate with each other
```bash
# Check network configuration
docker network ls
docker network inspect lf9_default

# Test connectivity between services
docker compose exec wordpress ping mariadb.local
```

### Advanced Troubleshooting

#### Enable Debug Mode
Set environment variable for more verbose logging:
```bash
echo "COMPOSE_LOG_LEVEL=DEBUG" >> .env
./manage.sh restart
```

#### Check Service Health
```bash
# Check health status of all services
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"

# Get detailed health check logs
docker inspect --format='{{json .State.Health}}' container_name
```

#### Reset Individual Services
```bash
# Remove and recreate a specific service
docker compose rm -f [service-name]
docker compose up -d [service-name]
```

### Getting Help

1. **Check logs first**: `./manage.sh logs [service]`
2. **Validate setup**: `./validate.sh`
3. **Check documentation**: Review service-specific documentation links
4. **Search issues**: Check the GitHub repository issues
5. **Create an issue**: Include logs and error messages

### Performance Optimization

#### Reduce Resource Usage
```bash
# Stop unnecessary services
docker compose stop [service-name]

# Use resource limits (already configured in docker-compose.yml)
# Monitor with: docker stats
```

#### Speed Up Startup
```bash
# Use Docker BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Pre-pull images
docker compose pull
```

## 📚 Documentation

- [German Documentation](Doku.md) - Detailed German documentation
- [Network Diagram](docs/Netzplan.drawio) - Network architecture
- [Project Structure](docs/Projektstrukturdiagramm.svg) - Project overview

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is created for educational purposes (Lernfeld 9).

## 🎯 Learning Objectives

This environment helps learn:
- Docker and containerization
- Service orchestration with Docker Compose
- Network configuration (IPv4/IPv6)
- Database management
- Web services deployment
- Monitoring and logging
- File sharing protocols (FTP/SMB)
- DNS configuration
- Security best practices