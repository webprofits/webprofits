#!/usr/bin/env python3
"""PreToolUse hook: deny any file tool call that targets a real .env file. Templates pass."""
import json, re, sys
data = json.load(sys.stdin)
ti = data.get("tool_input", {})
fields = [str(ti.get(k, "")) for k in ("file_path", "command", "pattern", "path")]
real = re.compile(r'(?:^|[/\\ \t\'"])\.env(?=$|[.\s/\'"*])')
template = re.compile(r'\.env\.(example|sample|template|dist|tpl)\b')
if any(real.search(template.sub(' ', f)) for f in fields):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny",
                      "permissionDecisionReason": "Blocked: .env files are protected."}}))
sys.exit(0)
