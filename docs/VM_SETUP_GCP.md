# Provisioning a Free‑Tier GCP VM for CLI Agents

This guide shows how to create an Ubuntu `e2-micro` VM on Google Cloud, connect via SSH, and prepare it for CLI coding agents. It pairs with `docs/VM_MULTI_AGENT_SETUP_PLAN.md`.

## Prerequisites

1.  A Google Cloud Platform account.
2.  The `gcloud` command-line tool installed and authenticated on your local machine.

## Step-by-Step Guide

The goal is to create a small, low‑cost remote development VM suitable for single‑agent workflows.

### 1. Enable Required APIs

Enable these APIs for the GCP project `<PROJECT_ID>`:

-   **Compute Engine API**: The core API for creating and managing VMs.
    ```bash
    gcloud services enable compute.googleapis.com --project=<PROJECT_ID>
    ```
-   **Network Management API**: Required for advanced network diagnostics, which was used for troubleshooting the SSH connection.
    ```bash
    gcloud services enable networkmanagement.googleapis.com --project=<PROJECT_ID>
    ```

### 2. Create the Virtual Machine

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

Key flags:
-   `gemini-cli-vm`: The name for our new VM.
-   `--project`: Specifies the GCP project to use.
-   `--zone`: The physical location where the VM is created.
-   `--machine-type=e2-micro`: A small, free-tier eligible machine type.
-   `--image-family=ubuntu-2204-lts` & `--image-project=ubuntu-os-cloud`: Specifies the latest stable version of Ubuntu 22.04 as the operating system.
-   `--metadata=enable-oslogin=TRUE`: Enables a secure and recommended method for managing SSH access.

### 3. Connect via SSH

With the VM running, we connected to it using SSH. The `gcloud` tool handles all the authentication complexity.

```bash
gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>
```
This opens a secure shell session directly into the Ubuntu environment on your VM.

### 4. Install prerequisites and your agent(s)

Once connected, install prerequisites and your desired CLI agent(s).

- If you plan to use Codex/Claude later, install Node.js 22 LTS first:
  ```bash
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
  node -v
  ```

- From the repo root, you can run the bootstrap helper to verify setup and create a convenience symlink:
  ```bash
  ./scripts/bootstrap.sh
  ```

Refer to `docs/VM_MULTI_AGENT_SETUP_PLAN.md` for agent-specific install/usage steps.

## Common Issues

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

## Manage Your VM

Here are the essential commands to manage your new VM from your local machine.

-   **Connect to the VM:**
    ```bash
    gcloud compute ssh gemini-cli-vm --zone=us-central1-a --project=<PROJECT_ID>
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
