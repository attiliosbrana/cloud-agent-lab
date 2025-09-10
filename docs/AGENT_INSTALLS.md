# Gemini CLI with Supabase MCP - Cloud Deployment Guide

## 🎉 Successfully Deployed!

Your Gemini CLI with Supabase MCP integration is now fully deployed and configured on Google Cloud VM:

- **VM Name**: `gemini-cli-vm`
- **Zone**: `us-central1-a`
- **Project**: `<PROJECT_ID>`
- **External IP**: `<VM_EXTERNAL_IP>`

## 🚀 How to Use

### 1. Connect to Your Cloud Instance

```bash
gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>
```

### 2. Start Gemini with Full Environment

```bash
# Use the convenient startup script that sets up all environment variables
~/start-gemini-with-env.sh

# Or run specific queries directly
~/start-gemini-with-env.sh -p "What tables are in the database?"
~/start-gemini-with-env.sh -p "How many appointments do we have?"
```

### 3. Manual Environment Setup (if needed)

```bash
export GEMINI_API_KEY=<YOUR_GEMINI_API_KEY>
export SUPABASE_ACCESS_TOKEN=<YOUR_SUPABASE_ACCESS_TOKEN>
export SUPABASE_PROJECT_REF=<YOUR_SUPABASE_PROJECT_REF>
export SUPABASE_URL=<YOUR_SUPABASE_URL>
export SUPABASE_ANON_KEY=<YOUR_SUPABASE_ANON_KEY>

# Then use gemini normally
gemini -p "Your query here"
```

## 🔧 What's Configured

### MCP Server Status
- ✅ **Supabase MCP server**: Connected and ready
- ✅ **Database access**: Read-only permissions to clinic data
- ✅ **Environment variables**: All credentials from .env file transferred

### Available Commands
```bash
# Check MCP server status
gemini mcp list

# Interactive mode
gemini

# Direct queries
gemini -p "Show me the database schema"
gemini -p "How many appointments are scheduled for this week?"
gemini -p "What are the most common appointment types?"
gemini -p "Generate a patient visit frequency report"
```

## 🎯 Example Analytics Queries

```bash
# Database exploration
~/start-gemini-with-env.sh -p "What tables and views are available?"

# Appointment analytics  
~/start-gemini-with-env.sh -p "How many appointments do we have this month?"
~/start-gemini-with-env.sh -p "What's the ratio of online vs in-person appointments?"

# Patient insights
~/start-gemini-with-env.sh -p "Show me patient visit patterns"
~/start-gemini-with-env.sh -p "What are the peak appointment hours?"

# Reports
~/start-gemini-with-env.sh -p "Create a summary report of our appointment data"
```

## 💡 Key Features

- **Remote Access**: Available from anywhere with internet connection
- **Secure Authentication**: Uses your Supabase read-only tokens
- **MCP Integration**: Direct database queries through Model Context Protocol
- **Analytics Ready**: Can generate SQL queries, reports, and insights
- **Persistent Environment**: All credentials configured and ready to use

## 🛠 Management Commands

### VM Management
```bash
# Start the VM
gcloud compute instances start gemini-cli-vm --zone=us-central1-a

# Stop the VM (to save costs)
gcloud compute instances stop gemini-cli-vm --zone=us-central1-a

# Check VM status
gcloud compute instances list --filter="name:gemini-cli-vm"
```

### Access Methods
1. **SSH via gcloud** (recommended):
   ```bash
   gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>
   ```

2. **Direct SSH** (if you prefer):
   ```bash
   ssh -i ~/.ssh/google_compute_engine <USERNAME>@<VM_EXTERNAL_IP>
   ```

## 🔐 Security Notes

- **Environment Variables**: All sensitive credentials are properly set up
- **Read-Only Access**: Supabase token has read-only permissions
- **VM Security**: Protected by Google Cloud's security infrastructure
- **SSH Access**: Secured with SSH keys managed by Google Cloud

## ✅ Verification

The deployment has been tested and confirmed working:
- ✅ Gemini CLI v0.3.4 installed
- ✅ Node.js v20.19.5 (required version)
- ✅ Supabase MCP server connected
- ✅ Environment variables configured
- ✅ Database connectivity verified

Your cloud-deployed Gemini CLI with Supabase MCP integration is ready for use! 🎉