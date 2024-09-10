#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/BidyutRoy2/BidyutRoy2/main/logo.sh | bash
echo "-----------------------------------------------------------------------------"

BOLD_PINK='\033[1;35m'
RESET='\033[0m'

function show {
    echo -e "${BOLD_PINK}$1${RESET}"
}

function quit_existing_screen_session {
    if screen -list | grep -q "cysic"; then
        show "A screen session named 'cysic' already exists. Quitting the existing session..."
        screen -S cysic -X quit
    fi
}

if ! command -v screen &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y screen
fi

if ! command -v curl &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y curl
fi

if [ -d "$HOME/cysic-verifier" ]; then
    show "Directory 'cysic-verifier' found."
    read -p "Do you want to delete it? (y/N): " response
    if [[ "$response" =~ ^[yY]$ ]]; then
        show "Deleting the directory..."
        rm -rf "$HOME/cysic-verifier"
    else
        show "Skipping deletion."
        exit 1
    fi
fi

mkdir -p "$HOME/cysic-verifier"

show "Downloading verifier..."
curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > "$HOME/cysic-verifier/verifier"

show "Downloading libzkp.so..."
curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > "$HOME/cysic-verifier/libzkp.so"

read -p "Enter EVM address to claim reward: " EVM_ADDRESS

cat <<EOF > "$HOME/cysic-verifier/config.yaml"
chain:
  endpoint: "testnet-node-1.prover.xyz:9090"
  chain_id: "cysicmint_9000-1"
  gas_coin: "cysic"
  gas_price: 10
claim_reward_address: "$EVM_ADDRESS"

server:
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

cd "$HOME/cysic-verifier" && chmod +x verifier

echo "export LD_LIBRARY_PATH=.:$HOME/miniconda3/lib && export CHAIN_ID=534352 && $HOME/cysic-verifier/verifier" > start.sh

chmod +x start.sh

quit_existing_screen_session

screen -dmS cysic

sleep 3

show "Executing start.sh..."
screen -S cysic -X stuff './start.sh\n'
echo
show "Cysic Verifier has started in the detached screen session named 'cysic'."
