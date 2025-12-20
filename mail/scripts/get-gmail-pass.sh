#!/bin/bash
# Retrieve Gmail password from macOS Keychain
# This is more reliable than GPG/pass for mail sync

# Try to get password from Keychain
security find-internet-password -s "imap.gmail.com" -a "jerome.faria@gmail.com" -w 2>/dev/null
