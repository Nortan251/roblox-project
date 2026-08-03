#!/usr/bin/env python3
"""Generates three .rbxmx model files that import the ENTIRE Tidebound script tree
into Roblox Studio with zero copy-pasting:

  tools/rbxmx/01_replicatedstorage_shared.rbxmx  -> right-click ReplicatedStorage
  tools/rbxmx/02_serverscriptservice.rbxmx       -> right-click ServerScriptService
  tools/rbxmx/03_starterplayer_client.rbxmx      -> right-click StarterPlayer > StarterPlayerScripts

Each file is self-validated (XML well-formed + base64 round-trip) before writing.
Usage: python3 tools/generate_rbxmx.py
"""
import base64, pathlib, xml.etree.ElementTree as ET

SRC = pathlib.Path("/home/user/tidebound/src")
OUT = pathlib.Path("/home/user/tidebound/tools/rbxmx")
OUT.mkdir(exist_ok=True)

# ── Instance tree: logical path -> instance class ─────────────────────────
TREE = {
    # Shared (ReplicatedStorage)
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
    # Server
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
    "ServerScriptService/Services/AutoTerrainService": "Script",
    # Client (StarterPlayer > StarterPlayerScripts)
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

def source_for(logical: str) -> str:
    parts = logical.split("/")
    base = SRC / "/".join(parts)
    for cand in (base.with_suffix(".luau"), base.with_suffix(".server.luau"), base.with_suffix(".client.luau")):
        if cand.exists():
            return cand.read_text()
    raise FileNotFoundError(base)

def xml_escape(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def base64_wrap(data: str) -> str:
    b64 = base64.b64encode(data.encode("utf-8")).decode("ascii")
    return "\n".join(b64[i:i + 76] for i in range(0, len(b64), 76))

class Counter:
    def __init__(self):
        self.n = 0
        self.registry = {}  # referent -> logical path (for validation)
    def next(self, logical: str):
        r = f"RBX{self.n}"
        self.n += 1
        self.registry[r] = logical
        return r

def item_xml(logical: str, cls: str, counter: Counter, depth: int) -> str:
    indent = "\t" * depth
    name = logical.split("/")[-1]
    out = []
    out.append(f'{indent}<Item class="{cls}" referent="{counter.next(logical)}">')
    out.append(f"{indent}\t<Properties>")
    out.append(f'{indent}\t\t<string name="Name">{xml_escape(name)}</string>')
    if cls in ("ModuleScript", "Script", "LocalScript"):
        src = source_for(logical)
        out.append(f'{indent}\t\t<ProtectedString name="Source">{base64_wrap(src)}</ProtectedString>')
    if cls in ("Script", "LocalScript"):
        out.append(f'{indent}\t\t<bool name="Enabled">true</bool>')
    out.append(f"{indent}\t</Properties>")
    # Children
    child_prefix = logical + "/"
    children = [(k, v) for k, v in TREE.items() if k.startswith(child_prefix) and "/" not in k[len(child_prefix):]]
    children.sort(key=lambda kv: kv[0])
    for child_logical, child_cls in children:
        out.append(item_xml(child_logical, child_cls, counter, depth + 1))
    out.append(f"{indent}</Item>")
    return "\n".join(out)

def build_file(targets: list, out_name: str):
    """targets: list of (logical, cls) TOP-LEVEL items to include."""
    counter = Counter()
    body = []
    for logical, cls in targets:
        body.append(item_xml(logical, cls, counter, 1))
    doc = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
        + "\n".join(body)
        + '\n<External>null</External>\n</roblox>\n'
    )
    path = OUT / out_name
    path.write_text(doc, encoding="utf-8")
    # ── Validate ──
    ET.fromstring(doc)  # XML well-formed
    root = ET.fromstring(doc)
    # base64 round-trip for every ProtectedString (matched by referent -> logical)
    for item in root.iter("Item"):
        src = item.find("Properties/ProtectedString")
        if src is not None and src.text and src.text.strip():
            b64 = "".join(src.text.split())
            decoded = base64.b64decode(b64).decode("utf-8")
            logical = counter.registry.get(item.get("referent"))
            if logical is None or source_for(logical) != decoded:
                raise ValueError(f"base64 round-trip mismatch for referent {item.get('referent')} ({logical})")
    size = path.stat().st_size
    print(f"  wrote {out_name}  ({size/1024:.1f} KB, {counter.n} instances)")

if __name__ == "__main__":
    shared_tops = [
        ("ReplicatedStorage/Shared", "Folder"),
    ]
    server_tops = [
        ("ServerScriptService/Bootstrap", "Script"),
        ("ServerScriptService/Services", "Folder"),
    ]
    client_tops = [
        ("StarterPlayer/StarterPlayerScripts/Bootstrap", "LocalScript"),
        ("StarterPlayer/StarterPlayerScripts/Controllers", "Folder"),
        ("StarterPlayer/StarterPlayerScripts/Modules", "Folder"),
    ]
    print("Generating rbxmx import files (validated)...")
    build_file(shared_tops, "01_replicatedstorage_shared.rbxmx")
    build_file(server_tops, "02_serverscriptservice.rbxmx")
    build_file(client_tops, "03_starterplayer_client.rbxmx")
    print("Done. Import order: 01 -> ReplicatedStorage, 02 -> ServerScriptService, 03 -> StarterPlayer > StarterPlayerScripts")
