# LF9 - Learning Field 9 Infrastructure Project

This project sets up a comprehensive network infrastructure using Docker Compose, featuring multiple services including web servers, databases, monitoring systems, file sharing, and network services.

## 🏗️ Architecture Overview

The infrastructure includes the following services:
- **Web Services**: WordPress with NGINX and MariaDB
- **File Sharing**: FTP Server and Samba/SMB
- **Monitoring**: Grafana, Prometheus, and Node Exporter
- **Network Services**: DNS Server (Unbound)
- **Documentation**: WikiJS with PostgreSQL
- **Virtual Environment**: Debian VM with VNC access

## 📋 Prerequisites

- Modern Linux computer with:
  - ~4GB RAM
  - 15GB free storage
  - 2 CPU cores
- Docker Engine
- Docker Compose
- Git

## 🚀 Quick Start

### Installation

1. **Install dependencies** (Debian/Ubuntu):
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose git
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/pilz0/LF9
   cd LF9
   ```

3. **Start all services**:
   ```bash
   docker-compose up -d
   ```

### Accessing Services

After startup, services are available at:

| Service | URL | Credentials |
|---------|-----|-------------|
| WordPress | http://wordpress.local:8080 | user: `user`, password: `bitnami` |
| Grafana | http://grafana.local:3000 | user: `admin`, password: `admin` |
| WikiJS | http://wiki.local:3000 | Configure on first access |
| Prometheus | http://prometheus.local:9090 | No authentication |
| VNC Web UI | http://vm.local:6901 | password: `vncpassword` |

### File Sharing

- **FTP**: Connect to `ftp.local` with users `user1`/`user2`, password: `garlictomatofood`
- **Samba**: Connect to `smb.local` with users `Benutzer1`/`Benutzer2`, password: `garlictomatofood`

## 🔧 Management

### Updates

To update the infrastructure:

```bash
docker-compose down
git pull
docker-compose pull
docker-compose up -d
```

### ARM64 Support

For ARM64 systems (Raspberry Pi, Ampere Altra), modify the Unbound service in `docker-compose.yml`:

```yaml
# Comment out line 68:
# image: "mvance/unbound:latest"

# Uncomment line 69:
image: "mvance/unbound-rpi:latest"
```

## 🌐 Network Configuration

The infrastructure uses a custom Docker bridge network:
- **IPv4**: 10.13.12.0/24
- **IPv6**: fd69:acab:1312::/64

### Service IP Addresses

| Service | Hostname | IPv4 | IPv6 | Port |
|---------|----------|------|------|------|
| WordPress | wordpress.local | 10.13.12.42 | fd69:acab:1312::42 | 8080 |
| MariaDB | mariadb.local | 10.13.12.50 | fd69:acab:1312::50 | 3306 |
| FTP | ftp.local | 10.13.12.116 | IPv6 issues | 20, 21 |
| VNC/Client | vm.local | 10.13.12.55 | fd69:acab:1312::55 | 5901, 6901 |
| DNS | unbound.local | 10.13.12.69 | fd69:acab:1312::69 | 53 |
| Grafana | grafana.local | 10.13.12.99 | fd69:acab:1312::99 | 3000 |
| Prometheus | prometheus.local | 10.13.12.98 | fd69:acab:1312::98 | 9090 |
| Node Exporter | node-exporter.local | 10.13.12.97 | fd69:acab:1312::97 | 9100 |
| PostgreSQL | db.local | 10.13.12.96 | fd69:acab:1312::96 | 5432 |
| WikiJS | wiki.local | 10.13.12.75 | fd69:acab:1312::75 | 3000 |
| Samba | smb.local | 10.13.12.23 | fd69:acab:1312::23 | 445 |

## 🔍 Monitoring & Debugging

### Wireshark Analysis

To use Wireshark in the Debian VM:
```bash
wireshark -i eth0
```
- Filter out VNC traffic for cleaner analysis
- Monitor interface `eth0` of the `vm_debian` container

### Log Access

View logs for any service:
```bash
docker-compose logs [service-name]
```

Example:
```bash
docker-compose logs wordpress
docker-compose logs grafana
```

## 🔒 Security Considerations

⚠️ **Important**: This setup is designed for learning purposes and includes several security compromises:

- Empty passwords are allowed for MariaDB
- Default credentials are used
- Services are exposed without authentication

**Do not use in production environments without proper security hardening.**

## 🛠️ Customization

### DNS Configuration
- A-records: Edit `a-records.conf`
- Forward records: Edit `forward-records.conf`

### Monitoring
- Prometheus config: `prometheus.yml`
- Grafana dashboards: `node_exporter_dashboard.json`

### Storage
Data persistence is handled through Docker volumes:
- `grafana_storage`: Grafana data
- `mariadb_data`: MariaDB database
- `wordpress_data`: WordPress files
- `./wiki_data`: PostgreSQL data (bind mount)

### Environment Variables

Key environment variables that can be customized in `docker-compose.yml`:

| Service | Variable | Default | Description |
|---------|----------|---------|-------------|
| FTP | USERS | user1\|garlictomatofood\|... | FTP user configuration |
| Samba | ACCOUNT_Benutzer1 | garlictomatofood | Samba user password |
| MariaDB | MARIADB_DATABASE | bitnami_wordpress | Database name |
| PostgreSQL | POSTGRES_PASSWORD | wikijsrocks | Database password |

## 🚨 Troubleshooting

### Common Issues

1. **Services not accessible**: Check if all containers are running:
   ```bash
   docker-compose ps
   ```

2. **DNS resolution issues**: Verify the DNS server is running:
   ```bash
   docker-compose logs unbound
   ```

3. **ARM64 compatibility**: Ensure you've switched to the ARM64 Unbound image

4. **Port conflicts**: Check for conflicts with existing services on your host

### Reset Infrastructure

To completely reset the infrastructure:
```bash
docker-compose down -v
docker-compose up -d
```

## 📚 Additional Documentation

- [German Documentation](./Doku.md) - Detailed German documentation
- [Network Diagram](./docs/res/Netzplan.svg) - Visual network overview
- [Project Structure](./docs/Projektstrukturdiagramm.svg) - Project structure diagram

## 🤝 Contributing

This is a learning project. Feel free to fork and modify for your own educational purposes.

## 📄 License

This project is for educational purposes. Check individual service licenses for production use.