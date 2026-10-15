#!/bin/bash
# Create the self-signed code-signing certificate used by tools/omniwm/build-local.sh (run once per Mac).
#
#   tools/omniwm/create-signing-cert.sh            create "$OMNIWM_CERT" in the login keychain
#   KEYCHAIN=/path/test.keychain-db tools/omniwm/create-signing-cert.sh   (tests: any keychain)
#
# Why: macOS ties the Accessibility / Screen Recording grants of OmniWM to its code signature. An
# ad-hoc signature changes on every build, so every rebuild would silently lose the permissions;
# a stable certificate keeps them. The key never leaves this Mac; nothing is trusted system-wide.
# macOS may ask for the login keychain password (that prompt is yours to answer).
# Undo: Keychain Access > login > My Certificates > delete "OmniWM Local Signing".
set -euo pipefail
CERT="${OMNIWM_CERT:-OmniWM Local Signing}"
KEYCHAIN="${KEYCHAIN:-$HOME/Library/Keychains/login.keychain-db}"
if security find-identity -p codesigning "$KEYCHAIN" | grep -q "\"$CERT\""; then
  echo "Certificate \"$CERT\" already present: nothing to do."; exit 0
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/cert.cnf" <<EOF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $CERT
[ext]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
EOF
/usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -config "$tmp/cert.cnf" \
  -keyout "$tmp/key.pem" -out "$tmp/cert.pem" 2>/dev/null
pass="$(/usr/bin/openssl rand -hex 16)"
/usr/bin/openssl pkcs12 -export -inkey "$tmp/key.pem" -in "$tmp/cert.pem" -name "$CERT" \
  -passout "pass:$pass" -out "$tmp/id.p12" 2>/dev/null \
  || /usr/bin/openssl pkcs12 -export -legacy -inkey "$tmp/key.pem" -in "$tmp/cert.pem" -name "$CERT" \
       -passout "pass:$pass" -out "$tmp/id.p12"
# -T /usr/bin/codesign: only codesign may use the private key without a prompt.
security import "$tmp/id.p12" -k "$KEYCHAIN" -P "$pass" -T /usr/bin/codesign >/dev/null
security find-identity -p codesigning "$KEYCHAIN" | grep -q "\"$CERT\"" \
  || { echo "Import done but \"$CERT\" is not listed as a code-signing identity." >&2; exit 1; }
echo "Created \"$CERT\" in $KEYCHAIN (valid 10 years)."
