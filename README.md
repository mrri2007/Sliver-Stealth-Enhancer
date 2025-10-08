git clone https://github.com/BishopFox/sliver.git
move the script to sliver main folder
give execute permissions to script - chmod +x  ./sliver_complete_fix.sh
run the script ./sliver_complete_fix.sh

-------------------------------------------------------------------------------------------------------------------------------------------------------->
after the script is finished  running ,it might give compilation error, to fix this simply copy paste these commands and enter ---->
# Fix the function definition
find server/cli client/cli -name "*.go" -exec sed -i 's/func CmdExecute(/func Execute(/g' {} +

# Also check for any method receivers that might have been renamed
find server/cli client/cli -name "*.go" -exec sed -i 's/) CmdExecute(/) Execute(/g' {} +

# Verify the fix
grep -n "func Execute()" server/cli/cli.go

# Should show something like:
# 45:func Execute() {

to verify if the modifications were implemented sucsessfully simply copy paste the commands below all together -----> 

if strings sliver-server | grep -q "\.sliverpb\.ScreenshotReq\|\.sliverpb\.ProcessDumpReq\|\.sliverpb\.ImpersonateReq"; then
    echo "❌ FAILED - Old protobuf signatures still present"
else
    echo "✅ SUCCESS - Protobuf signatures successfully modified"
fi
---------------------------------------------------------------------------------------------------------------------------------------------------------->
last step run the command to compile sliver - make
