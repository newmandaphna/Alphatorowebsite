#!/usr/bin/env python3
import os
import sys
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_HOST = os.environ.get("SMTP_HOST", "")
SMTP_PORT = int(os.environ.get("SMTP_PORT", "587"))
SMTP_USER = os.environ.get("SMTP_USER", "")
SMTP_PASSWORD = os.environ.get("SMTP_PASSWORD", "")
TO_EMAIL = "adaphna@alphatoro.us"

if not all([SMTP_HOST, SMTP_USER, SMTP_PASSWORD]):
    sys.exit(0)

branch = sys.argv[1] if len(sys.argv) > 1 else "unknown"
timestamp = sys.argv[2] if len(sys.argv) > 2 else ""
error_output = sys.argv[3] if len(sys.argv) > 3 else ""

subject = f"[GitHub Sync] Push failed on branch '{branch}'"
body = f"""GitHub sync failed.

Branch:    {branch}
Time:      {timestamp}

Error output:
{error_output}

Check github-sync-status.log for the full history.
"""

msg = MIMEMultipart()
msg["From"] = SMTP_USER
msg["To"] = TO_EMAIL
msg["Subject"] = subject
msg.attach(MIMEText(body, "plain"))

try:
    with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
        server.ehlo()
        server.starttls()
        server.login(SMTP_USER, SMTP_PASSWORD)
        server.sendmail(SMTP_USER, TO_EMAIL, msg.as_string())
except Exception as e:
    print(f"[GitHub Sync] Failed to send alert email: {e}", file=sys.stderr)
    sys.exit(0)
