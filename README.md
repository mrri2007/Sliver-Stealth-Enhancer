Sliver C2 Protobuf Signature Modifier
Automatically rename Sliver C2's protobuf messages to evade signature-based detection.
Quick Start
Step 1: Clone Sliver Repository
bashgit clone https://github.com/BishopFox/sliver.git
cd sliver
Step 2: Setup the Script
Move sliver_complete_fix.sh to the Sliver main folder and give it execute permissions:
bashchmod +x ./sliver_complete_fix.sh
Step 3: Run the Script
bash./sliver_complete_fix.sh
Step 4: Fix Compilation Errors (If Needed)
After the script finishes running, it might give a compilation error. To fix this, simply copy and paste these commands:
bash# Fix the function definition
find server/cli client/cli -name "*.go" -exec sed -i 's/func CmdExecute(/func Execute(/g' {} +

# Also check for any method receivers that might have been renamed
find server/cli client/cli -name "*.go" -exec sed -i 's/) CmdExecute(/) Execute(/g' {} +

# Verify the fix
grep -n "func Execute()" server/cli/cli.go
Expected output:
server/cli/cli.go:157:func Execute() {
client/cli/cli.go:93:func Execute() {
Step 5: Verify Modifications
To verify if the modifications were implemented successfully, copy and paste the command below:
bashif strings sliver-server | grep -q "\.sliverpb\.ScreenshotReq\|\.sliverpb\.ProcessDumpReq\|\.sliverpb\.ImpersonateReq"; then
    echo "❌ FAILED - Old protobuf signatures still present"
else
    echo "✅ SUCCESS - Protobuf signatures successfully modified"
fi
Step 6: Compile Sliver
Last step - run the command to compile Sliver:
bashmake

What Gets Modified
OriginalModifiedScreenshotReqSysScreenCaptureReqProcessDumpReqSysMemDumpReqImpersonateReqSysTokenSwitchReqNetstatReqSysConnListReqExecuteReqCmdExecuteReqUploadReqFileUploadReqDownloadReqFileDownloadReq+ 20 more...
Rollback
If you need to restore the original files:
bashrm -rf protobuf
cp -r protobuf.backup.original protobuf
make
Disclaimer
For authorized security testing only. Use responsibly.

Credits: Original Sliver C2 by BishopFoxRetryClaude can make mistakes. Please double-check responses.
