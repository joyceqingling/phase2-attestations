# Filecoin Trusted-Setup Phase2 Attestations

This repo stores the attestation files for participants in Filecoin's Groth16 parameter generation MPC. This repo is specific to the second phase of the MPC, the participant attestations for Filecoin's trusted-setup Phase1/Powers-of-Tau ceremony can be found in this [repo](https://github.com/arielgabizon/perpetualpowersoftau).

## Filecoin Circuit Releases

Each Filecoin circuit release will require a new Phase2 trusted-setup.

| Filecoin Release | Directory |
| :--------------: | :-------: |
| Mainnet          | [b288702](/b288702) |

## Mainnet Circuits

* Circuits frozen at `rust-fil-proofs` commit: `b288702`

1. SDR-PoRep-32GiB (Poseidon)
2. SDR-PoRep-64GiB (Poseidon)
3. Winning-PoSt-32GiB (Poseidon)
4. Winning-PoSt-64GiB (Poseidon)
5. Window-PoSt-32GiB (Poseidon)
6. Window-PoSt-64GiB (Poseidon)

### Participation Requirements

The following are requirements for participating in Filecoin's mainnet Phase 2. Note that runtime varies inversely with the number of CPU threads available.

| Circuit            | RAM Req. | Disk Space Req. | Runtime 96 CPU Threads | Runtime 8 CPU Threads |
| :------------------ | :--------: | :---------------: | :-----------------------: | :---------------------: |
| SDR-PoRep-32GiB    | 6GB      | 52GB            | 45m                    | 6h                    |
| SDR-PoRep-64GiB    | 6GB      | 52GB            | 45m                    | 6h                    |
| Window-PoSt-32GiB  | 6GB      | 52GB            | 45m                    | 6h                    |
| Window-PoSt-64GiB  | 6GB      | 52GB            | 45m                    | 6h                    |
| Winning-PoSt-32GiB | 1GB      | 250MB          | 10s                    | 1m                    |
| Winning-PoSt-64GiB | 1GB      | 250MB          | 10s                    | 1m                    |

### Participant Setup Instructions

* Participant's must send us a public SSH key before participating.
* Participant's must have a publicly accessible GPG public-key and must send us a link to it before participating. If needed, we can help you set up and publish a signing keypair.

Prior to participation, each participant should:
1. Install dependencies: `rustup`, `git`, `ssh`, `tmux`, `rsync`, `b2sum`, `gpg`, OpenCL header files
2. Build [`rust-fil-proofs`](https://github.com/filecoin-project/rust-fil-proofs)

The following instructions can be used to setup a computer running Ubuntu 18.

```
$ sudo apt update
$ sudo apt install build-essential ocl-icd-opencl-dev

# Check for and install missing dependencies:
$ which <git, ssh, tmux, rsync, b2sum, gpg>

# Install rustup:
# Installation instructions are taken from the rustup website: https://rustup.rs.
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Select choice: "1"
$ source $HOME/.cargo/env

# Build rust-fil-proofs:
$ git clone https://github.com/filecoin-project/rust-fil-proofs.git
$ cd rust-fil-proofs
$ git checkout 4e4f766
$ cargo build --release --bin phase2
$ cp target/release/phase2 .
```

### Running Phase 2

Once we have confirmed you as a participant, you will be sent links to download and upload files as well as commands to run Phase 2.

Commands to run Phase 2 will be similar to:

```
# 1) Start a tmux session.
$ tmux new
$ export ssh_key='<path to ssh private-key>'

# 2) Download the previous participant’s parameters.
$ rsync -vP -e "ssh -i ${ssh_key}" <download url> .

# 3) Verify the digest of the downloaded file.
$ echo '<digest>  <downloaded file>' | b2sum -c

# 4) Run the contribution program.
$ ./phase2 contribute <downloaded file>

# 5) Hash the output parameters and send them to us via Slack.
$ b2sum <params file output by phase2>

# 6) Sign the output .contrib file.
$ gpg -a -o <.contrib file output by phase2>.sig --detach-sign <.contrib file output by phase2>

# 7) Upload your files.
$ rsync -vP -e "ssh -i ${ssh_key}" <files output by phase2> <upload url>
$ exit
```

### Phase 2 Validation

Follow the instructions [here](/b288702/README.md) to verify the Groth16 parameters generated by Filecoin's mainnet Phase 2 ceremony.

### Contact Us

A slack channel has been set up to discuss the ceremony - please join the **#fil-trustedsetup** room in our [Slack](https://join.slack.com/t/filecoinproject/shared_invite/zt-dj58b7fq-weyaTEvjHoYF_ENkQHR6Ig) or email us at trustedsetup@protocol.ai.
