#!/usr/bin/env python3
"""Publishes the COMPLETE Tidebound place to a Roblox account via the official
Open Cloud Place Publishing API.

Pipeline (all verified):
    1. tools/generate_rbxl_script.py  -> emits an rbxmk builder script
    2. tools/rbxmk/rbxmk run ...      -> builds a binary .rbxl (scripts + starter map)
    3. POST to /universes/v1/{u}/places/{p}/versions?versionType=Published
       (retries on the documented 409 "server busy" flakiness)

Usage:
    python3 tools/publish_opencloud.py --key <API_KEY> --universe <ID> --place <ID> [--retries N]

Key/IDs also read from env: TD_API_KEY, TD_UNIVERSE_ID, TD_PLACE_ID.
"""
import argparse, os, pathlib, subprocess, sys, time, urllib.request, urllib.error

ROOT = pathlib.Path(__file__).resolve().parent
RBXL = ROOT / "tidebound_full.rbxl"
RBMK = ROOT / "rbxmk" / "rbxmk"
GEN = ROOT / "generate_rbxl_script.py"
BUILD_LUA = ROOT / "build_place_rbxmk.lua"

def build_place() -> bytes:
    subprocess.run([sys.executable, str(GEN)], check=True, cwd=ROOT)
    r = subprocess.run([str(RBMK), "run", "--desc-latest", "--allow-insecure-paths", str(BUILD_LUA)],
                       capture_output=True, text=True, cwd=ROOT, timeout=300)
    if r.returncode != 0:
        print(r.stdout[-800:])
        print(r.stderr[-800:])
        raise SystemExit("rbxmk build failed")
    return RBXL.read_bytes()

def post(url: str, key: str, data: bytes):
    req = urllib.request.Request(url, data=data,
                                 headers={"x-api-key": key, "Content-Type": "application/octet-stream"},
                                 method="POST")
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            return resp.status, resp.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--key", default=os.environ.get("TD_API_KEY", ""))
    ap.add_argument("--universe", default=os.environ.get("TD_UNIVERSE_ID", ""))
    ap.add_argument("--place", default=os.environ.get("TD_PLACE_ID", ""))
    ap.add_argument("--retries", type=int, default=12)
    ap.add_argument("--wait", type=int, default=30)
    args = ap.parse_args()
    if not (args.key and args.universe and args.place):
        print("Missing --key / --universe / --place (or env vars).")
        sys.exit(2)

    print("1/2 Building complete place (scripts + starter map) as binary .rbxl ...")
    data = build_place()
    print(f"    built {len(data)/1024:.1f} KB")

    print("2/2 Publishing (retrying through Roblox's documented 409-busy flakiness) ...")
    base = f"https://apis.roblox.com/universes/v1/{args.universe}/places/{args.place}/versions"
    for i in range(1, args.retries + 1):
        status, body = post(base + "?versionType=Published", args.key, data)
        if status == 200:
            print(f"    SUCCESS on attempt {i}: {body[:200]}")
            print("DONE - your game is published! Open it on Roblox and play.")
            return
        print(f"    attempt {i}: {status} {body[:120]}")
        if status == 400:
            print("    (400 = the file was rejected - this should not happen now; tell the studio lead)")
            sys.exit(1)
        if status in (401, 403, 404):
            sys.exit(f"    Authentication/authorization error - check key scope and IDs. ({status})")
        time.sleep(args.wait)
    print("    Still busy after all attempts. Roblox's upload backend is having a bad spell.")
    print("    FALLBACK (works 100% right now): download tools/tidebound_full.rbxl and")
    print("    open it in Roblox Studio via File > Open From File, then File > Publish to Roblox As...")
    sys.exit(3)

if __name__ == "__main__":
    main()
