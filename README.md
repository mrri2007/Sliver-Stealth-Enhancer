Sliver C2 Protobuf Signature Modifier
A script to modify Sliver C2 Framework's protobuf message signatures to evade signature-based detection by EDR/AV solutions.
What This Does
Renames common protobuf messages that are heavily signatured by security tools:

ScreenshotReq → SysScreenCaptureReq
ProcessDumpReq → SysMemDumpReq
ImpersonateReq → SysTokenSwitchReq
And 20+ other high-value targets

Prerequisites

Go 1.21 or higher
Make
Protocol Buffers compiler (protoc)

Installation & Usage
1. Clone Sliver Repository
bashgit clone https://github.com/BishopFox/sliver.git
cd sliver
2. Add the Script
Place sliver_complete_fix.sh in the Sliver main directory and make it executable:
bashchmod +x ./sliver_complete_fix.sh
3. Run the Script
bash./sliver_complete_fix.sh
4. Fix Compilation Errors (If Needed)
If the script encounters compilation errors, run these commands:
bash# Fix the function definition
find server/cli client/cli -name "*.go" -exec sed -i 's/func CmdExecute(/func Execute(/g' {} +

# Fix any method receivers that might have been renamed
find server/cli client/cli -name "*.go" -exec sed -i 's/) CmdExecute(/) Execute(/g' {} +

# Verify the fix
grep -n "func Execute()" server/cli/cli.go
Expected output:
server/cli/cli.go:157:func Execute() {
client/cli/cli.go:93:func Execute() {
5. Compile Sliver
bashmake
Verification
Verify that the modifications were successfully implemented:
bashif strings sliver-server | grep -q "\.sliverpb\.ScreenshotReq\|\.sliverpb\.ProcessDumpReq\|\.sliverpb\.ImpersonateReq"; then
    echo "❌ FAILED - Old protobuf signatures still present"
else
    echo "✅ SUCCESS - Protobuf signatures successfully modified"
fi
Expected Output
✅ SUCCESS - Protobuf signatures successfully modified
Protobuf Modifications
Original NameModified NameScreenshotReqSysScreenCaptureReqScreenshotSysScreenCaptureProcessDumpReqSysMemDumpReqProcessDumpSysMemDumpImpersonateReqSysTokenSwitchReqImpersonateSysTokenSwitchPsReqSysProcListReqPsSysProcListIfconfigReqSysNetConfigReqIfconfigSysNetConfigNetstatReqSysConnListReqNetstatSysConnListExecuteReqCmdExecuteReqExecuteCmdExecuteUploadReqFileUploadReqUploadFileUploadDownloadReqFileDownloadReqDownloadFileDownloadLsReqFileDirListReqLsFileDirListCdReqFileDirChangeReqCdFileDirChangeMkdirReqFileMakeDirReqMkdirFileMakeDirRmReqFileRemoveReqRmFileRemoveMigrateReqProcMigrateReqMigrateProcMigrate
Rollback
If you need to restore the original protobuf files:
bashrm -rf protobuf
cp -r protobuf.backup.original protobuf
make
Disclaimer
This tool is for authorized security testing and research purposes only. Ensure you have proper authorization before using this in any environment.
Credits

Original Sliver C2 Framework by BishopFox

License
This modification script is provided as-is for educational purposes.
