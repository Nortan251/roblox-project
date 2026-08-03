#!/usr/bin/env python3
"""Generates tools/installer_parts/part_01..NN.luau - small chunks of the installer
for pasting into Studio's Command Bar one at a time (for users where the full
single paste gets truncated). Each part is self-contained and idempotent.

Usage: python3 tools/generate_installer_parts.py
"""
import pathlib

SRC = pathlib.Path("/home/user/tidebound/src")
OUT = pathlib.Path("/home/user/tidebound/tools/installer_parts")
OUT.mkdir(exist_ok=True)

TREE = {
    "ReplicatedStorage/Shared": "Folder",
    "ReplicatedStorage/Shared/Config": "ModuleScript",
    "ReplicatedStorage/Shared/Types": "ModuleScript",
    "ReplicatedStorage/Shared/Util": "ModuleScript",
    "ReplicatedStorage/Shared/Remotes": "ModuleScript",
    "ReplicatedStorage/Shared/Data": "Folder",
    "ReplicatedStorage/Shared/Data/FishCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/RodCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/ZoneCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/QuestCatalog": "ModuleScript",
    "ReplicatedStorage/Shared/Data/CosmeticsCatalog": "ModuleScript",
    "ServerScriptService/Bootstrap": "Script",
    "ServerScriptService/Services": "Folder",
    "ServerScriptService/Services/SecurityService": "Script",
    "ServerScriptService/Services/DataService": "Script",
    "ServerScriptService/Services/EconomyService": "Script",
    "ServerScriptService/Services/InventoryService": "Script",
    "ServerScriptService/Services/QuestService": "Script",
    "ServerScriptService/Services/EventService": "Script",
    "ServerScriptService/Services/LeaderboardService": "Script",
    "ServerScriptService/Services/ShopService": "Script",
    "ServerScriptService/Services/TravelService": "Script",
    "ServerScriptService/Services/AmbienceService": "Script",
    "ServerScriptService/Services/FishingService": "Script",
    "ServerScriptService/Services/WorldInteractionsService": "Script",
    "StarterPlayer/StarterPlayerScripts/Bootstrap": "LocalScript",
    "StarterPlayer/StarterPlayerScripts/Controllers": "Folder",
    "StarterPlayer/StarterPlayerScripts/Controllers/AudioController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/GuideController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/CastController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/UIController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules": "Folder",
    "StarterPlayer/StarterPlayerScripts/Modules/Theme": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/UiKit": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/ClientState": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/FishVisuals": "ModuleScript",
}

def source_for(logical):
    parts = logical.split("/")
    base = SRC / "/".join(parts)
    for cand in (base.with_suffix(".luau"), base.with_suffix(".server.luau"), base.with_suffix(".client.luau")):
        if cand.exists():
            return cand.read_text()
    raise FileNotFoundError(base)

PREAMBLE_LINES = [
    "--[[",
    "\tTidebound - Installer part (paste into Studio Command Bar)",
    "\tCreates/updates scripts. Idempotent; safe to run parts in any order,",
    "\tbut run them in order 01..NN. Watch the Output window for part messages.",
    "]]",
    'local function getSvc(n) return game:GetService(n) end',
    'local rs = getSvc("ReplicatedStorage")',
    'local sss = getSvc("ServerScriptService")',
    'local sp = getSvc("StarterPlayer"):WaitForChild("StarterPlayerScripts")',
    "",
    "local starter = getSvc(\"StarterPlayer\")",
    "",
    "-- Idempotent ensure: walks the LIVE explorer tree from the service root.",
    "-- (NOTE: paths use the SERVICE root, e.g. 'StarterPlayer/StarterPlayerScripts/...'",
    "-- so StarterPlayerScripts is found as a CHILD of the StarterPlayer service.)",
    "local function ensure(logical, cls)",
    "\tlocal parts = {}",
    "\tfor p in logical:gmatch(\"[^/]+\") do table.insert(parts, p) end",
    "\tlocal root = parts[1] == \"ReplicatedStorage\" and rs",
    "\t\tor parts[1] == \"ServerScriptService\" and sss",
    "\t\tor parts[1] == \"StarterPlayer\" and starter",
    "\tif not root then return nil end",
    "\tlocal current = root",
    "\tfor i = 2, #parts do",
    "\t\tlocal child = current:FindFirstChild(parts[i])",
    "\t\tif not child then",
    "\t\t\tchild = Instance.new(i == #parts and cls or \"Folder\")",
    "\t\t\tchild.Name = parts[i]",
    "\t\t\tchild.Parent = current",
    "\t\tend",
    "\t\tcurrent = child",
    "\tend",
    "\treturn current",
    "end",
    "",
]

def script_block(logical, cls):
    src = source_for(logical)
    assert "]==]" not in src, "delimiter collision in " + logical
    return (
        "-- " + logical + "\n"
        "local inst = ensure('" + logical + "', '" + cls + "')\n"
        "if inst and inst.Source ~= [==[" + src + "]==] then\n"
        "\tinst.Source = [==[" + src + "]==]\n"
        "\tprint('[Installer] Wrote " + logical + "')\n"
        "end\n"
    )

def main():
    folder_blocks = [("ensure('" + l + "', 'Folder')") for l, c in TREE.items() if c == "Folder"]
    script_blocks = [(l, c) for l, c in TREE.items() if c != "Folder"]

    MAX_BYTES = 38000
    parts = []
    preamble = "\n".join(PREAMBLE_LINES)
    current = [preamble]
    size = len(preamble)
    for logical, cls in script_blocks:
        block = script_block(logical, cls)
        if size + len(block) > MAX_BYTES and len(current) > 1:
            parts.append(current)
            current = [preamble]
            size = len(preamble)
        current.append(block)
        size += len(block)
    if current:
        parts.append(current)

    total = len(parts)
    for i, part_lines in enumerate(parts, 1):
        body = "\n".join(part_lines)
        body += '\nprint("[Installer] Part ' + str(i) + '/' + str(total) + ' complete - next: ' + str(i + 1) + '")\n'
        path = OUT / ("part_%02d_of_%02d.luau" % (i, total))
        path.write_text(body, encoding="utf-8")
        print("  wrote %s (%.1f KB)" % (path.name, path.stat().st_size / 1024))

    (OUT / "README.txt").write_text(
        "TIDEBOUND INSTALLER PARTS\n"
        "=========================\n"
        "1. Open Roblox Studio, sign in, create a Baseplate place.\n"
        "2. Open View > Command Bar (or View > Output and click the command bar box).\n"
        "3. Type:  print('ok')  and press Enter. You should see 'ok' in the Output window.\n"
        "4. Open part_01...luau in Notepad. Select ALL (Ctrl+A), Copy (Ctrl+C).\n"
        "5. Click inside the Command Bar, paste (Ctrl+V), press Enter.\n"
        "6. Wait for: [Installer] Part 1/N complete.\n"
        "7. Repeat for every part in order.\n"
        "8. Done! You should see [Tidebound] Server booted after pressing Play.\n",
        encoding="utf-8",
    )
    print("wrote %d parts + README.txt into %s" % (total, OUT))

if __name__ == "__main__":
    main()
