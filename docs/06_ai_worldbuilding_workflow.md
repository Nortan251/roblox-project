# TIDEBOUND — AI World-Building Workflow (pair me with a designer tool)
*The plan: you run 2 free browser tools (Terrainio + Nilo) to generate designed world assets,
import them into Studio, and I do everything else (logic, systems, placement automation,
publishing). Each tool is 5–15 minutes.*

---

## THE DIVISION OF LABOR (read this once)

| What | Who |
|---|---|
| **Terrain** (islands, cliffs, beaches, mountains) | **Terrainio** (you, 5 min, free) |
| **Buildings/props/meshes** (tavern, houses, ruins, rocks, trees) | **Nilo** (you, 10 min, free) |
| **Game logic** (fishing, economy, quests, saving, security) | **Me** (done — 32 scripts, tested) |
| **Placement automation** (put the imported assets in the right spots, add NPCs/fish/particles) | **Me** (I build a placement script for Studio) |
| **Publishing** | **Me** (already automated — Open Cloud API) |

You are the **art director**: you prompt the tools, eyeball the results, tell me what to fix.
I do the engineering. That's the workflow you asked for.

---

## STEP 1 — TERRAIN (Terrainio, ~5 min, free)

1. Go to **https://terrainio.com/**
2. Sign up (free tier).
3. Type this exact prompt (or adjust to taste):

```
A crescent archipelago of six islands in a turquoise tropical sea.
Main island (north): a large island with a golden sand beach ring,
a flat village plateau in the center, a hill on the north headland
for a lighthouse, and a shallow bay indenting the south coast for a dock.
Island 2 (east): vast shallow lagoon with sandbars.
Island 3 (west): horseshoe of dark cliffs around a deep basin, fog.
Island 4 (south-east): volcanic black cone with a crater.
Island 5 (south): white icy island with pack ice.
Island 6 (center-south): deep trench basin, near-black seabed.
Small hidden isle inside the ring. Sea level covers everything else.
Materials: sand shores, grass highlands, rock cliffs, snow peak, basalt volcano.
```

4. Size: **large** (covers the 8,000 × 8,000 world).
5. Generate → download the **heightmap + colormap ZIP**.
6. In Studio with the Tidebound place open: **Terrain Editor → Create → Import** →
   upload the two maps, set the dimensions to match the game (offset so the islands
   land where the zone parts are: Sunshall at (0,150), Whisper at (0,-1000),
   Drop at (0,-2000), Ember at (0,-3000), Frost at (0,-4000), Abyss at (0,-5000),
   Hidden at (800,-3000), Grotto at (800,-2000)).
7. **Or** (easier): download Terrainio's **starter .rbxlx place** and just copy its
   Terrain into the Tidebound place (drag the Terrain instance over).

---

## STEP 2 — BUILDINGS & PROPS (Nilo, ~10 min, free)

1. Go to **https://nilo.io/** (browser vibe-coding, no install, free tier).
2. Describe the assets you want — **one prompt per asset**, e.g.:

```
A cozy wooden fishing village tavern with a red shingled roof,
a stone chimney, glowing windows, and a hanging sign. Low-poly,
Roblox-optimized, warm storybook style.
```

3. Nilo gives you a live 3D preview; tweak with follow-up prompts until it looks good.
4. **Export as FBX/GLB** → import into Studio via **Asset Manager → Import** (or
   drag the file into the Explorer). Repeat for each asset you want:

   - Tavern (with interior: bar, fireplace)
   - Fishing shack (porch + net)
   - Cottage house (bed interior)
   - Lighthouse (leaning, with lamp room)
   - Market stall (awning)
   - Great Fig Tree (or use Terrainio/Nilo trees)
   - Palm trees ×2 poses
   - Pine trees ×2 sizes
   - Rock clusters ×3 sizes
   - Drowned Kingdom ruins: stone arch (standing), arch (shattered), bell tower,
     statue, pillar, gate (two pillars + lintel)
   - Shipwreck (hull + mast + bow)
   - Rowboat, crates, barrels, rope coils
   - Whale skeleton (for the Abyss)
   - Iceberg cluster, ice chapel (for Frost)
   - Coral + seagrass + kelp (underwater)

5. Name every imported model clearly: `Tavern`, `Shack`, `House`, `Lighthouse`,
   `Ruin_Arch`, `Ruin_Bell`, `Ruin_Statue`, `Ruin_Pillar`, `Ruin_Gate`,
   `Wreck`, `Rowboat`, `PalmA`, `PineA`, `RockCluster`, `WhaleSkeleton`,
   `Iceberg`, `Coral`, `FigTree`, `Well`, `MarketStall`.

---

## STEP 3 — PLACEMENT (ME, automated)

Once the models are in the place with the right names, I build a
**Studio placement script** that:
- deletes the placeholder blocky versions
- drops each real model at its designed spot (Tavern at village green,
  Lighthouse on the north headland, Wreck at The Drop, Ruin kit scattered
  per the world doc, etc.)
- re-attaches the interactivity (Old Salt, market, signs, chest prompts)
  to the real models
- keeps all 32 game scripts untouched

**When you have the assets imported, tell me the model names and I'll generate it.**

---

## STEP 4 — FALLBACK: the free Studio Assistant (if you don't want browser tools)

Roblox Studio has **Roblox Assistant** built in (free, no plugin install):
- **Plugins/Home → Assistant** panel.
- Ask it: *"Build a wooden tavern with a red roof and glowing windows near the
  village green at (0,150)"* — it can create models directly in the place.
- Then tell me what it made and I'll place/connect everything.

---

## STEP 5 — ME: what I'll keep doing (no design needed from you)

- Terrain/fill placement automation (from the world doc coordinates)
- NPC animation rigs, fish schools, particle systems, atmosphere
- All gameplay systems (already done)
- Publishing every version (already automated)

---

## SAFETY NOTE

Only install plugins from the official **Creator Store** (RoPilot / Roblox Assistant)
and only paste API keys into plugins from reputable devs. Terrainio/Nilo are
browser tools that export files — no account passwords needed.

---

## THE BOTTOM LINE

- **You** prompt Terrainio + Nilo (or Studio Assistant) → real designed world assets.
- **I** place them, wire them, and publish.
- This is the division that actually works — a coding agent alone can't sculpt,
  and a designer alone can't engineer. Together it's a real studio.
