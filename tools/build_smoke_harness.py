#!/usr/bin/env python3
"""Tidebound code health check: compiles & smoke-runs every module (server + client)
with a Roblox stub environment, plus server<->client contract tests.
Usage: python3 tools/build_smoke_harness.py && tools/luau-bin/luau /tmp/harness.luau
"""
import pathlib, re

SRC = pathlib.Path("/home/user/tidebound/src")
SIM = pathlib.Path("/home/user/tidebound/tools/sim_tests.luau")

# Logical name -> relative file path (unique keys; Bootstrap disambiguated)
FILES = {}
for p in SRC.rglob("*.luau"):
    rel = p.relative_to(SRC)
    parts = list(rel.parts[:-1]) + [rel.stem]
    while parts and parts[0] in ("ReplicatedStorage", "ServerScriptService", "StarterPlayer", "StarterPlayerScripts"):
        parts = parts[1:]
    if parts:
        parts[-1] = parts[-1].removesuffix(".server").removesuffix(".client")
    name = ".".join(parts)
    if name == "Bootstrap":
        name = "Bootstrap.server" if "ServerScriptService" in str(rel) else "Bootstrap.client"
    FILES[name] = p

def rewrite_source(text: str, path: pathlib.Path) -> str:
    # require(InstancePath) -> __tdRequire("LogicalName")
    # 1. Dynamic requires (targeted, bracket-safe)
    text = re.sub(r'require\(script\.Parent\.Services\[([A-Za-z_]+)\]\)', lambda m: '__tdRequire("Services." .. %s)' % m.group(1), text)
    text = re.sub(r'require\(script\.Services\[([A-Za-z_]+)\]\)', lambda m: '__tdRequire("Services." .. %s)' % m.group(1), text)
    text = re.sub(r'require\(script\.Parent\.Controllers\[([A-Za-z_]+)\]\)', lambda m: '__tdRequire("Controllers." .. %s)' % m.group(1), text)
    # 2. Catalogs: script.Parent.Parent.Types -> Shared.Types (must precede generic)
    text = text.replace("require(script.Parent.Parent.Types)", '__tdRequire("Shared.Types")')
    # 3. Client script-relative
    text = re.sub(r'require\(script\.Parent\.Parent\.([A-Za-z_.]+)\)', lambda m: '__tdRequire("%s")' % m.group(1), text)
    dir_name = path.parent.name  # Modules / Controllers / StarterPlayerScripts / ...
    if dir_name in ("Modules", "Controllers"):
        text = re.sub(r'require\(script\.Parent\.([A-Za-z_.]+)\)', lambda m: '__tdRequire("%s.%s")' % (dir_name, m.group(1)), text)
    else:
        text = re.sub(r'require\(script\.Parent\.([A-Za-z_.]+)\)', lambda m: '__tdRequire("%s")' % m.group(1), text)
    # 4. Inline service-get: require(game:GetService("ReplicatedStorage").Shared.X)
    gs = re.compile(r'require\(game:GetService\("ReplicatedStorage"\)\.([A-Za-z_.]+)\)')
    text = gs.sub(lambda m: '__tdRequire("%s")' % m.group(1), text)
    # 5. Plain instance paths
    pattern = re.compile(r'require\(([A-Za-z_.]+)\)')
    def repl(m):
        expr = m.group(1)
        if expr.startswith("ReplicatedStorage."):
            return '__tdRequire("%s")' % expr[len("ReplicatedStorage."):]
        return m.group(0)
    return pattern.sub(repl, text)

harness = []
harness.append('-- Tidebound smoke harness (generated)\nlocal moduleSources = {}\n')

for name in sorted(FILES):
    src = FILES[name].read_text()
    src = rewrite_source(src, FILES[name])
    if name == "Bootstrap.server":
        # Load server Bootstrap in init-only mode (skip live Start loops)
        src = re.sub(
            r'-- Start\s*for _, name\s+in\s+pairs\(ORDER\) do.*?service:Start\(\)\s*end\s*end',
            '',
            src,
            flags=re.DOTALL,
        )
    harness.append('moduleSources[%r] = [==[%s]==]' % (name, src))

