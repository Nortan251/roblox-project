#!/usr/bin/env python3
"""Generates tools/studio_installer.luau — paste that file into Roblox Studio's
Command Bar (View > Command Bar) while signed in as your account. It creates
the whole Tidebound script tree with source code embedded, ready to publish.

Usage: python3 tools/generate_installer.py
"""
import pathlib, re

SRC = pathlib.Path("/home/user/tidebound/src")
OUT = pathlib.Path("/home/user/tidebound/tools/studio_installer.luau")

# Instance tree: (logical path) -> (instance cls)
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
    "ServerScriptService/Bootstrap": "Script",
    "StarterPlayer/StarterPlayerScripts/Bootstrap": "LocalScript",
    "StarterPlayer/StarterPlayerScripts/Controllers": "Folder",
    "StarterPlayer/StarterPlayerScripts/Controllers/AudioController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/CastController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/UIController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Controllers/MenuUIController": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules": "Folder",
    "StarterPlayer/StarterPlayerScripts/Modules/Theme": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/UiKit": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/ClientState": "ModuleScript",
    "StarterPlayer/StarterPlayerScripts/Modules/FishVisuals": "ModuleScript",
}

def source_for(logical: str) -> str:
    """Map logical path to the physical src file."""
    parts = logical.split("/")
    base = SRC / "/".join(parts)
    # ModuleScripts are plain .luau; Scripts/LocalScripts carry .server/.client
    for cand in (base.with_suffix(".luau"), base.with_suffix(".server.luau"), base.with_suffix(".client.luau")):
        if cand.exists():
            return cand.read_text()
    raise FileNotFoundError(base)

def main():
    lines = []
    lines.append("--[[")
    lines.append("\tTidebound — Studio Installer (GENERATED, do not hand-edit)")
    lines.append("\tPaste this ENTIRE file into Studio's Command Bar (View > Command Bar)")
    lines.append("\twhile signed in. It creates/updates every script for the game.")
    lines.append("\tSafe to run multiple times (idempotent).")
    lines.append("]]")
    lines.append("")
    lines.append('local function getSvc(n) return game:GetService(n) end')
    lines.append("local rs = getSvc('ReplicatedStorage')")
    lines.append("local sss = getSvc('ServerScriptService')")
    lines.append("local sp = getSvc('StarterPlayer'):WaitForChild('StarterPlayerScripts')")
    lines.append("")
    lines.append("-- Build the instance tree; returns each instance by logical path")
    lines.append("local created = {}")
    lines.append("local starter = getSvc('StarterPlayer')")
    lines.append("local function ensure(logical, cls)")
    lines.append("\tlocal pathParts = {}")
    lines.append("\tfor part in logical:gmatch('[^/]+') do table.insert(pathParts, part) end")
    lines.append("\tlocal root = pathParts[1] == 'ReplicatedStorage' and rs")
    lines.append("\t\tor pathParts[1] == 'ServerScriptService' and sss")
    lines.append("\t\tor pathParts[1] == 'StarterPlayer' and starter")
    lines.append("\tif not root then return nil end")
    lines.append("\tlocal current = root")
    lines.append("\tfor i = 2, #pathParts do")
    lines.append("\t\tlocal child = current:FindFirstChild(pathParts[i])")
    lines.append("\t\tif not child then")
    lines.append("\t\t\tchild = Instance.new(i == #pathParts and cls or 'Folder')")
    lines.append("\t\t\tchild.Name = pathParts[i]")
    lines.append("\t\t\tchild.Parent = current")
    lines.append("\t\tend")
    lines.append("\t\tcurrent = child")
    lines.append("\tend")
    lines.append("\treturn current")
    lines.append("end")
    lines.append("")

    # Emit each file as a [==[ ... ]==] long string (verified: no source contains ]==])
    for logical, cls in TREE.items():
        if cls in ("Folder",):
            continue
        src = source_for(logical)
        # Escape the long-string delimiter if ever present (defensive)
        assert "]==]" not in src, f"delimiter collision in {logical}"
        inst_expr = logical.split("/")[-1]
        lines.append(f"-- {logical}")
        lines.append(f"local inst = ensure('{logical}', '{cls}')")
        lines.append(f"if inst and inst.Source ~= [==[{src}]==] then")
        lines.append(f"\tinst.Source = [==[{src}]==]")
        lines.append(f"\tprint('[Installer] Wrote {logical}')")
        lines.append("end")
        lines.append("")

    lines.append("-- Ensure folders exist (created on first run)")
    for logical, cls in TREE.items():
        if cls == "Folder":
            lines.append(f"ensure('{logical}', 'Folder')")
    lines.append("")
    lines.append('print("[Installer] Tidebound script tree ready! Now: build the map per src/README.md, then File > Publish to Roblox As...")')

    OUT.write_text("\n".join(lines))
    print(f"wrote {OUT} ({len(lines)} lines)")

if __name__ == "__main__":
    main()
