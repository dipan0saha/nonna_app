import re

with open("docs/96_next_steps/Next_Steps.md", "r") as f:
    text = f.read()

text = re.sub(
    r"## 1\. Add New Registry Items \(CRUD\) — Status: UI exists, wiring needed",
    r"## 1. Add New Registry Items (CRUD) — Status: **Completed**",
    text
)

text = re.sub(
    r"## 2\. Purchaser Tracking \(Visibility\) — Status: Data collected, UI missing",
    r"## 2. Purchaser Tracking (Visibility) — Status: **Partially Completed**\n(Marking un-marking and tracking state exists, displaying purchaser avatar remains)",
    text
)

with open("docs/96_next_steps/Next_Steps.md", "w") as f:
    f.write(text)

