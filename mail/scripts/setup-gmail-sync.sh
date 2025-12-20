#!/bin/bash
# Setup Gmail sync with mbsync
# This script helps you configure Gmail app-specific password in macOS Keychain

echo "================================================================"
echo "Gmail Sync Setup for Neomutt + Notmuch"
echo "================================================================"
echo ""
echo "Step 1: Create a Gmail App-Specific Password"
echo "------------------------------------------------------------"
echo "1. Go to: https://myaccount.google.com/apppasswords"
echo "2. Sign in to your Google account (jerome.faria@gmail.com)"
echo "3. Click 'Select app' and choose 'Mail'"
echo "4. Click 'Select device' and choose 'Mac'"
echo "5. Click 'Generate'"
echo "6. Copy the 16-character password (it will look like: xxxx xxxx xxxx xxxx)"
echo ""
echo "Press Enter when you have the app-specific password ready..."
read

echo ""
echo "Step 2: Store Password in macOS Keychain"
echo "------------------------------------------------------------"
echo "Enter your Gmail app-specific password (it will be stored securely):"
read -s app_password

# Remove spaces from the password
app_password=$(echo "$app_password" | tr -d ' ')

# Store in macOS Keychain
security add-internet-password \
  -a "jerome.faria@gmail.com" \
  -s "imap.gmail.com" \
  -w "$app_password" \
  -r "imap" \
  -l "Gmail IMAP (jerome.faria@gmail.com)" \
  2>/dev/null

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Password stored successfully in Keychain!"
else
  echo ""
  echo "⚠️  Password may already exist in Keychain. Trying to update..."
  # Delete existing and add new
  security delete-internet-password -s "imap.gmail.com" -a "jerome.faria@gmail.com" 2>/dev/null
  security add-internet-password \
    -a "jerome.faria@gmail.com" \
    -s "imap.gmail.com" \
    -w "$app_password" \
    -r "imap" \
    -l "Gmail IMAP (jerome.faria@gmail.com)"
  echo "✅ Password updated in Keychain!"
fi

echo ""
echo "Step 3: Test Connection"
echo "------------------------------------------------------------"
echo "Testing mbsync connection to Gmail..."

# Test the password retrieval
test_pass=$($HOME/dotfiles/mail/scripts/get-gmail-pass.sh)
if [ -n "$test_pass" ]; then
  echo "✅ Password retrieval works!"

  echo ""
  echo "Testing Gmail connection..."
  timeout 30 mbsync -V gmail-inbox 2>&1 | grep -E "Logging in|Opening|Selecting|Syncing" | head -10

  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ Connection successful!"
    echo ""
    echo "Step 4: Initial Sync"
    echo "------------------------------------------------------------"
    echo "Ready to perform initial mail sync. This may take a while."
    echo "Do you want to sync all mail now? (y/n)"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo ""
      echo "Starting full sync... (this may take 10-30 minutes depending on mail volume)"
      mbsync -V gmail
      echo ""
      echo "✅ Initial sync complete!"
      echo ""
      echo "Step 5: Index with Notmuch"
      echo "------------------------------------------------------------"
      cd ~/.local/share/mail/gmail
      notmuch new
      echo ""
      echo "✅ Mail indexed!"
      echo ""
      echo "================================================================"
      echo "Setup Complete! 🎉"
      echo "================================================================"
      echo ""
      echo "Next steps:"
      echo "1. Run 'mbsync gmail' periodically to sync mail"
      echo "2. Run 'notmuch new' after sync to index new mail"
      echo "3. Start neomutt to use your offline mail"
      echo ""
      echo "TIP: A sync script has been created for you."
      echo "================================================================"
    fi
  else
    echo ""
    echo "⚠️  Connection test timed out or failed."
    echo "Please check your internet connection and try again."
  fi
else
  echo "❌ Password retrieval failed. Please check Keychain Access."
fi
