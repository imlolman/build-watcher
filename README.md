# Build Watcher

A lightweight, automated deployment watcher service that monitors trigger files and executes deployment scripts for multiple user accounts on a Linux server.

## 🚀 Quick Setup

### One-Line Installation (from GitHub)

```bash
curl -fsSL https://raw.githubusercontent.com/imlolman/build-watcher/refs/heads/main/install.sh | sudo bash
```

### Manual Installation (from local files)

```bash
# Clone the repository
git clone https://github.com/imlolman/build-watcher.git
cd build-watcher

# Run the installer
sudo bash install.sh
```

## 📋 What It Does

Build Watcher is a background service that:

1. **Monitors Deployment Triggers**: Continuously watches for deployment trigger files at `/home/*/public_html/deploy`

2. **Automatic Execution**: When a trigger file is detected:
   - Validates that a `deploy.sh` script exists in the user's project directory
   - Executes the deployment script with the real user's username as an argument
   - Logs all deployment activities to `storage/logs/deploy.log`

3. **Permission Management**: Automatically fixes ownership permissions for the `public` directory after deployment

4. **Multi-User Support**: Handles deployments for multiple user accounts simultaneously

5. **Clean-Up**: Removes trigger files after processing and maintains clean operation

### How It Works

```
┌─────────────────┐
│ Trigger File    │
│ Created at:     │
│ /home/user/     │
│ public_html/    │
│ deploy          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Build Watcher   │
│ Detects File    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Execute         │
│ deploy.sh       │
│ (as real user)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Log Results &   │
│ Fix Permissions │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Remove Trigger  │
│ File            │
└─────────────────┘
```

## 🛠️ Manual Setup (Advanced)

If you prefer to install components individually:

### 1. Install the Script

```bash
sudo curl -fsSL https://raw.githubusercontent.com/imlolman/build-watcher/refs/heads/main/build-watcher.sh \
  -o /usr/local/bin/build-watcher.sh
sudo chmod +x /usr/local/bin/build-watcher.sh
```

### 2. Install the Service

```bash
sudo curl -fsSL https://raw.githubusercontent.com/imlolman/build-watcher/refs/heads/main/build-watcher.service \
  -o /etc/systemd/system/build-watcher.service
```

### 3. Enable and Start

```bash
sudo systemctl daemon-reload
sudo systemctl enable build-watcher
sudo systemctl start build-watcher
```

## 📊 Management Commands

### Service Control

```bash
# Check service status
sudo systemctl status build-watcher

# View live logs
sudo journalctl -u build-watcher -f

# Stop the service
sudo systemctl stop build-watcher

# Start the service
sudo systemctl start build-watcher

# Restart the service
sudo systemctl restart build-watcher

# Disable auto-start on boot
sudo systemctl disable build-watcher
```

### Triggering a Deployment

To trigger a deployment for a specific user:

```bash
# Create a trigger file
touch /home/username/public_html/deploy
```

The watcher will detect this file within 2 seconds and execute the deployment.

## 📁 File Structure

```
/usr/local/bin/build-watcher.sh          # Main watcher script
/etc/systemd/system/build-watcher.service # Systemd service definition

/home/[user]/public_html/
├── deploy                                # Trigger file (created to start deployment)
├── deploy.sh                            # User's deployment script (must exist)
├── public/                              # Directory with auto-fixed permissions
└── storage/logs/deploy.log              # Deployment logs
```

## ⚙️ Configuration

Edit `/usr/local/bin/build-watcher.sh` to customize:

```bash
FILE_PATTERN_TO_WATCH="/home/*/public_html/deploy"  # Where to watch for triggers
LOG_FILE_PATH="storage/logs/deploy.log"             # Log location (relative)
PERMISSION_UPDATE_PATH="public"                     # Directory for permission fixes
```

After making changes, restart the service:

```bash
sudo systemctl restart build-watcher
```

## 🔒 Security Notes

- The service runs as `root` to manage multiple user directories
- Each deployment script runs with the context of the real user
- Permissions are automatically corrected after deployment
- All activities are logged for audit purposes

## 🐛 Troubleshooting

### Service won't start

```bash
# Check for errors
sudo journalctl -u build-watcher -n 50

# Verify the script is executable
ls -l /usr/local/bin/build-watcher.sh
```

### Deployment not triggering

1. Ensure `deploy.sh` exists in the user's `public_html` directory
2. Check the trigger file is being created at the correct path
3. Monitor logs: `sudo journalctl -u build-watcher -f`

### Permission issues

The script automatically fixes permissions for the `public` directory. If you need to change which directory gets permission fixes, edit the `PERMISSION_UPDATE_PATH` variable.

## 📝 Requirements

- Linux server with systemd
- Root access for installation
- User directories at `/home/[username]/public_html/`
- Deployment scripts at `/home/[username]/public_html/deploy.sh`

## 📄 License

Open source - feel free to modify and distribute.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

---

**Made with ❤️ for simplified deployments**




