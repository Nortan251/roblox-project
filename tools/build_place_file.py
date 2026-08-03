#!/usr/bin/env python3
"""Builds tidebound_full.rbxlx — a COMPLETE, playable Roblox place file:
all scripts + a starter map (water, sea floor, dock, spawn, Old Salt NPC,
market stall, 8 zone regions with buoys & name tags).

This single file can be published directly to a Roblox account via the
Open Cloud Place Publishing API (see publish_opencloud.py) or imported
into Studio via File > Open From File (or drag-drop).

Usage: python3 tools/build_place_file.py   (writes tools/tidebound_full.rbxlx)
"""
import base64, pathlib, xml.etree.ElementTree as ET

SRC = pathlib.Path("/home/user/tidebound/src")
OUT = pathlib.Path("/home/user/tidebound/tools/tidebound_full.rbxlx")

# ── Script tree (same as the other installers) ───────────────────────────
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
    "ServerScriptService/Services/FishingService": "Script",
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
    parts = logical.split("/")
    base = SRC / "/".join(parts)
    for cand in (base.with_suffix(".luau"), base.with_suffix(".server.luau"), base.with_suffix(".client.luau")):
        if cand.exists():
            return cand.read_text()
    raise FileNotFoundError(logical)

# ── Starter map layout ───────────────────────────────────────────────────
# (x, z) centers; y handled per-part. Journey heads south (-Z).
ZONES = {
    "sunshall":       {"pos": (0, 0),      "size": (360, 360), "color": (255, 214, 150), "label": "Sunshall Cove"},
    "whisper":        {"pos": (0, -1000),  "size": (360, 360), "color": (70, 220, 210),  "label": "Whisper Shallows"},
    "drop":           {"pos": (0, -2000),  "size": (360, 360), "color": (40, 100, 200),  "label": "The Drop"},
    "ember":          {"pos": (0, -3000),  "size": (360, 360), "color": (255, 100, 50),  "label": "Ember Falls"},
    "frost":          {"pos": (0, -4000),  "size": (360, 360), "color": (200, 235, 255), "label": "Frostreach"},
    "abyss":          {"pos": (0, -5000),  "size": (360, 360), "color": (90, 55, 130),   "label": "Abyssal Trench"},
    "hidden_isles":   {"pos": (800, -3000), "size": (180, 180), "color": (240, 255, 240), "label": "Hidden Isle of Whispers"},
    "sunken_grotto":  {"pos": (800, -2000), "size": (180, 180), "color": (120, 220, 200), "label": "The Sunken Grotto"},
}

class Counter:
    def __init__(self):
        self.n = 0
        self.registry = {}
    def next(self, logical: str):
        r = f"RBX{self.n}"
        self.n += 1
        self.registry[r] = logical
        return r

