# Autosim: An FTP-on-VLAN simulator


A secure, isolated FTP server solution leveraging Linux network namespaces and VLAN segmentation for multi-tenant environments.

## Overview

This project implements a multi-instance FTP server system where each FTP service runs in its own isolated network namespace with dedicated VLAN interfaces. This provides complete network isolation between different tenant environments while maintaining centralized management.

## Project Status

Current development progress and roadmap: [Development Progress](docs/DEVELOPMENT.md)


## Key Features

- **Network Isolation**: Each FTP instance runs in separate Linux network namespace
- **VLAN Support**: Dedicated VLAN interfaces for layer-2 network segmentation  
- **Multi-Tenant Architecture**: Isolated environments for different clients/departments
- **Centralized Management**: Single control point for all FTP instances
- **Security First**: Complete network separation prevents cross-tenant access
- **Scalable Design**: Easy to add new VLAN-based FTP instances

## Architecture

```
┌────────────────┐    ┌───────────────────┐    ┌─────────────────┐
│  Client VLAN10 │────│ Namespace: vlan10 │────│ FTP Service #1  │
│  192.168.10.x  │    │ IP: 192.168.10.10 │    │ Port: 2121      │
└────────────────┘    └───────────────────┘    └─────────────────┘
                                │
┌────────────────┐    ┌───────────────────┐    ┌─────────────────┐
│  Client VLAN20 │────│ Namespace: vlan20 │────│ FTP Service #2  │
│  192.168.20.x  │    │ IP: 192.168.20.10 │    │ Port: 2122      │
└────────────────┘    └───────────────────┘    └─────────────────┘
```

## Prerequisites

- **OS**: Linux distribution with kernel ≥ 3.10
- **Privileges**: Root access or CAP_NET_ADMIN capability
- **Dependencies**: 
  - Go 1.19+
  - iproute2 package
  - Standard networking tools

## Quick Start

### 1. Install Dependencies

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y iproute2 net-tools golang-go

# CentOS/RHEL  
sudo yum install -y iproute net-tools golang
```

### 2. Build the Project

```bash
git clone <repository-url>
cd vlan-ftp-server
go build -o vlan-ftp-server ./cmd/vlan-ftp-server
```

### 3. Configure System Permissions

```bash
# Grant network administration capabilities
sudo setcap cap_net_admin+ep vlan-ftp-server

# Create data directories
sudo mkdir -p /data/vlan10 /data/vlan20
sudo chown -R $USER:$USER /data/vlan10 /data/vlan20
```

### 4. Configure FTP Instances

Edit `configs/config.yaml`:

```yaml
server:
  base_port: 2121
  
instances:
  - id: "vlan10-ftp"
    namespace: "vlan10-ns"
    vlan_id: 10
    ip_address: "192.168.10.10/24"
    port: 2121
    root_dir: "/data/vlan10"
    
  - id: "vlan20-ftp"  
    namespace: "vlan20-ns"
    vlan_id: 20
    ip_address: "192.168.20.10/24"
    port: 2122
    root_dir: "/data/vlan20"
```

### 5. Start Services

```bash
# Using configuration file
sudo ./vlan-ftp-server -config configs/config.yaml

# Or specify custom config
sudo ./vlan-ftp-server -config /path/to/your/config.yaml
```

## Usage Examples

### Check Running Instances

```bash
# List network namespaces
sudo ip netns list

# Verify VLAN interfaces
sudo ip netns exec vlan10-ns ip addr show
sudo ip netns exec vlan20-ns ip addr show
```

### Access FTP Services

```bash
# Connect to VLAN10 FTP (from VLAN10 network)
ftp 192.168.10.10 2121

# Connect to VLAN20 FTP (from VLAN20 network)  
ftp 192.168.20.10 2122
```

### Debug Network Issues

```bash
# Enter namespace for debugging
sudo ip netns exec vlan10-ns bash

# Test connectivity from within namespace
ping -c 3 192.168.10.1
ip route show
```

## Project Structure

```
vlan-ftp-server/
├── cmd/vlan-ftp-server/     # Main application entrypoint
├── internal/
│   ├── network/             # Network namespace & VLAN management
│   ├── ftp/                # FTP server implementation
│   ├── config/             # Configuration loading
│   └── manager/            # Instance lifecycle management
├── pkg/utils/               # Shared utilities
├── configs/                 # Configuration files
├── deployments/             # Deployment scripts
└── docs/                    # Additional documentation
```

## Security Considerations

- **Network Isolation**: Each tenant completely isolated at network level
- **Root Privileges**: Service requires elevated privileges for namespace management
- **Access Control**: Implement proper filesystem permissions for FTP roots
- **Monitoring**: Regular audit of namespace and VLAN configurations
- **Backup Strategy**: Isolate backups per VLAN/namespace

## Troubleshooting

### Common Issues

**Permission Denied Errors**
```bash
# Ensure proper capabilities are set
sudo setcap cap_net_admin+ep vlan-ftp-server
```

**Namespace Creation Failures**
```bash
# Check if namespaces already exist
sudo ip netns list
# Clean up existing namespaces if needed
sudo ip netns del vlan10-ns
```

**VLAN Interface Issues**
```bash
# Verify physical interface supports VLAN tagging
sudo ethtool -k eth0 | grep vlan
```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.