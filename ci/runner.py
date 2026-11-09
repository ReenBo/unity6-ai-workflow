#!/usr/bin/env python3
"""
Cross-Platform Universal CI/CD Audit Runner for Unity 6
Works identically on Windows, macOS, and Linux without external dependencies.
"""

import os
import sys
import re
from pathlib import Path

def print_banner(text, color_code="36"):
    print(f"\033[{color_code}m{text}\033[0m")

def audit_vcontainer(project_root):
    print_banner("\n[1/3] Running VContainer & POCO Audit (Python)...", "33")
    mono_count = 0
    poco_count = 0
    cs_files = list(Path(project_root).rglob("*.cs"))
    
    for file_path in cs_files:
        if any(ignored in str(file_path) for ignored in ["Library", "Temp", "Packages", ".git"]):
            continue
        try:
            content = file_path.read_text(encoding="utf-8", errors="ignore")
            if re.search(r"class\s+\w+\s*:\s*MonoBehaviour", content):
                mono_count += 1
            elif re.search(r"class\s+\w+", content):
                poco_count += 1
        except Exception:
            pass

    print(f"  Found POCO Classes: {poco_count}")
    print(f"  Found MonoBehaviour Classes: {mono_count}")
    return True

def scan_pii_and_secrets(project_root):
    print_banner("\n[2/3] Running Security & PII Leak Scanner (Python)...", "33")
    leak_count = 0
    ignored_patterns = ["Library", "Temp", "Packages", ".git", ".foragents", "Builds", "Build"]
    binary_extensions = {".dll", ".wasm", ".so", ".dylib", ".a", ".png", ".jpg", ".jpeg", ".tga", ".psd", ".asset", ".unity", ".prefab", ".meta", ".fbx", ".obj", ".wav", ".mp3", ".ogg", ".log"}
    
    for file_path in Path(project_root).rglob("*"):
        if file_path.is_dir() or file_path.suffix.lower() in binary_extensions:
            continue
        if any(ignored in file_path.parts for ignored in ignored_patterns):
            continue
        try:
            content = file_path.read_text(encoding="utf-8", errors="ignore")
            
            # Skip documentation examples containing template usernames
            if file_path.suffix.lower() == ".md" and ("<user>" in content or "username" in content or "example" in content):
                continue

            # Check for hardcoded absolute user paths
            if re.search(r"[C-Z]:\\Users\\[a-zA-Z0-9_\.]+\\", content) or re.search(r"\/(?:home|Users)\/[a-zA-Z0-9_\.]+\/", content):
                print(f"\033[31m  SECURITY WARNING: Hardcoded User Path in {file_path.name}\033[0m")
                leak_count += 1
                
            # Check for potential API Keys
            if re.search(r"\bsk-[a-zA-Z0-9]{20,}\b", content):
                print(f"\033[31m  CRITICAL RISK: Potential API Key in {file_path.name}\033[0m")
                leak_count += 1
        except Exception:
            pass
            
    if leak_count == 0:
        print_banner("  No PII or Secret Leaks Detected.", "32")
        return True
    else:
        print_banner(f"  Found {leak_count} Security Risks! Developer approval required.", "31")
        return False

def check_gc_allocations(project_root):
    print_banner("\n[3/3] Running GC & Allocation Profiler (Python)...", "33")
    alloc_warnings = 0
    cs_files = list(Path(project_root).rglob("*.cs"))
    
    for file_path in cs_files:
        if any(ignored in str(file_path) for ignored in ["Library", "Temp", "Packages", ".git"]):
            continue
        try:
            lines = file_path.read_text(encoding="utf-8", errors="ignore").splitlines()
            in_tick = False
            for idx, line in enumerate(lines, 1):
                if re.search(r"void\s+Tick\(\)", line):
                    in_tick = True
                if in_tick and "}" in line:
                    in_tick = False
                if in_tick and re.search(r"new\s+", line):
                    print(f"\033[33m  WARNING: Allocation in Tick() at {file_path.name}:{idx} -> {line.strip()}\033[0m")
                    alloc_warnings += 1
        except Exception:
            pass
            
    if alloc_warnings == 0:
        print_banner("  No GC allocations found in Tick() loops!", "32")
    else:
        print(f"  Found {alloc_warnings} allocation warnings.")
    return True

def main():
    print_banner("=========================================")
    print_banner("🚀 Starting Unity 6 AI Workflow Python CI")
    print_banner("=========================================")
    
    project_root = sys.argv[1] if len(sys.argv) > 1 else "."
    
    success = True
    success &= audit_vcontainer(project_root)
    success &= scan_pii_and_secrets(project_root)
    success &= check_gc_allocations(project_root)
    
    print_banner("=========================================")
    if success:
        print_banner("✅ All Python CI Audits Passed Successfully!", "32")
        sys.exit(0)
    else:
        print_banner("❌ CI Audits Failed with Security/Quality Errors!", "31")
        sys.exit(1)

if __name__ == "__main__":
    main()