def esc(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def b64w(data: str) -> str:
    b = base64.b64encode(data.encode("utf-8")).decode("ascii")
    return "\n".join(b[i:i + 76] for i in range(0, len(b), 76))

def item_open(cls: str, ref: str, ind: str) -> str:
    return f'{ind}<Item class="{cls}" referent="{ref}">'

def item_close(ind: str) -> str:
    return f"{ind}</Item>"

def props(ps: list) -> str:
    out = ["\t<Properties>"]
    for p in ps:
        out.append("\t\t" + p)
    out.append("\t</Properties>")
    return "\n".join(out)

def part_xml(counter: Counter, name: str, cls: str, x: float, y: float, z: float,
             sx: float, sy: float, sz: float, color: tuple, material: str = "SmoothPlastic",
             transparency: float = 0.0, collide: bool = True, query: bool = True,
             shape: str = "Block", extra: list = None) -> str:
    ref = counter.next(f"part:{name}")
    ps = [
        f'<string name="Name">{esc(name)}</string>',
        f'<bool name="Anchored">true</bool>',
        f'<bool name="CanCollide">{"true" if collide else "false"}</bool>',
        f'<bool name="CanQuery">{"true" if query else "false"}</bool>',
        f'<float name="Transparency">{transparency}</float>',
        f'<CoordinateFrame name="CFrame" R00="1" R01="0" R02="0" R10="0" R11="1" R12="0" R20="0" R21="0" R22="1" X="{x}" Y="{y}" Z="{z}"/>',
        f'<Vector3 name="Size" X="{sx}" Y="{sy}" Z="{sz}"/>',
        f'<Color3uint8 name="Color" R="{color[0]}" G="{color[1]}" B="{color[2]}"/>',
        f'<token name="Material">{material}</token>',
        f'<token name="Shape">{shape}</token>',
    ]
    if extra:
        ps += extra
    return item_open(cls, ref, "\t") + "\n" + props(ps) + "\n" + item_close("\t")

def billboard_tag(counter: Counter, text: str, color: tuple, y: float) -> str:
    """Floating zone name tag (BillboardGui > TextLabel)."""
    ref = counter.next("billboard")
    return (
        item_open("BillboardGui", ref, "\t\t") + "\n"
        + props([
            f'<string name="Name">Tag</string>',
            f'<bool name="Adornee">nil</bool>',
            f'<bool name="AlwaysOnTop">true</bool>',
            f'<bool name="Enabled">true</bool>',
            f'<Vector2 name="Size" X="300" Y="60"/>',
            f'<Vector3 name="StudsOffset" X="0" Y="{y}" Z="0"/>',
            f'<float name="MaxDistance">400</float>',
        ]) + "\n"
        + "\t\t\t" + item_open("TextLabel", counter.next("billboard_label"), "\t\t") + "\n"
        + "\t\t\t" + props([
            f'<string name="Name">Label</string>',
            f'<string name="Text">{esc(text)}</string>',
            f'<bool name="BackgroundTransparency">true</bool>',
            f'<Color3uint8 name="TextColor3" R="{color[0]}" G="{color[1]}" B="{color[2]}"/>',
            f'<float name="TextSize">18</float>',
            f'<token name="Font">GothamBold</token>',
            f'<UDim2 name="Size" X="1" Y="0" X2="0" Y2="60"/>',
            f'<UDim2 name="Position" X="0" Y="0" X2="0" Y2="0"/>',
            f'<float name="TextStrokeTransparency">0.5</float>',
        ]) + "\n"
        + "\t\t\t" + item_close("\t\t") + "\n"
        + "\t\t" + item_close("\t\t")
    )

def workspace_xml(counter: Counter) -> str:
    out = [item_open("Workspace", counter.next("workspace"), "\t")]
    ps = [f'<string name="Name">Workspace</string>', f'<float name="Gravity">196.2</float>']
    out.append(props(ps))

    # Sea floor (walkable seabed at Y = -3)
    out.append(part_xml(counter, "SeaFloor", "Part", 0, -3.5, -2500, 9000, 5, 9000,
                        (110, 140, 170), "SmoothPlastic", 0, True, True, "Block"))
    # Water visual (translucent blue volume)
    out.append(part_xml(counter, "WaterVisual", "Part", 0, 0, -2500, 9000, 7, 9000,
                        (40, 130, 210), "Glass", 0.45, False, False, "Block"))

    # Dock + spawn at north edge of Sunshall
    out.append(part_xml(counter, "DockPlanks", "Part", 0, -2.6, 60, 40, 1.2, 24, (150, 110, 70)))
    out.append(part_xml(counter, "DockPillar1", "Part", -16, -3.2, 52, 3, 1, 3, (120, 90, 60)))
    out.append(part_xml(counter, "DockPillar2", "Part", 16, -3.2, 52, 3, 1, 3, (120, 90, 60)))
    out.append(part_xml(counter, "SpawnLocation", "SpawnLocation", 0, -1.9, 66, 10, 1, 10,
                        (90, 220, 170), "SmoothPlastic", 0, True, True, "Block",
                        extra=[f'<bool name="Neutral">true</bool>', f'<int name="Duration">5</int>']))

    # Market stall
    out.append(part_xml(counter, "StallTable", "Part", 12, -2.6, 84, 10, 1, 6, (160, 120, 70)))
    out.append(part_xml(counter, "StallPost1", "Part", 9, -2.0, 81, 1, 2.6, 1, (140, 100, 60)))
    out.append(part_xml(counter, "StallPost2", "Part", 15, -2.0, 87, 1, 2.6, 1, (140, 100, 60)))
    out.append(part_xml(counter, "StallRoof", "Part", 12, -0.4, 84, 14, 0.5, 14, (200, 60, 60)))
    out.append(part_xml(counter, "StallSign", "Part", 12, -0.9, 84, 12, 0.3, 12, (255, 210, 90)))

    # Old Salt NPC (simple blocky fisherman)
    out.append(part_xml(counter, "OldSaltBody", "Part", -20, -2.35, 70, 2.4, 3, 1.4, (70, 90, 130)))
    out.append(part_xml(counter, "OldSaltHead", "Part", -20, -0.65, 70, 1.3, 1.3, 1.3, (255, 220, 190), "SmoothPlastic", 0, True, True, "Ball"))
    out.append(part_xml(counter, "OldSaltHat", "Part", -20, 0.0, 70, 1.6, 0.5, 1.6, (60, 60, 60)))
    out.append(part_xml(counter, "OldSaltBeard", "Part", -20, -0.85, 69.4, 0.9, 0.9, 0.5, (230, 230, 230)))

    # Zones: floor disc + buoy + name tag + region part
    for zid, z in ZONES.items():
        x, zz = z["pos"]
        wx, wz = z["size"]
        col = z["color"]
        # Tinted floor disc (thin cylinder)
        out.append(part_xml(counter, f"ZoneDisc_{zid}", "Part", x, -3.0, zz, wx * 0.6, 0.3, wz * 0.6,
                            col, "SmoothPlastic", 0.55, True, True, "Cylinder"))
        # Buoy (pole + neon ball)
        out.append(part_xml(counter, f"BuoyPole_{zid}", "Part", x, 0.5, zz, 0.6, 8, 0.6, (90, 90, 100)))
        out.append(part_xml(counter, f"BuoyBall_{zid}", "Part", x, 4.6, zz, 2.4, 2.4, 2.4, col, "Neon", 0, True, True, "Ball"))
        # Name tag
        out.append(billboard_tag(counter, z["label"], col, 8.5))
        # Region part (the one the server actually uses)
        out.append(part_xml(counter, f"ZoneRegion_{zid}", "Part", x, 0, zz, wx, 80, wz,
                            (255, 255, 255), "SmoothPlastic", 1.0, False, False, "Block"))

    out.append(item_close("\t"))
    return "\n".join(out)

def build() -> str:
    counter = Counter()
    out = []
    out.append('<?xml version="1.0" encoding="utf-8"?>')
    out.append('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
               'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
               'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">')
    out.append(item_open("DataModel", counter.next("datamodel"), ""))
    out.append(props([f'<string name="Name">Tidebound</string>']))

    # Workspace
    out.append(workspace_xml(counter))

    # Lighting (defaults)
    out.append(item_open("Lighting", counter.next("lighting"), "\t"))
    out.append(props([f'<string name="Name">Lighting</string>']))
    out.append(item_close("\t"))

    # ReplicatedStorage/Shared/*
    rs_ref = counter.next("ReplicatedStorage")
    out.append(item_open("ReplicatedStorage", rs_ref, "\t"))
    out.append(props([f'<string name="Name">ReplicatedStorage</string>']))
    shared_ref = counter.next("ReplicatedStorage/Shared")
    out.append("\t\t" + item_open("Folder", shared_ref, "\t"))
    out.append("\t\t" + props([f'<string name="Name">Shared</string>']))
    prefix = "ReplicatedStorage/Shared/"
    children = sorted((k, v) for k, v in TREE.items() if k.startswith(prefix) and "/" not in k[len(prefix):])
    for cl, cc in children:
        ref = counter.next(cl)
        indent = "\t\t"
        out.append(indent + item_open(cc, ref, indent))
        ps = [f'<string name="Name">{esc(cl.split("/")[-1])}</string>']
        if cc in ("ModuleScript", "Script", "LocalScript"):
            ps.append(f'<ProtectedString name="Source">{b64w(source_for(cl))}</ProtectedString>')
        if cc in ("Script", "LocalScript"):
            ps.append(f'<bool name="Enabled">true</bool>')
        out.append(props(ps))
        # nested Data folder
        if cc == "Folder":
            dprefix = cl + "/"
            dchildren = sorted((k, v) for k, v in TREE.items() if k.startswith(dprefix) and "/" not in k[len(dprefix):])
            for dl, dc in dchildren:
                dref = counter.next(dl)
                out.append("\t\t\t" + item_open(dc, dref, "\t\t\t"))
                psd = [f'<string name="Name">{esc(dl.split("/")[-1])}</string>']
                if dc in ("ModuleScript", "Script", "LocalScript"):
                    psd.append(f'<ProtectedString name="Source">{b64w(source_for(dl))}</ProtectedString>')
                out.append(props(psd))
                out.append("\t\t\t" + item_close("\t\t\t"))
        out.append(indent + item_close(indent))
    out.append("\t\t" + item_close("\t\t"))
    out.append("\t" + item_close("\t"))

    # ServerScriptService
    out.append(item_open("ServerScriptService", counter.next("ServerScriptService"), "\t"))
    out.append(props([f'<string name="Name">ServerScriptService</string>']))
    # Bootstrap script
    boot_ref = counter.next("ServerScriptService/Bootstrap")
    out.append("\t\t" + item_open("Script", boot_ref, "\t\t"))
    out.append("\t\t" + props([f'<string name="Name">Bootstrap</string>',
                               f'<ProtectedString name="Source">{b64w(source_for("ServerScriptService/Bootstrap"))}</ProtectedString>',
                               f'<bool name="Enabled">true</bool>']))
    out.append("\t\t" + item_close("\t\t"))
    # Services folder
    sref = counter.next("ServerScriptService/Services")
    out.append("\t\t" + item_open("Folder", sref, "\t\t"))
    out.append("\t\t" + props([f'<string name="Name">Services</string>']))
    sprefix = "ServerScriptService/Services/"
    schildren = sorted((k, v) for k, v in TREE.items() if k.startswith(sprefix) and "/" not in k[len(sprefix):])
    for cl, cc in schildren:
        ref = counter.next(cl)
        out.append("\t\t\t" + item_open(cc, ref, "\t\t\t"))
        ps = [f'<string name="Name">{esc(cl.split("/")[-1])}</string>',
              f'<ProtectedString name="Source">{b64w(source_for(cl))}</ProtectedString>']
        if cc in ("Script", "LocalScript"):
            ps.append(f'<bool name="Enabled">true</bool>')
        out.append(props(ps))
        out.append("\t\t\t" + item_close("\t\t\t"))
    out.append("\t\t" + item_close("\t\t"))
    out.append("\t" + item_close("\t"))

    # StarterPlayer > StarterPlayerScripts
    out.append(item_open("StarterPlayer", counter.next("StarterPlayer"), "\t"))
    out.append(props([f'<string name="Name">StarterPlayer</string>']))
    sps_ref = counter.next("StarterPlayer/StarterPlayerScripts")
    out.append("\t\t" + item_open("StarterPlayerScripts", sps_ref, "\t\t"))
    out.append("\t\t" + props([f'<string name="Name">StarterPlayerScripts</string>']))
    cprefix = "StarterPlayer/StarterPlayerScripts/"
    cchildren = sorted((k, v) for k, v in TREE.items() if k.startswith(cprefix) and "/" not in k[len(cprefix):])
    for cl, cc in cchildren:
        ref = counter.next(cl)
        indent = "\t\t"
        out.append(indent + item_open(cc, ref, indent))
        ps = [f'<string name="Name">{esc(cl.split("/")[-1])}</string>']
        if cc in ("ModuleScript", "Script", "LocalScript"):
            ps.append(f'<ProtectedString name="Source">{b64w(source_for(cl))}</ProtectedString>')
        if cc in ("Script", "LocalScript"):
            ps.append(f'<bool name="Enabled">true</bool>')
        out.append(props(ps))
        # nested folders (Controllers, Modules)
        if cc == "Folder":
            nprefix = cl + "/"
            nchildren = sorted((k, v) for k, v in TREE.items() if k.startswith(nprefix) and "/" not in k[len(nprefix):])
            for nl, nc in nchildren:
                nref = counter.next(nl)
                out.append("\t\t\t" + item_open(nc, nref, "\t\t\t"))
                psn = [f'<string name="Name">{esc(nl.split("/")[-1])}</string>']
                if nc in ("ModuleScript", "Script", "LocalScript"):
                    psn.append(f'<ProtectedString name="Source">{b64w(source_for(nl))}</ProtectedString>')
                out.append(props(psn))
                out.append("\t\t\t" + item_close("\t\t\t"))
        out.append(indent + item_close(indent))
    out.append("\t\t" + item_close("\t\t"))
    out.append("\t" + item_close("\t"))

    # SoundService + Players (minimal)
    out.append(item_open("SoundService", counter.next("SoundService"), "\t"))
    out.append(props([f'<string name="Name">SoundService</string>']))
    out.append(item_close("\t"))
    out.append(item_open("Players", counter.next("Players"), "\t"))
    out.append(props([f'<string name="Name">Players</string>']))
    out.append(item_close("\t"))

    out.append(item_close(""))
    out.append("<External>null</External>")
    out.append("</roblox>")
    return "\n".join(out)

def validate(doc: str):
    root = ET.fromstring(doc)
    # count scripts vs expected
    count_scripts = sum(1 for it in root.iter("Item") if it.get("class") in ("Script", "LocalScript", "ModuleScript"))
    expected_scripts = sum(1 for c in TREE.values() if c != "Folder")
    assert count_scripts == expected_scripts, f"script count {count_scripts} != {expected_scripts}"
    # base64 round-trip every ProtectedString
    for it in root.iter("Item"):
        ps = it.find("Properties/ProtectedString")
        if ps is not None and ps.text and ps.text.strip():
            b64 = "".join(ps.text.split())
            decoded = base64.b64decode(b64).decode("utf-8")
            assert decoded.startswith("--!strict") or decoded.startswith("--[["), "bad source start"
    # zone regions present
    names = [it.find("Properties/string[@name='Name']").text for it in root.iter("Item")
             if it.find("Properties/string[@name='Name']") is not None]
    for zid in ZONES:
        assert f"ZoneRegion_{zid}" in names, f"missing ZoneRegion_{zid}"
    # spawn present
    spawn_classes = [it.get("class") for it in root.iter("Item")]
    assert "SpawnLocation" in spawn_classes, "missing SpawnLocation"

if __name__ == "__main__":
    print("Building complete place file...")
    doc = build()
    validate(doc)
    OUT.write_text(doc, encoding="utf-8")
    print(f"  wrote {OUT} ({OUT.stat().st_size/1024:.1f} KB)")
    print("  validated: XML well-formed, all scripts embedded, 8 zone regions, spawn present")
