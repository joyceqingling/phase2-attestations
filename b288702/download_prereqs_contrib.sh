#!/usr/bin/env bash

# This script downloads the files needed to verify a contribution.
#
# Inputs are a proof type and a sector size and the contribution to verify.
set -e

script_name=$(basename "$0")

if [ "${#}" -ne 3 ]; then
    echo "Download files needed to verify a contribution."
    echo "The 'contribution' parameter is a numeric value."
    echo ""
    echo "Usage: ${script_name} {sdr|window|winning} {32|64} [contribution]"
    exit 1
fi

if ! command -v b2sum >/dev/null 2>&1
then
    echo "ERROR: 'b2sum' needs to be installed."
    exit 1
fi

if ! command -v curl >/dev/null 2>&1
then
    echo "ERROR: 'curl' needs to be installed."
    exit 1
fi

if ! command -v gpg >/dev/null 2>&1
then
    echo "ERROR: 'gpg' needs to be installed."
    exit 1
fi

proof="$1"
sector_size="$2"
contrib="$3"

magenta='\u001b[35;1m'
red='\u001b[31;1m'
off='\u001b[0m'

function log() {
    echo -e "${magenta}[${script_name}]${off} $1"
}

function error() {
    echo -e "${magenta}[${script_name}] ${red}error:${off} $1"
}

if [[ $proof != 'winning' && $proof != 'sdr' && $proof != 'window' ]]; then
    error "invalid proof: '${proof}'"
    exit 1
fi

if [[ $sector_size != '32' && $sector_size != '64' ]]; then
    error "invalid sector-size: '${sector_size}'"
    exit 1
fi

# The number of Phase 2 contributions.
if [[ $proof == 'winning' ]]; then
    n='20'
elif [[ $proof == 'window' ]]; then
    n='15'
elif [[ $sector_size == '32' ]]; then
    n='17'
else
    n='16'
fi

if [[ -z $contrib || $contrib -lt 2 || $contrib  -gt $n ]]; then
    error "invalid contrib: ${contrib}"
    exit 1
fi

# Once everything is pinned to IPFS, it will be a single location for all
# the files
url_base='https://trusted-setup.s3.amazonaws.com/phase2-mainnet'

# Get the file containing checksums of the parameter files.
if [[ ! -f './b288702.b2sums' ]]; then
    log "downloading checksums for parameters: b288702.b2sums"
    curl --progress-bar -O "${url_base}/b288702.b2sums"
fi
log 'verifying parameters checksums file checksum'
echo "7931ca92df34bf0b6217692daaf2d92135fceb6caae344b10712ee997717cc612435b0a6e1e61325d5abaa62044b6f6359fd44bbe3dc4e111536bcad43c2e0ec b288702.b2sums" | b2sum -c

# Get the keyring with the public GPG keys to verify the signatures of the
# contributions and put it into a local keyring.
if [[ ! -f './keyring.asc' ]]; then
    log "downloading keyring with public GPG keys: keyring.asc"
    curl --progress-bar -O "${url_base}/keyring.asc"
fi
log 'verifying keyring with public GPG keys checksum'
echo "5933fa0cebe764e02fbd394108af50169336bef01809df3d9004a0fe494bb0c48f1d67334b6b9de67b5185d0c0db78c01263d57675ce433df00a21258c845c8f keyring.asc" | b2sum -c
if [[ ! -f './keyring.gpg' ]]; then
    gpg --no-default-keyring --keyring ./keyring.gpg --import keyring.asc
else
    log "keyring.gpg already exists, skip importing the keys"
fi

# The parameters of the previous contributions are needed in order to verify
# the current contribution. In case this file wasn't created by a previous
# verification step, the file is downloaded.
prev=$((contrib - 1))
prev_file="${proof}_poseidon_${sector_size}gib_b288702_${prev}_small_raw"
if [[ ! -f ${prev_file} ]]; then
    log "downloading params: ${file}"
    curl --progress-bar -O "${url_base}/${prev_file}"
fi
# Verify checksum even if file was present, in case of incomplete download or corruption.
# This is especially relevant if another process might have initiated a download now in process.
log 'verifying downloaded params checksum'
grep "$prev_file" b288702.b2sums | b2sum -c

# Download the parameters of the contributions that should get verified
file="${proof}_poseidon_${sector_size}gib_b288702_${contrib}_small_raw"
if [[ ! -f ${file} ]]; then
    log "downloading params: ${file}"
    curl --progress-bar -O "${url_base}/${file}"
fi
log 'verifying downloaded params checksum'
grep "$file" b288702.b2sums | b2sum -c

contrib_file="${file}.contrib"
if [[ ! -f ${contrib_file} ]]; then
    log "downloading contrib: ${contrib_file}"
    curl --progress-bar -O "${url_base}/${contrib_file}"
fi

sig_file="${file}.contrib.sig"
if [[ ! -f ${sig_file} ]]; then
    log "downloading signature: ${sig_file}"
    curl --progress-bar -O "${url_base}/${sig_file}"
fi
