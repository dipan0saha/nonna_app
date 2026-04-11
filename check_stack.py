import json
with open("test_machine2.json") as f:
    events = [json.loads(l) for l in f if l.startswith("{")]
failed = [e for e in events if e.get("type") == "testDone" and e.get("result") == "error"]
tests = {e["test"]["id"]: e["test"]["name"] for e in events if e.get("type") == "testStart"}
errors = [e for e in events if e.get("type") == "error"]
for f in failed:
    test_id = f.get("testID")
    if "validates file extensions" in tests.get(test_id, ""):
        print("FAILED:", tests.get(test_id))
        errs = [er for er in errors if er.get("testID") == test_id]
        if errs:
            print(errs[0].get("error"))
            print(errs[0].get("stackTrace", ""))
