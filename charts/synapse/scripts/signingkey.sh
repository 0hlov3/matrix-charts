#!/bin/sh

set -eu

# Function to check if a signing key exists in the Kubernetes secret
check_key() {
  set +e
  echo "Checking for existing signing key..."

  key=$(kubectl get secret "${SECRET_NAME}" -o jsonpath="{.data['signing\.key']}" 2>/dev/null)

  # Check if the key retrieval command failed or if the key is empty
  if [ $? -ne 0 ]; then
    return 1
  elif [ -z "$key" ]; then
    return 2
  fi

  return 0
}

# Function to wait for a new signing key to be generated
create_key() {
  echo "Waiting for new signing key to be generated..."

  start_time=$(date +%s)
  timeout=$((start_time + 300)) # 5 minutes timeout

  while true; do
    # Exit the loop if the key file is found
    if [ -f /synapse/keys/signing.key ]; then
      return 0
    fi

    # Check if we've exceeded the timeout
    if [ "$(date +%s)" -gt "$timeout" ]; then
      return 1
    fi

    sleep 5
  done
}

# Function to store the signing key in a Kubernetes secret
store_key() {
  echo "Storing signing key in Kubernetes secret..."
  encoded_key=$(base64 /synapse/keys/signing.key | tr -d '\n')

  kubectl patch secret "${SECRET_NAME}" \
    --type=json \
    -p "[{\"op\":\"replace\", \"path\":\"/data/signing.key\", \"value\":\"${encoded_key}\"}]"
}

# Main script execution
if check_key; then
  echo "Key already in place, exiting."
  exit 0
fi

if ! create_key; then
  echo "Timed out waiting for a signing key to appear."
  exit 1
fi

store_key