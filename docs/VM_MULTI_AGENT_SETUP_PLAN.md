# Remote Development VM Setup Plan

A comprehensive plan to set up your VM as a remote development environment with gemini-cli, claude-code, and codex, plus GitHub integration.

## **Phase 1: VM Foundation (Already Done ✅)**
Your GCP VM is already provisioned with:
- Ubuntu 22.04 LTS on `e2-micro` instance
- Zone: `us-central1-a`
- Gemini CLI already installed (MCP optional and deferred)

## **Phase 2: Install Additional CLI Tools**

### **2.1 Claude Code CLI**
```bash
# SSH into VM
gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>

# Install Node.js 22 LTS (satisfies Codex >=22 and Claude Code >=18)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node -v

# Install Claude Code CLI (official)
# Option A (preferred for version pinning)
npm install -g @anthropic-ai/claude-code

# Option B (bootstrap installer)
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
claude doctor
```

### **2.2 OpenAI Codex CLI**
```bash
# Install Codex CLI
npm install -g @openai/codex

# Verify installation
codex --version
```

## **Phase 3: GitHub Integration**

### **3.1 Generate SSH Keys on VM**
```bash
# Generate ED25519 SSH key (recommended)
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display public key to copy
cat ~/.ssh/id_ed25519.pub
```

### **3.2 Add SSH Key to GitHub**
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate with GitHub
gh auth login

# Add SSH key to GitHub account
gh ssh-key add ~/.ssh/id_ed25519.pub --title "Cloud Agent Lab VM"

# Test SSH connection
ssh -T git@github.com
```

### **3.3 Configure Git**
```bash
# Set up Git user info
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# Configure SSH for Git
cat >> ~/.ssh/config << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
EOF
```

## **Phase 4: Environment Setup**

### **4.1 Update Environment Variables**
```bash
# Create a private env file used by the launcher
cat > ~/.agents.env << 'EOF'
# Gemini
GEMINI_API_KEY=your-gemini-key

# Optional: Supabase if you plan to use database integrations later
SUPABASE_ACCESS_TOKEN=your-token
SUPABASE_PROJECT_REF=your-ref
SUPABASE_URL=your-url
SUPABASE_ANON_KEY=your-key
EOF

# Restrict permissions
chmod 600 ~/.agents.env
```

### **4.2 Universal Agent Launcher**
```bash
# Use the repo launcher (supports gemini, claude, codex)
cd ~/cloud-agent-lab
scripts/start-agent.sh --agent gemini -p "Hello from Gemini"

# Optional symlink for convenience
ln -sf "$PWD/scripts/start-agent.sh" ~/start-agent
```



## **Phase 5: Repository Integration**

### **5.1 Clone Your Repositories**
```bash
# Clone your cloud-agent-lab repo
cd ~
git clone git@github.com:yourusername/cloud-agent-lab.git

# Clone other project repositories as needed
git clone git@github.com:yourusername/other-project.git
```

## **Phase 6: Development Workflow**

### **6.1 SSH Access Methods**
```bash
# Primary method (from local machine)
gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>

# Direct SSH (if you prefer)
ssh -i ~/.ssh/google_compute_engine username@<VM_EXTERNAL_IP>
```

### **6.2 Usage Examples**
```bash
# Use Gemini for data analysis
~/cloud-agent-lab/scripts/start-agent.sh --agent gemini -p "Analyze the database schema"

# Use Claude for code help
~/cloud-agent-lab/scripts/start-agent.sh --agent claude -p "Review this Python function for bugs"

# Use Codex for shell commands
~/cloud-agent-lab/scripts/start-agent.sh --agent codex "find all Python files modified in the last week"
```

## **Phase 7: Cost Management**

### **7.1 VM Management Commands**
```bash
# Stop VM when not in use (saves money)
gcloud compute instances stop gemini-cli-vm --zone=us-central1-a

# Start VM when needed
gcloud compute instances start gemini-cli-vm --zone=us-central1-a

# Check VM status
gcloud compute instances list --filter="name:gemini-cli-vm"
```

## **Benefits of This Setup**
- **Multi-agent environment**: Switch between Gemini, Claude, and Codex for different tasks
- **Remote accessibility**: Work from anywhere with internet
- **GitHub integration**: Full git workflow with SSH authentication
- **Cost-effective**: Free-tier eligible VM that you can stop when not using
- **Scalable**: Can upgrade VM specs if needed
- **Persistent environment**: All tools and configurations remain between sessions

## **Security Considerations**
- SSH keys with passphrases; restrict SSH to your IP or use IAP
- Secrets in `~/.agents.env` (chmod 600); do not source secrets in `.bashrc`
- VM is isolated from your local machine and can be rebuilt quickly
- Enable UFW, unattended-upgrades, and fail2ban

## **System Requirements Summary**
- **VM**: Ubuntu 22.04 LTS on `e2-micro` (single-agent usage)
- **Node.js**: v22 LTS (Codex CLI ≥22, Claude Code ≥18)
- **Memory**: ~1 GB RAM on e2-micro; add 2 GB swap
- **Storage**: 10GB boot disk (works; prune caches). For comfort, 20–30GB.
- **Network**: Stable internet connection for API calls

## **Phase 1.5: Resource Tuning (Recommended on e2-micro)**
```bash
# Swap to reduce OOM risk (2G)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon -a

# Basic hardening & tools
sudo apt-get update && sudo apt-get install -y unattended-upgrades fail2ban htop tmux
sudo ufw allow OpenSSH && sudo ufw --force enable
```

This plan builds on your existing Gemini CLI setup and transforms your VM into a comprehensive remote development environment with all three AI coding assistants integrated with GitHub.
