---
description: "Log this device out of mastermem (the next session connects it again)"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/hooks/bin/mastermem-hook:*)"]
---

```!
"${CLAUDE_PLUGIN_ROOT}/hooks/bin/mastermem-hook" logout --client claude
```

Tell the user the result above in one short line, nothing else. If it says logged out, add that the next `claude` session opens the browser to connect this device again. Do not call any mastermem tool.
