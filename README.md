![sliver-readme-banner](https://github.com/user-attachments/assets/e302d08c-d651-4b8d-86bb-c8a1175965d8)
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 400">
  <!-- Background -->
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#0f0f23;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1a1a2e;stop-opacity:1" />
    </linearGradient>
    
    <linearGradient id="accentGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#00d9ff;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#00ff88;stop-opacity:1" />
    </linearGradient>
    
    <!-- Glow effect -->
    <filter id="glow">
      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  
  <rect width="1200" height="400" fill="url(#bgGrad)"/>
  
  <!-- Grid pattern -->
  <g opacity="0.03">
    <path d="M0,0 L0,400 M50,0 L50,400 M100,0 L100,400 M150,0 L150,400 M200,0 L200,400 M250,0 L250,400 M300,0 L300,400 M350,0 L350,400 M400,0 L400,400 M450,0 L450,400 M500,0 L500,400 M550,0 L550,400 M600,0 L600,400 M650,0 L650,400 M700,0 L700,400 M750,0 L750,400 M800,0 L800,400 M850,0 L850,400 M900,0 L900,400 M950,0 L950,400 M1000,0 L1000,400 M1050,0 L1050,400 M1100,0 L1100,400 M1150,0 L1150,400 M1200,0 L1200,400" stroke="#00ff88" stroke-width="1"/>
    <path d="M0,0 L1200,0 M0,50 L1200,50 M0,100 L1200,100 M0,150 L1200,150 M0,200 L1200,200 M0,250 L1200,250 M0,300 L1200,300 M0,350 L1200,350 M0,400 L1200,400" stroke="#00ff88" stroke-width="1"/>
  </g>
  
  <!-- Top accent line -->
  <rect x="0" y="0" width="1200" height="3" fill="url(#accentGrad)"/>
  
  <!-- Shield/Security Icon -->
  <g transform="translate(100, 120)">
    <path d="M60,10 L100,30 L100,80 Q100,120 60,140 Q20,120 20,80 L20,30 Z" 
          fill="none" stroke="url(#accentGrad)" stroke-width="3" filter="url(#glow)"/>
    <path d="M45,70 L55,80 L75,55" 
          fill="none" stroke="#00ff88" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
  
  <!-- Main Title -->
  <text x="220" y="150" font-family="'Courier New', monospace" font-size="52" font-weight="bold" fill="#ffffff">
    SLIVER C2
  </text>
  <text x="220" y="200" font-family="'Courier New', monospace" font-size="42" font-weight="bold" fill="url(#accentGrad)">
    Protobuf Modifier
  </text>
  
  <!-- Subtitle -->
  <text x="220" y="240" font-family="'Courier New', monospace" font-size="20" fill="#8892b0">
    Evade Signature-Based Detection
  </text>
  
  <!-- Code-style transformation visualization -->
  <g transform="translate(220, 270)">
    <!-- Before -->
    <rect x="0" y="0" width="280" height="60" rx="5" fill="#1e2a3a" opacity="0.6"/>
    <text x="10" y="25" font-family="'Courier New', monospace" font-size="14" fill="#ff6b6b">
      ScreenshotReq
    </text>
    <text x="10" y="45" font-family="'Courier New', monospace" font-size="14" fill="#ff6b6b">
      ProcessDumpReq
    </text>
    
    <!-- Arrow -->
    <g transform="translate(300, 20)">
      <line x1="0" y1="10" x2="60" y2="10" stroke="url(#accentGrad)" stroke-width="3"/>
      <polygon points="60,10 50,5 50,15" fill="#00ff88"/>
    </g>
    
    <!-- After -->
    <rect x="380" y="0" width="320" height="60" rx="5" fill="#1e2a3a" opacity="0.6"/>
    <text x="390" y="25" font-family="'Courier New', monospace" font-size="14" fill="#00ff88">
      SysScreenCaptureReq
    </text>
    <text x="390" y="45" font-family="'Courier New', monospace" font-size="14" fill="#00ff88">
      SysMemDumpReq
    </text>
  </g>
  
  <!-- Tech badges -->
  <g transform="translate(850, 100)">
    <rect x="0" y="0" width="100" height="30" rx="15" fill="#1e2a3a"/>
    <text x="50" y="20" font-family="Arial, sans-serif" font-size="14" fill="#00d9ff" text-anchor="middle">
      Go
    </text>
    
    <rect x="0" y="40" width="100" height="30" rx="15" fill="#1e2a3a"/>
    <text x="50" y="60" font-family="Arial, sans-serif" font-size="14" fill="#00d9ff" text-anchor="middle">
      Protobuf
    </text>
    
    <rect x="0" y="80" width="100" height="30" rx="15" fill="#1e2a3a"/>
    <text x="50" y="100" font-family="Arial, sans-serif" font-size="14" fill="#00ff88" text-anchor="middle">
      Red Team
    </text>
  </g>
  
  <!-- Binary code effect (decorative) -->
  <g opacity="0.1" font-family="'Courier New', monospace" font-size="10" fill="#00ff88">
    <text x="1000" y="200">01001000</text>
    <text x="1000" y="220">11010101</text>
    <text x="1000" y="240">00110011</text>
    <text x="1000" y="260">10101010</text>
    <text x="1070" y="200">01110010</text>
    <text x="1070" y="220">11001100</text>
    <text x="1070" y="240">00111001</text>
    <text x="1070" y="260">10100101</text>
  </g>
  
  <!-- Bottom accent line -->
  <rect x="0" y="397" width="1200" height="3" fill="url(#accentGrad)"/>
  
  <!-- Footer text -->
  <text x="600" y="380" font-family="'Courier New', monospace" font-size="12" fill="#8892b0" text-anchor="middle">
    Automated Signature Obfuscation for Sliver Framework
  </text>
</svg>





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
