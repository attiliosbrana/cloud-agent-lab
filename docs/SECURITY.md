# Security and Operations

- Store credentials outside git. Prefer Secret Manager or VM-level env files.
- Rotate keys after any exposure; audit usage and logs.
- Use read-only tokens for data access (e.g., Supabase). Enforce RLS.
- Limit inbound network access; stop VMs when idle to reduce attack surface.
- Maintain agent logs (redact PII) and basic health checks.
