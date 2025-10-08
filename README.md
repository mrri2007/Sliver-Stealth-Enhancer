## 🛠️ Sliver Fix Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/BishopFox/sliver.git
   ```

2. Move the script to the main Sliver folder.

3. Give execute permissions to the script:
   ```bash
   chmod +x ./sliver_complete_fix.sh
   ```

4. Run the script:
   ```bash
   ./sliver_complete_fix.sh
   ```

---

### ⚠️ After the script finishes

If it gives a compilation error, fix it by running these commands:

**Fix the function definition:**
```bash
find server/cli client/cli -name "*.go" -exec sed -i 's/func CmdExecute(/func Execute(/g' {} +
```

**Fix method receivers (if renamed):**
```bash
find server/cli client/cli -name "*.go" -exec sed -i 's/) CmdExecute(/) Execute(/g' {} +
```

**Verify the fix:**
```bash
grep -n "func Execute()" server/cli/cli.go
# Output should show something like:
# 45:func Execute() {
```

---

### ✅ Check for protobuf signature modification

Run the following all together:
```bash
if strings sliver-server | grep -q ".sliverpb.ScreenshotReq|.sliverpb.ProcessDumpReq|.sliverpb.ImpersonateReq"; then
    echo "❌ FAILED - Old protobuf signatures still present"
else
    echo "✅ SUCCESS - Protobuf signatures successfully modified"
fi
```

---

### 🧱 Final step: Compile Sliver

```bash
make
```
