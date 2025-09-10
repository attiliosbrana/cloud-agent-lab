# Remote Development VM Setup Plan

A comprehensive plan to set up your VM as a remote development environment with gemini-cli, claude-code, and codex, plus GitHub integration.

## **Phase 1: VM Foundation (Already Done ✅)**
Your GCP VM is already provisioned with:
- Ubuntu 22.04 LTS on `e2-micro` instance
- Zone: `us-central1-a`
- Gemini CLI already installed and configured with MCP

## **Phase 2: Install Additional CLI Tools**

### **2.1 Claude Code CLI**
```bash
# SSH into VM
gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>

# Install Node.js 18+ (required for Claude Code)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash
# OR via npm: npm install -g @anthropic-ai/claude-code

# Verify installation
claude doctor
```

### **2.2 OpenAI Codex CLI**
```bash
# Install Codex CLI
npm install -g @openai/codex

# Set up environment variable (add to ~/.bashrc)
echo 'export OPENAI_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc

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
# Add all API keys to .env file
cat >> ~/.env << EOF
# OpenAI
OPENAI_API_KEY=your-openai-key

# Anthropic (if not already set)
ANTHROPIC_API_KEY=your-anthropic-key

# Gemini (already configured)
GEMINI_API_KEY=your-gemini-key
SUPABASE_ACCESS_TOKEN=your-token
SUPABASE_PROJECT_REF=your-ref
SUPABASE_URL=your-url
SUPABASE_ANON_KEY=your-key
EOF

# Source environment in .bashrc
echo 'source ~/.env' >> ~/.bashrc
```

### **4.2 Create Universal Agent Launcher**
```bash
# Create a universal script to launch any agent
cat > ~/start-agent.sh << 'EOF'
#!/bin/bash
source ~/.env 2>/dev/null || true

case "$1" in
    gemini)
        shift
        ~/start-gemini-with-env.sh "$@"
        ;;
    claude)
        shift
        claude "$@"
        ;;
    codex)
        shift
        codex "$@"
        ;;
    *)
        echo "Usage: $0 {gemini|claude|codex} [options]"
        exit 1
        ;;
esac
EOF

chmod +x ~/start-agent.sh
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
~/start-agent.sh gemini -p "Analyze the database schema"

# Use Claude for code help
~/start-agent.sh claude -p "Review this Python function for bugs"

# Use Codex for shell commands
~/start-agent.sh codex "find all Python files modified in the last week"
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
- SSH keys provide secure authentication
- Environment variables keep API keys safe
- VM is isolated from your local machine
- Can be easily destroyed and recreated if compromised

## **System Requirements Summary**
- **VM**: Ubuntu 22.04 LTS (already provisioned)
- **Node.js**: v18+ for Claude Code CLI
- **Memory**: 4GB minimum (8GB recommended)
- **Storage**: 10GB boot disk (already configured)
- **Network**: Stable internet connection for API calls

This plan builds on your existing Gemini CLI setup and transforms your VM into a comprehensive remote development environment with all three AI coding assistants integrated with GitHub.