harness.append(r'''
-- ── Roblox stubs (env chained to _G; the CLI _G is read-only) ────────────
local loaded2 = {}
local envBase = setmetatable({}, { __index = _G })

envBase.game = { BindToClose = function(cb) end,
    GetService = function(_, name)
        if name == "ReplicatedStorage" then return envBase.rs end
        if name == "Players" then return envBase.players end
        if name == "DataStoreService" then return envBase.dss end
        if name == "Workspace" then return envBase.ws end
        if name == "MarketplaceService" then return envBase.mps end
        if name == "HttpService" then return envBase.http end
        if name == "TweenService" then return envBase.tween end
        if name == "SoundService" then return envBase.soundSvc end
        if name == "UserInputService" then return envBase.uis end
        if name == "RunService" then return envBase.runSvc end
        return {}
    end }
envBase.rs = { Name = "ReplicatedStorage", FindFirstChild = function() return nil end }
envBase.players = {
    PlayerAdded = { Connect = function() end },
    PlayerRemoving = { Connect = function() end },
    GetPlayers = function() return {} end,
    LocalPlayer = { UserId = 1, Name = "LocalPlayer", PlayerGui = {} },
}
envBase.ws = {
    DescendantAdded = { Connect = function() end },
    FindFirstChild = function() return nil end,
    CurrentCamera = { CFrame = { LookVector = { X = 0, Y = 0, Z = -1 } } },
}
envBase.dss = { GetDataStore = function() return { GetAsync = function() return nil end, SetAsync = function() end } end,
    GetOrderedDataStore = function() return { SetAsync = function() end, GetSortedAsync = function() return { GetCurrentPage = function() return {} end } end } end }
envBase.mps = { ProcessReceipt = { Connect = function() end }, UserOwnsGamePassAsync = function() return false end }
envBase.http = { JSONEncode = function(v) return tostring(v) end, JSONDecode = function() return nil end }
envBase.tween = { Create = function() return { Play = function() end, Cancel = function() end, Completed = { Wait = function() end } } end }
envBase.soundSvc = {}
envBase.uis = {
    InputBegan = { Connect = function() end },
    InputEnded = { Connect = function() end },
    GetFocusedTextBox = function() return nil end,
}
envBase.runSvc = { RenderStepped = { Connect = function() end }, Heartbeat = { Connect = function() end } }
envBase.Enum = setmetatable({}, { __index = function(_, k)
    return setmetatable({}, { __index = function(_, k2) return k2 end })
end })
envBase.task = {
    wait = function() end,
    spawn = function(f, ...) local ok, e = pcall(f, ...) if not ok then print("task.spawn: " .. tostring(e)) end end,
    delay = function() end,
}
envBase.TweenInfo = { new = function() return {} end }
envBase.NumberSequence = { new = function() return {} end }
envBase.NumberRange = { new = function() return {} end }
envBase.ColorSequence = { new = function() return {} end }

-- Instance stub with parent/children tracking (enables UI structure tests)
envBase.Instance = { new = function(cls)
    local inst = { ClassName = cls, Parent = nil, _children = {} }
    inst.GetChildren = function(self)
        local out = {}
        for k in pairs(self._children) do table.insert(out, k) end
        return out
    end
    inst.GetDescendants = function(self)
        local out = {}
        local function walk(i)
            for _, c in pairs(i._children) do table.insert(out, c) walk(c) end
        end
        walk(self)
        return out
    end
    inst.FindFirstChild = function(self, name)
        for _, c in pairs(self._children) do if c.Name == name then return c end end
        return nil
    end
    inst.IsA = function(self, className) return self.ClassName == className end
    inst.Destroy = function(self) self.Parent = nil end
    inst.Clone = function(self) return self end
    inst.Play = function() end
    inst.Stop = function() end
    inst.Disconnect = function() end
    if cls == "RemoteEvent" then
        inst.OnServerEvent = { Connect = function() end }
        inst.OnClientEvent = { Connect = function() end }
        inst.FireServer = function() end
        inst.FireClient = function() end
        inst.FireAllClients = function() end
    end
    if cls == "TextButton" then
        inst.MouseButton1Click = { Connect = function() end }
        inst.MouseButton1Down = { Connect = function() end }
        inst.MouseButton1Up = { Connect = function() end }
        inst.MouseEnter = { Connect = function() end }
        inst.MouseLeave = { Connect = function() end }
    end
    if cls == "Model" then
        inst.GetPivot = function() return { Position = { X = 0, Y = 0, Z = 0 } } end
        inst.GetExtentsSize = function() return { Magnitude = 1 } end
    end
    local mt = {
        __newindex = function(t, k, v)
            rawset(t, k, v)
            if k == "Parent" and v ~= nil and type(v) == "table" then
                if not v._children then v._children = {} end
                v._children[t] = t
            end
        end,
    }
    return setmetatable(inst, mt)
end }
local function makeColor(r, g, b)
    local c = { R = r, G = g, B = b }
    c.Lerp = function(self, _other, _t) return self end
    return c
end
envBase.Color3 = { fromRGB = function(r, g, b) return makeColor(r / 255, g / 255, b / 255) end,
    new = function(r, g, b) return makeColor(r, g, b) end,
    Lerp = function(self, _other, _t) return self end }
envBase.Vector2 = { new = function(x, y) return { X = x, Y = y } end }
envBase.Vector3 = { new = function(x, y, z)
    x, y, z = x or 0, y or 0, z or 0
    return { X = x, Y = y, Z = z, Magnitude = math.sqrt(x * x + y * y + z * z), Unit = { X = 1, Y = 0, Z = 0 } }
end }
local cfMeta = { __mul = function(a, _b) return a end }
envBase.CFrame = {
    new = function() return setmetatable({ Position = { X = 0, Y = 0, Z = 0 }, LookVector = { X = 0, Y = 0, Z = -1 } }, cfMeta) end,
    Angles = function() return setmetatable({}, cfMeta) end,
}
envBase.UDim = { new = function() return {} end }
envBase.UDim2 = { new = function() return {} end, fromScale = function() return {} end, fromOffset = function() return {} end }
envBase.Player = {}
envBase.script = { Name = "harness", Parent = nil }
envBase.warn = function(...) print("[warn]", ...) end
envBase.tick = os.clock
envBase.__tdHarnessCtx = {} -- client Bootstrap writes its ctx here when present

function envBase.__tdRequire(key)
    if loaded2[key] then return loaded2[key] end
    local src = moduleSources[key]
    if not src then error("Harness: unknown module " .. tostring(key)) end
    local chunk, err = loadstring(src, "@" .. key)
    if not chunk then error("Harness: syntax error in " .. key .. ": " .. tostring(err)) end
    setfenv(chunk, envBase)
    local ok, result = xpcall(chunk, function(e)
        return debug.traceback(tostring(e), 2)
    end)
    if not ok then error("Harness: runtime error in " .. key .. ":\n" .. tostring(result)) end
    loaded2[key] = result
    return result
end
''')

