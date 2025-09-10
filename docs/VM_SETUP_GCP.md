# Deploying and Accessing the Gemini CLI on Google Cloud

This document outlines the complete process used to deploy the Gemini CLI onto a free-tier Google Cloud Platform (GCP) Virtual Machine (VM), access it remotely, and troubleshoot common setup issues.

## Prerequisites

1.  A Google Cloud Platform account.
2.  The `gcloud` command-line tool installed and authenticated on your local machine.

## Step-by-Step Guide

The goal was to create a remote, accessible instance of the Gemini CLI. We accomplished this by provisioning a new VM and configuring the project along the way.

### 1. Enabling Required APIs

Before creating a VM, several underlying APIs needed to be enabled for the GCP project `<PROJECT_ID>`.

-   **Compute Engine API**: The core API for creating and managing VMs.
    ```bash
    gcloud services enable compute.googleapis.com --project=<PROJECT_ID>
    ```
-   **Network Management API**: Required for advanced network diagnostics, which was used for troubleshooting the SSH connection.
    ```bash
    gcloud services enable networkmanagement.googleapis.com --project=<PROJECT_ID>
    ```

### 2. Creating the Virtual Machine

After enabling the APIs, we created the VM. We encountered and resolved several issues during this process (see Troubleshooting section). The final, successful command was:

```bash
gcloud compute instances create gemini-cli-vm \
    --project=<PROJECT_ID> \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --metadata=enable-oslogin=TRUE
```

**Command Breakdown:**
-   `gemini-cli-vm`: The name for our new VM.
-   `--project`: Specifies the GCP project to use.
-   `--zone`: The physical location where the VM is created.
-   `--machine-type=e2-micro`: A small, free-tier eligible machine type.
-   `--image-family=ubuntu-2204-lts` & `--image-project=ubuntu-os-cloud`: Specifies the latest stable version of Ubuntu 22.04 as the operating system.
-   `--metadata=enable-oslogin=TRUE`: Enables a secure and recommended method for managing SSH access.

### 3. Connecting to the VM

With the VM running, we connected to it using SSH. The `gcloud` tool handles all the authentication complexity.

```bash
gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>
```
This command opens a secure shell session directly into the Ubuntu environment on your new VM.

### 4. Installing the Gemini CLI

Once connected, the final step is to install the Gemini CLI on the remote machine. This step depends on the specific installation method for the CLI.

**Example (replace with your actual installation command):**
```bash
# Example using npm (Node Package Manager)
sudo npm install -g @google/gemini-cli

# Example using pip (Python Package Installer)
pip install -g google-gemini-cli
```

After installation, you can run `gemini` directly from the remote shell.

## Troubleshooting Log

We resolved the following issues during the setup:

1.  **`PERMISSION_DENIED: Compute Engine API has not been used...`**:
    -   **Cause**: The project had never used Compute Engine before.
    -   **Solution**: Enabled the API using `gcloud services enable compute.googleapis.com`.

2.  **`Could not fetch resource: The referenced image resource cannot be found.`**:
    -   **Cause**: The specific OS image version initially used was outdated and no longer available.
    -   **Solution**: Switched from a specific image version to `--image-family=ubuntu-2204-lts`, which always points to the latest version.

3.  **`The resource 'serviceAccount' was not found.`**:
    -   **Cause**: The project was new and did not have a default Compute Engine service account. The command was trying to use one that didn't exist.
    -   **Solution**: Removed the `--service-account` flag from the `create` command, allowing GCP to automatically create and assign a new default service account.

4.  **`ssh: connect to host ... port 22: Connection refused`**:
    -   **Cause**: This typically happens when trying to SSH into a VM that has not finished its boot sequence and started the SSH service.
    -   **Solution**: We waited a minute and retried. We also used the `gcloud compute ssh --troubleshoot` command, which required enabling the `networkmanagement.googleapis.com` API but ultimately confirmed the VM was reachable. The final connection attempt was successful.

## How to Manage Your VM

Here are the essential commands to manage your new VM from your local machine.

-   **Connect to the VM:**
    ```bash
    gcloud compute ssh gemini-cli-vm --zone=us-central1-a
    ```

-   **Stop the VM (to prevent incurring charges if you exceed free-tier limits):**
    ```bash
    gcloud compute instances stop gemini-cli-vm --zone=us-central1-a
    ```

-   **Start the VM again:**
    ```bash
    gcloud compute instances start gemini-cli-vm --zone=us-central1-a
    ```

-   **Delete the VM (when you no longer need it):**
    ```bash
    gcloud compute instances delete gemini-cli-vm --zone=us-central1-a
    ```
