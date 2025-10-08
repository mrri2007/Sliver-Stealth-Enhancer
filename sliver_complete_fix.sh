#!/bin/bash
# Complete Sliver Protobuf Modification and Fix Script
# This handles all the edge cases and compilation issues

set -e

SLIVER_DIR="${1:-.}"

if [ ! -d "$SLIVER_DIR/protobuf" ]; then
    echo "Error: Sliver directory not found. Usage: $0 /path/to/sliver"
    exit 1
fi

cd "$SLIVER_DIR"

echo "[*] Starting complete Sliver modification process..."
echo ""

# Backup first
if [ ! -d "protobuf.backup.original" ]; then
    echo "[*] Creating backup..."
    cp -r protobuf protobuf.backup.original
    echo "    Backup saved to protobuf.backup.original"
fi

echo ""
echo "[*] Step 1: Modifying protobuf definitions..."

# Define renaming mappings - avoiding common method names
declare -A PROTO_RENAMES=(
    # High-value targets that are heavily signatured
    ["ScreenshotReq"]="SysScreenCaptureReq"
    ["Screenshot"]="SysScreenCapture"
    ["ProcessDumpReq"]="SysMemDumpReq"
    ["ProcessDump"]="SysMemDump"
    ["ImpersonateReq"]="SysTokenSwitchReq"
    ["Impersonate"]="SysTokenSwitch"
    
    # Process/system info
    ["PsReq"]="SysProcListReq"
    ["Ps"]="SysProcList"
    ["IfconfigReq"]="SysNetConfigReq"
    ["Ifconfig"]="SysNetConfig"
    ["NetstatReq"]="SysConnListReq"
    ["Netstat"]="SysConnList"
    
    # File operations - be careful with these
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
    
    # Keep Execute, Upload, Download as protobuf names but we'll handle RPC carefully
    ["ExecuteReq"]="CmdExecuteReq"
    ["Execute"]="CmdExecute"
    ["UploadReq"]="FileUploadReq"
    ["Upload"]="FileUpload"
    ["DownloadReq"]="FileDownloadReq"
    ["Download"]="FileDownload"
    ["MigrateReq"]="ProcMigrateReq"
    ["Migrate"]="ProcMigrate"
)

# Apply renames to proto files
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

# Phase 2: Fix .Execute() method calls that got renamed but shouldn't have been
echo "  [+] Restoring template/command .Execute() methods..."
echo "$FILES" | xargs -I {} sed -i \
    -e 's/\.CmdExecute(/\.Execute(/g' \
    -e 's/tmpl\.CmdExecute/tmpl.Execute/g' \
    -e 's/template\.CmdExecute/template.Execute/g' \
    -e 's/cmd\.CmdExecute/cmd.Execute/g' \
    -e 's/root\.CmdExecute/root.Execute/g' \
    -e 's/command\.CmdExecute/command.Execute/g' \
    {}

# Phase 3: Ensure RPC calls use the new protobuf method names
echo "  [+] Fixing RPC method calls..."
echo "$FILES" | xargs -I {} sed -i \
    -e 's/\.Rpc\.Execute(/\.Rpc.CmdExecute(/g' \
    -e 's/rpc\.Execute(/rpc.CmdExecute(/g' \
    -e 's/client\.Execute(/client.CmdExecute(/g' \
    {}

# Handle other potential method collisions
echo "  [+] Handling io.Reader/Writer methods..."
echo "$FILES" | xargs -I {} sed -i \
    -e 's/reader\.FileUpload/reader.Upload/g' \
    -e 's/writer\.FileUpload/writer.Upload/g' \
    -e 's/reader\.FileDownload/reader.Download/g' \
    -e 's/writer\.FileDownload/writer.Download/g' \
    -e 's/os\.FileRemove/os.Remove/g' \
    -e 's/filepath\.FileRemove/filepath.Remove/g' \
    {}

echo ""
echo "[*] Step 5: Attempting compilation..."
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
    echo "To verify your modifications:"
    echo "  strings sliver-server | grep -i 'ScreenshotReq'  # Should be empty"
    echo "  strings sliver-server | grep -i 'SysScreenCapture'  # Should show results"
    echo ""
    echo "To start using:"
    echo "  ./sliver-server"
    echo ""
    echo "Original protobuf backup: protobuf.backup.original"
else
    echo ""
    echo "============================================"
    echo "Compilation failed. Don't worry, let's debug..."
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
    echo "  2. Check the error output above for specific files"
    echo "  3. You can manually edit those files and run 'make' again"
    echo ""
    exit 1
    
    sed -i 's/func CmdExecute(/func Execute(/g' server/cli/cli.go
    sed -i 's/func CmdExecute(/func Execute(/g' client/cli/cli.go

   # Verify the fix
   grep -n "func Execute()" server/cli/cli.go client/cli/cli.go 
   server/cli/cli.go:157:func Execute() {
   client/cli/cli.go:93:func Execute() {
   if strings sliver-server | grep -q "\.sliverpb\.ScreenshotReq\|\.sliverpb\.ProcessDumpReq\|\.sliverpb\.ImpersonateReq"; then
    echo "❌ FAILED - Old protobuf signatures still present"
else
    echo "✅ SUCCESS - Protobuf signatures successfully modified"
fi