order = [
    "Shared.Config", "Shared.Types", "Shared.Util", "Shared.Remotes",
    "Shared.Data.QuestCatalog", "Shared.Data.ZoneCatalog", "Shared.Data.RodCatalog", "Shared.Data.FishCatalog",
    "Shared.Data.CosmeticsCatalog",
    "Services.SecurityService", "Services.DataService",
    "Services.EconomyService", "Services.InventoryService",
    "Services.QuestService", "Services.EventService",
    "Services.LeaderboardService", "Services.ShopService",
    "Services.WorldInteractionsService", "Services.FishingService",
    "Services.TravelService", "Services.AmbienceService",
    "Bootstrap.server",
    "Modules.Theme", "Modules.UiKit", "Modules.ClientState", "Modules.FishVisuals",
    "Controllers.AudioController", "Controllers.GuideController", "Controllers.CastController",
    "Controllers.UIController", "Controllers.MenuUIController",
    "Bootstrap.client",
]
harness.append("local order = {\n" + "\n".join('    "%s",' % o for o in order) + "\n}")
harness.append(r'''
local failures = 0
for _, name in ipairs(order) do
    local ok, err = pcall(function() return envBase.__tdRequire(name) end)
    if ok then
        print("[OK] " .. name)
    else
        failures += 1
        print("[FAIL] " .. name .. " -> " .. tostring(err))
    end
end

local checks = 0
local function check(cond, label)
    checks += 1
    if cond then print("[PASS] " .. label) else print("[FAIL] " .. label); failures += 1 end
end

-- ── Shared module functional tests ──────────────────────────
local Util = envBase.__tdRequire("Shared.Util")
local Config = envBase.__tdRequire("Shared.Config")
local Fish = envBase.__tdRequire("Shared.Data.FishCatalog")
local Zone = envBase.__tdRequire("Shared.Data.ZoneCatalog")
local Rods = envBase.__tdRequire("Shared.Data.RodCatalog")
local Quests = envBase.__tdRequire("Shared.Data.QuestCatalog")

check(Util.weightedPick({ a = 1, b = 2 }) ~= nil, "weightedPick returns a key")
check(Util.clamp(5, 0, 3) == 3, "clamp upper")
check(Util.round(1.234, 2) == 1.23, "round")
check(Util.formatNumber(1234) == "1.2K", "formatNumber K")
check(#Util.keys(Config.RARITY_WEIGHTS) == 6, "6 rarities")
local all = Fish.GetAll()
local total = 0
for _ in pairs(all) do total += 1 end
check(total >= 45, "fish catalog size >= 45 (got " .. total .. ")")
check(Fish.Get("old_one") ~= nil, "old one exists")
for _, zdef in pairs(Zone.GetAll()) do
    local day = Fish.GetZoneFish(zdef.id, false, false)
    local night = Fish.GetZoneFish(zdef.id, true, false)
    check(#day + #night >= 4, "zone " .. zdef.id .. " has fish (day:" .. #day .. " night:" .. #night .. ")")
end
local sum = 0
for _, w in pairs(Config.RARITY_WEIGHTS) do sum += w end
check(sum == 1000, "rarity weights sum to 1000")
local sorted = Rods.GetSorted()
local prev = -1
local ladderOk = true
for _, r in ipairs(sorted) do if r.cost <= prev then ladderOk = false end prev = r.cost end
check(ladderOk, "rod ladder strictly increasing")
check(#Quests.DAILY_POOL == 8 and #Quests.WEEKLY_POOL == 5, "quest pool sizes")
check(Config.STREAK_REWARDS[7].pearls == 25, "streak day 7 = 25 pearls")

-- ── Client module functional tests ───────────────────────────
local ClientState = envBase.__tdRequire("Modules.ClientState")
ClientState:Apply("StateSync", { coins = 123, pearls = 7, level = 4, xp = 55 })
local cs = ClientState:Get()
check(cs.coins == 123 and cs.pearls == 7 and cs.level == 4, "ClientState:Apply StateSync")
ClientState:Apply("InventorySync", { inventory = { { uid = 1 } }, bestiary = {}, globalPct = 12, invSlots = 60 })
check(#cs.inventory == 1 and cs.globalPct == 12, "ClientState:Apply InventorySync")
ClientState:Apply("WorldState", { timeOfDay = "night", isStorm = true })
check(cs.timeOfDay == "night" and cs.isStorm == true, "ClientState:Apply WorldState")
ClientState:Apply("QuestUpdate", { daily = { { templateId = "x" } }, weekly = {}, streak = 3 })
check(#cs.dailyQuests == 1 and cs.streak == 3, "ClientState:Apply QuestUpdate")

local FishVisuals = envBase.__tdRequire("Modules.FishVisuals")
local model = FishVisuals.Build("gilded_bass", true)
local parts = model:GetChildren()
check(#parts >= 5, "FishVisuals builds >=5 parts (got " .. #parts .. ")")
local bodyPart = model:FindFirstChild("Body")
check(bodyPart ~= nil and bodyPart:FindFirstChild("ShinySparkle") ~= nil, "shiny fish has sparkle emitter on body")

-- ── Server <-> client contract ───────────────────────────────
local clientCtx = envBase.__tdHarnessCtx
check(clientCtx ~= nil, "client bootstrap exposed ctx to harness")
local handlerTypes = {}
if clientCtx and clientCtx.Handlers then
    for t, _ in pairs(clientCtx.Handlers) do handlerTypes[t] = true end
end
local serverTypes = {
    "StateSync", "CatchResult", "Bite", "ReelState", "EventBanner", "LevelUp",
    "BestiaryUpdate", "QuestUpdate", "AchievementUnlock", "StreakUpdate",
    "FeedMessage", "WorldState", "InventorySync", "PassGranted", "ProductGranted",
}
for _, t in ipairs(serverTypes) do
    local consumed = handlerTypes[t] == true
        or t == "StateSync" or t == "InventorySync" or t == "QuestUpdate" -- handled by ClientState:Apply
    check(consumed, "server->client contract: " .. t)
end
local catchHandlers = clientCtx and clientCtx.Handlers and clientCtx.Handlers["CatchResult"]
check(catchHandlers ~= nil and #catchHandlers >= 2, "CatchResult has multiple handlers (cast + UI)")

print("")
if failures == 0 then
    print("ALL SMOKE TESTS PASSED (" .. checks .. " checks)")
else
    print(failures .. " FAILURES")
    error(failures .. " smoke failures")
end
''')

# Deep simulation tests
harness.append(SIM.read_text())

out = pathlib.Path("/tmp/harness.luau")
out.write_text("\n".join(harness))
print("harness written (%d modules)" % len(FILES))
