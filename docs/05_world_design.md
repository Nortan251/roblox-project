# TIDEBOUND — World Design Document
**The Tidebound Archipelago**
*World & environment bible | v1.0 | Design lead: AAA Level Design review*

> "The ocean here remembers a kingdom that drowned. Every island is a tombstone. Every fish is a story. Cast a line, and pull up a piece of the world that was."

---

# STEP 1 — WORLD IDENTITY

| | |
|---|---|
| **World name** | **The Tidebound Archipelago** |
| **Theme** | Cozy nautical adventure wrapped around a buried mystery |
| **Setting** | A turquoise ocean with a crescent of islands — the peaks of a drowned maritime kingdom |
| **Time period** | Timeless "storybook age" — post-collapse of the Old Kingdom, no modern technology, sail & lantern light |
| **Visual style** | Saturated stylized realism — the look of a watercolor storybook come to life. Low-poly-friendly, painterly lighting, generous fog depth |
| **Mood** | Calm wonder → curiosity → awe → gentle dread at the trench. The ocean is warm and safe; the *deep* is not |
| **Colors** | Turquoise & gold (day) · indigo, teal & bioluminescence (night) · coral, ember, ice-white, abyss-violet (zones) |
| **Weather** | Trade winds, sea mist, sudden squalls, rare great storms (game events), aurora nights at Frostreach |
| **Lighting style** | Permanent golden-hour bias (warm sun, long shadows) with heavy color grading; night is blue-black with light sources that actually matter |
| **Sound atmosphere** | Layered: rolling waves, gull cries, creaking wood, wind in palms; at night — distant whale song; storms — thunder rumble |
| **Memorable hook** | **The Drowned Kingdom.** Bell towers, arches, statues and a giant stone gate scattered underwater across every zone tell the story of a civilization that sank. The bestiary is its encyclopedia; the Old One is its last guardian. Every catch is a piece of a lost world |
| **Spawn feeling** | You arrive on a real island at golden hour. A broken lighthouse on the hill. A village behind you. An endless ocean ahead. Somewhere out there, something huge breaks the surface — and then it's gone. *You want to go look.* |

---

# STEP 2 — FULL MAP DESIGN

## Shape & scale
The world is a **crescent archipelago** in an 8,000 × 8,000-stud sea, arranged so **every island is visible from its neighbors**. Nothing is hidden behind loading — you *see* your next destination, which is the single strongest "explore that way" engine in open-world design.

```
                        [SUNSHALL]  ← spawn, village, lighthouse
                       /          \
        [THE DROP] ←→ [WHISPER LAGOON] ←→ [EMBER FALLS]
              \              |              /
               [ABYSSAL TRENCH] ← [FROSTREACH]  ← south
                  
              (hidden inside the ring:)
        [HIDDEN ISLE OF WHISPERS] · [SUNKEN GROTTO] · [THE OLD ONE'S LAIR]
```

## The crescent logic (why it works)
1. **Sunshall (north)** — safe harbor, all services. The hub you always return to.
2. **The Drop (west)** — the "edge of the shelf," cliffs, wreck, fog. First taste of danger.
3. **Whisper Shallows (east)** — vast shallow lagoon, sandbars, seagrass. Horizontal freedom.
4. **Ember Falls (south-east)** — volcanic island, visible at night by its orange glow on the horizon. The glow is a landmark you navigate by.
5. **Frostreach (far south)** — iceberg field; at night its aurora is visible from Ember and the Drop.
6. **Abyssal Trench (center-south)** — the deepest point, the "belly" of the crescent. Entered last. Every other island's story points here.
7. **Secrets inside the ring** — the Hidden Isle (behind Ember's waterfall) and the Sunken Grotto (cave under the Drop) are the rewards for *not* following the main route.

## Player routes (3 distinct paths)
- **The Sailor's Route** (main quest): Sunshall → Whisper → Drop → Ember → Frost → Abyss. Follows the tall tales Old Salt tells.
- **The Smuggler's Route** (shortcuts): hidden currents behind islands, a cave passage under Sunshall, the mist tunnel between Drop and Frost.
- **The Scholar's Route** (secrets): following the Drowned Kingdom's ruins — bells, arches, statues — leads you to the Hidden Isle and the Grotto.

## Why players travel
- **In-world reasons:** Old Salt's stories ("they say the Trench Devil sleeps where the gate fell"), the hermit's map, zone completion unlocking new tall tales.
- **Mechanical reasons:** new fish (bestiary %), better rods, quests, contest grounds, the pearl chests.
- **Emotional reasons:** the horizon always shows something — a glow, a silhouette, an aurora — and the night changes everything.

---

# STEP 3 — STARTING AREA (extreme detail)

## Sunshall Cove — the first 2 minutes

**Spawn:** On the end of the pier at golden hour. The camera is angled so the player sees, in one frame: the village hill behind, the bay ahead, and **the Broken Lighthouse leaning on the north headland** with a gull circling it.

**The "wow" sequence (first 2 minutes):**
1. **0:00 — spawn.** Warm light, gentle waves, gulls. The HUD's first-catch hint fades in. Old Salt is 20 studs away on the pier, *actively casting his rod* (animated). A fish visibly jumps in the bay.
2. **0:10 — the first cast.** Water splash, bobber, and under the clear water you can see **a drowned bell tower** tilted on the seabed, barnacled, half-buried in sand. (First taste of the Drowned Kingdom.)
3. **0:30 — the whale.** Far out at the bay mouth, a whale breaches and slaps the water. It happens once, early, and never repeats for new players. *"What WAS that?"*
4. **1:00 — the village reveal.** Walking back from the pier, the path rises slightly and the village opens up: tavern, shack, house, well, the **Great Fig Tree** towering over the green, villagers walking. Smoke rises from the tavern chimney.
5. **2:00 — the lighthouse.** At the edge of the hill, the lighthouse's lamp **sweeps** even in daylight — a slow, broken sweep, as if it still remembers its job.

## The village layout (Sunshall)

| Building | Location | Contents |
|---|---|---|
| **The Rusty Hook tavern** | Village green, west | Bar, fireplace (animated fire + smoke), stools, lanterns, Tessa the keeper, hanging fish, menu board |
| **Bram's Shack** (fishing shop) | East edge, above the beach | Porch with net and crates, lantern, shelves of tackle |
| **The Old Salt's Hut** | North headland, under the lighthouse | Small, weathered, nets + barrel outside |
| **The sleeping house** | Village green, east | Bed interior, warm windows, porch |
| **The well** | Center of the green | Rope, bucket, moss |
| **The Great Fig Tree** | Center of the green | The largest tree on the island; lanterns hang in its branches at night; its roots make natural benches |
| **Market stall** | On the pier approach | Red awning, hanging fish, crates — the "shop" |
| **The dock** | Bay | Main pier with railing + lanterns, rowboat tied up, 3 "CATCH HERE" floats |

## Decoration & life
- Palms lean over the beach; boulders (organic shapes) dot the sand; a stone path winds through the green.
- Fence along the beach edge with a gate that leads down to the water.
- Seagulls on the lighthouse, fish schooling off the pier, villagers on a walking loop (green → well → tavern).
- Lanterns everywhere that matter — the village reads as "warm, safe, inhabited" from the water at night.

## Secrets in the starter area (yes, in the FIRST area)
1. **The Drowned Bell** — swim down off the pier; the bell tolls once at dawn (visual ripple + sound). Touching it gives a one-time pearl gift.
2. **The Smuggler's Cave** — behind the beach rocks on the east; a hidden passage with a small cache (one-time coins + a journal line that hints at the Hidden Isle).
3. **The Fig Tree's hollow** — an achievement for finding the old coin wedged in the roots.

## First-2-minute sound & light
- **Sound:** rolling waves, gulls, creaking pier, a distant ship's bell, tavern door creak when near.
- **Light:** golden-hour sun (warm 1.2 brightness), long soft shadows, glitter path on the water, bloom on the sun.

---

# STEP 4 — EVERY AREA

## 1. Sunshall Cove (Starter / Hub)
- **Purpose:** spawn, tutorial, all services, emotional home base.
- **Visual:** golden beach, leaning palms, whitewashed village, turquoise bay, broken lighthouse on the hill.
- **Terrain:** real island (bay indentation, plateau for the village, hill north with the lighthouse, beach ring).
- **Buildings:** tavern, shack, house, well, market, pier, lighthouse (interior: spiral ramp + lamp room with the sweeping light).
- **Props:** crates, barrels, nets, ropes, buoys, boats, fishing floats, fence, path stones, gulls, fish.
- **Colors:** sand gold, sea turquoise, warm wood, terracotta roofs, lighthouse white/red.
- **Lighting:** golden hour always; lanterns + tavern windows at night; lighthouse beam.
- **Ambient:** waves, gulls, creak, tavern murmur (distant chatter).
- **NPCs:** Old Salt (guide, casts his rod), Tessa (tavern keeper), Bram (shack, sits on porch), 2 wandering villagers.
- **Activities:** fishing, buying, questing, the 3 chest-free secret finds, watching whales.
- **Secrets:** Drowned Bell, Smuggler's Cave, Fig Tree coin.
- **Why remembered:** it's *home* — the place you return to after every trip, and it glows at night.

## 2. Whisper Shallows (Intermediate / Freedom)
- **Purpose:** the "open sea" moment — a giant shallow lagoon that feels endless.
- **Visual:** knee-deep turquoise water over white sand, endless seagrass swaying, sandbars glittering, a stone arch, a tiny palm islet.
- **Terrain:** very shallow seabed with sandbar ridges; the arch frames the view of Sunshall behind you — a *screenshot* sightline.
- **Buildings:** none — just a half-drowned ruin (the **Whisper Arch's fallen sister**) and a mooring post.
- **Props:** seagrass fields (hundreds), sandbars, islet with one palm + rock, the arch, coral clumps, glassy shallow pools with tiny fish.
- **Colors:** cyan, white-gold sand, seagrass green, pale sky.
- **Lighting:** brightest area of the game; water sparkle particles at noon.
- **Ambient:** gentle shallow-water lap, wind through grass, distant gull.
- **NPCs:** a wandering **shell-gatherer** (rare) who nods and moves on; night shows **lanternfish swarms** (light particles) — the "wow" of this zone at night.
- **Activities:** bestiary completion, catching night fish, finding the ruin.
- **Secrets:** the **Sunken Bell** of the shallows (second bell), a **drowned house** visible through clear water (doorway you can swim into — a tiny room with a shelf and a pearl), the arch's keystone.
- **Why remembered:** it's the "aha — the world is bigger than the island" moment. Endless, bright, free.

## 3. The Drop (Intermediate / Dread)
- **Purpose:** the first time the sea is *not* friendly — a vertical cliff where the shelf ends.
- **Visual:** a wall of dark cliff arcing around a deep basin; fog wisps rolling; the **Dawnbreaker shipwreck** impaled on rocks; a broken watchtower on the cliff edge.
- **Terrain:** horseshoe cliff (~20-26 studs tall) around a circular deep; fog volume; a beach of dark stones.
- **Buildings/structures:** the wreck (hull, deck, mast, planks, anchor), the **Abandoned Watchtower** (climbable, with a rusted bell and a view), the **Shattered Arch** (fallen sister of the Whisper Arch — visual storytelling: the same arch, collapsed, at the deep end).
- **Props:** fog wisps, jagged rocks, ship debris, a rope ladder down the cliff, floating driftwood.
- **Colors:** slate blue, iron gray, pale fog, the wreck's warm rotting wood.
- **Lighting:** cold, diffused; fog eats distance; at night the fog glows faintly.
- **Ambient:** deep water rumble, creaking wreck, distant groan of the hull, fog-siren-like gull.
- **NPCs:** a **lone fisherman** on the cliff ("nobody comes here twice"), who gives a tall tale about the Trench Devil.
- **Activities:** wreck diving (bestiary), fog fishing, exploring the tower.
- **Secrets:** the **wreck's captain's chest** (one-time pearls, found in the cabin), the **tower's logbook** (lore fragment), the rope-ladder path to a hidden rock shelf with a rare night fish.
- **Why remembered:** the mood shift. First zone that *feels* dangerous — and the wreck is the best screenshot in the mid-game.

## 4. Ember Falls (Advanced / Awe)
- **Purpose:** the volcanic island — the "postcard" zone.
- **Visual:** a black volcanic cone with a glowing lava throat, rivers of cooled basalt, a **waterfall that falls into the sea**, ash-speckled shore, ember particles drifting upward.
- **Terrain:** volcanic island (cone ~15 studs), lava pool in the crater, basalt pillars, the east waterfall cliff.
- **Buildings:** none inhabited — a **shrine of the Drowned Kingdom** at the base of the falls (stone arch + offering bowl + glow), which is the zone's story beat.
- **Props:** lava cracks (glowing), basalt columns, ember particle updrafts, heat shimmer, the waterfall's mist.
- **Colors:** black, ember orange, red, steam white, night-sky purple.
- **Lighting:** the crater glows at night — **visible from Whisper Shallows**, the "navigate by the glow" moment; waterfall lit warm from below.
- **Ambient:** low rumble, crackle, waterfall roar, wind through the crater.
- **NPCs:** a **pilgrim** kneeling at the shrine (animated bow), who trades a rumor for the hermit's map fragment.
- **Activities:** lava-adjacent fishing (storm fish here feel earned), shrine offerings (leave a fish → small pearl blessing once a day), waterfall exploration.
- **Secrets:** **behind the waterfall** — the passage to the Hidden Isle (the big secret of the game); the **offering bowl** daily reward; a **basalt cave** with ember crystals.
- **Why remembered:** the glow on the horizon + the waterfall reveal. It's the "wow" peak before the cold.

## 5. Frostreach (Advanced / Beauty)
- **Purpose:** the serene, beautiful, cold zone — a palette cleanser that still has teeth.
- **Visual:** icebergs like floating cathedrals, snow-covered floes, **aurora bands** rippling at night, glowing ice crystals, a **ship frozen in the ice** (mast and sails iced over).
- **Terrain:** pack-ice with berg clusters, snow fields on the main floe, the frozen ship at the center.
- **Buildings:** the **Ice Chapel** (a half-frozen shrine of the Old Kingdom, stained-glass ice windows) — the zone's story beat.
- **Props:** icebergs (various), snow patches, ice crystals (neon), aurora ribbons (semi-transparent wedges), a frozen sail.
- **Colors:** white, pale blue, aurora green/violet, deep navy sky.
- **Lighting:** coldest light of the game; aurora at night (visible from Ember and the Drop — the second "navigate by sky" moment).
- **Ambient:** wind, ice creaking, aurora hum (low soft tone at night).
- **NPCs:** a **frostbitten hermit** in a snow cave — gives a map fragment and warns about the Trench.
- **Activities:** night fishing under the aurora, crystal hunting, the frozen ship's hold (bestiary + a pearl).
- **Secrets:** the **hermit's map fragment**, the **frozen ship's chest**, an **aurora pool** (hot spring under the aurora — warm glow in the snow, a "rest" spot).
- **Why remembered:** it's beautiful, and the aurora at night is the game's most screenshot-worthy sky.

## 6. Abyssal Trench (Endgame / Dread-Beauty)
- **Purpose:** the belly of the crescent — the deepest, darkest, most rewarding place.
- **Visual:** near-black water, bioluminescent fields (drifting glowing orbs), basalt pillars like teeth, a **giant whale skeleton** arched over the hunting ground, the **Trench Gate** (two colossal stone pillars, fallen lintel) — the front door of the Drowned Kingdom.
- **Terrain:** the deep basin, pillar clusters, the skeleton, the gate.
- **Buildings:** none — this whole zone IS the ruin. The gate, a fallen statue, scattered pillars.
- **Props:** bioluminescent orbs (40+), the whale skeleton, the gate, a drowned **treasure chest** glowing at the gate's foot, deep pressure shimmer.
- **Colors:** void blue, bioluminescence cyan/green/violet, skeleton bone-white.
- **Lighting:** almost no light except bioluminescence + your bobber; PointLights feel like islands of safety.
- **Ambient:** deep pressure hum, whale song at night (louder here), the skeleton creaking.
- **NPCs:** none living — but the **statue** of the last king of the Old Kingdom faces the gate, and the hermit's map confirms what you suspected: *the kingdom drowned when the gate fell*.
- **Activities:** endgame fishing (Leviathan, Stormcaller Eel), the **Old One's Lair** (deepest point, a dark throat in the seabed — the trigger for the secret boss).
- **Secrets:** the **Old One** itself, the **gate keystone** (a pearl-rich offertory), the skeleton's eye socket (hidden cache).
- **Why remembered:** the reveal. Every zone hinted at this; here the whole story clicks into place. And then something moves in the dark.

## 7. Hidden Isle of Whispers (Secret)
- **Purpose:** the reward for curiosity — the hidden heart of the map.
- **Visual:** a tiny perfect isle with two palms, a **floating rock with a waterfall** pouring from it, mist, a small chest on the sand, and — on the back shore — a **cairn** (three stacked stones) marking a grave.
- **Reach:** behind Ember's waterfall (swim through), then a short hidden channel.
- **Story:** the hermit's map says a woman "went to meet the kingdom" — the cairn is hers. The isle is the gentlest, most poignant place in the game.
- **Activities:** 2 unique fish (Mistfin, Isle Song), the isle chest, reading the cairn's inscription (lore).
- **Why remembered:** it feels *found*. A place that exists only for the player who looked.

## 8. Sunken Grotto (Secret)
- **Purpose:** the "dungeon-lite" secret — a cave under the Drop.
- **Visual:** a ring of rock walls, stalactites, **glowing crystals** (green/violet), a dark glassy pool, the grotto chest on a stone plinth.
- **Reach:** a cave mouth at the base of the Drop's cliff (visible only from the water at low angle), or the rope-ladder shelf.
- **Activities:** 2 unique fish (Grotto Glowfin, Sunken King), the chest, crystal hunting.
- **Why remembered:** the only fully enclosed space in the game — the sound changes (echoes), the light changes, and it's the closest thing to a "room" in an ocean game.

---

# STEP 5 — ENVIRONMENT DETAILS (fill every empty space)

**Rules of density:** every 100 studs of swim has *something*: a rock cluster, a fish school, a patch of kelp, a buoy, a half-sunk crate, a coral head. Every sightline ends in something: an island, a glow, a silhouette, a ruin.

**The filler kit (reusable pieces):**
- **Rocks** — organic blobs in 4 sizes, 3 tint variants per zone (sand-warm, cliff-gray, basalt-black, ice-white).
- **Plants** — palms (4 poses), pines (3 sizes), seagrass (clumped), kelp (tall, swaying), coral (5 species, neon-tipped), crystals (Frost/Abyss/Grotto).
- **Wreckage** — crates, barrels, planks, oars, rope coils, half-sunk rowboats, a floating door. Scattered near every ruin.
- **Ruins** — the Drowned Kingdom kit: **arches** (3 states: standing/shattered/collapsed), **bells** (3), **statues** (2), **pillars** (4 states), **gates** (2), **platforms** (3). All barnacled, sand-drifted, with coral grown over them. *These are the environmental storytellers.*
- **Signs & markers** — buoys, "CATCH HERE" floats, zone name tags, wreck warning signs, the hermit's carved arrows (secret trails).
- **Atmosphere props** — fog wisps, ember particles, aurora ribbons, bioluminescent orbs, snow drift, waterfall mist, heat shimmer, storm rain sheets.

**Why every object has a reason:** rocks block sightlines (discovery), ruins tell the story, buoys guide, fish schools make water feel alive, wreckage implies events. Nothing is decoration-for-its-own-sake; everything is either a *guide*, a *story*, or a *reward hint*.

---

# STEP 6 — 22 LANDMARKS (each worth a screenshot)

| # | Landmark | Zone | Why players visit | Screenshot moment |
|---|---|---|---|---|
| 1 | **The Broken Lighthouse** | Sunshall | The first thing you see; its beam sweeps day and night | Its lamp against a sunset sky |
| 2 | **The Great Fig Tree** | Sunshall | Village center, lanterns at night, hidden coin | Night, lanterns in its branches |
| 3 | **The Drowned Bell** | Sunshall bay | One-time pearl, first Drowned-Kingdom taste | Dawn: the ripple as it tolls |
| 4 | **The Smuggler's Cave** | Sunshall | Secret cache + first lore hint | Its entrance hidden behind rocks |
| 5 | **The Whale Watch** | Sunshall bay mouth | The whale breach at spawn | The breach itself |
| 6 | **The Whisper Arch** | Whisper Shallows | Frames the view back to Sunshall | The arch framing the island |
| 7 | **The Sunken House** | Whisper Shallows | Swim into a drowned room | Through its clear-water doorway |
| 8 | **The Second Bell** | Whisper Shallows | Completes the bell mystery | Barnacled, glowing at night |
| 9 | **The Glass Shoal** | Whisper Shallows | A migration of translucent fish | Sunlight through the shoal |
| 10 | **The Dawnbreaker Wreck** | The Drop | Bestiary + captain's chest + story | The mast against the fog |
| 11 | **The Abandoned Watchtower** | The Drop | Climbable, rusted bell, best view of the crescent | View from the tower at dusk |
| 12 | **The Shattered Arch** | The Drop | The arch's fallen twin — story beat | The fallen keystone |
| 13 | **The Serpent's Spine** | The Drop | A rock ridge shaped like a sea serpent | Low sun along its "back" |
| 14 | **Mount Cinder / The Caldera** | Ember Falls | The glow on the horizon; storm fishing | Crater glow at night |
| 15 | **The Falls of Ember** | Ember Falls | The waterfall into the sea; hidden passage behind | Waterfall + mist + sunset |
| 16 | **The Ashen Shrine** | Ember Falls | Offer fish for a daily blessing | Pilgrim kneeling at dusk |
| 17 | **The Aurora Pools** | Frostreach | Warm pool under the aurora — rest spot | Steam + aurora |
| 18 | **The Ice Chapel** | Frostreach | Frozen stained-glass shrine | Aurora through ice windows |
| 19 | **The Frozen Sailship** | Frostreach | Hold loot + bestiary | Sails of ice at night |
| 20 | **The Whale Skeleton** | Abyssal Trench | The zone's centerpiece, bestiary, hidden cache | Bioluminescence through its ribs |
| 21 | **The Trench Gate** | Abyssal Trench | The story's climax — the fallen gate of the kingdom | The keystone glowing in the dark |
| 22 | **The Old One's Lair** | Abyssal Trench | The secret boss | Whatever it is, surfacing |

*(Plus the Hidden Isle cairn and the Grotto crystals as landmarks 23–24 — small, but the ones players *tell friends about*.)*

---

# STEP 7 — EXPLORATION DESIGN

**The exploration engine — "what's over there?" is always answered by a promise:**
- A glow on the horizon (Ember's caldera, the aurora, bioluminescence at night)
- A silhouette in the mist (the wreck's mast, the gate's pillars, the frozen sails)
- A light in the dark (lanterns, shrine glow, chest glow)
- A sound cue (the bell at dawn, whale song at night, the falls' roar from a distance)

**Hidden paths (8):**
1. Smuggler's Cave (Sunshall) → coin + lore
2. Rope-ladder shelf (The Drop) → rare night fish
3. Behind Ember's waterfall → the Hidden Isle
4. The mist tunnel (between Drop and Frost) → shortcut + fog fish
5. The sunken house doorway (Whisper) → pearl
6. The basalt cave (Ember) → crystals
7. The hermit's carved arrows (Frost → Abyss) → hermit's map
8. The Grotto cave mouth (under the Drop) → the Grotto

**Collectibles (the "journal of the deep"):**
- **The Bells** (3) — find and ring them all (achievement + lore).
- **The Arch stones** (3) — Whisper standing, Drop shattered, Ember's shrine uses the third.
- **The King's statues** (2) — Drop wreck figurehead, Abyss last-king statue.
- **The Map fragments** (3) — Ember pilgrim, Frost hermit, Grotto chest → assemble the Old Kingdom map (shows the Lair).
- **One-time chests** (5) — Sunken, Isle, Grotto, Wreck's captain, Frozen hold.

**Mysteries (never fully explained — the best kind):**
- Who rang the bells? Why did the kingdom drown?
- The cairn on the Hidden Isle — who is buried there?
- Why does the Old One remember *your* name?
- The lighthouse still sweeps. Who keeps it wound?

**Environmental puzzles (light-touch):**
- The shrine offering (leave a fish → daily blessing).
- The bell timing (dawn-only reward).
- The keystone (the gate's fallen lintel can be "offered to" for pearls).

---

# STEP 8 — NPC & LIFE DESIGN

**Named characters (8):**
| NPC | Where | What they do | Why they matter |
|---|---|---|---|
| **Old Salt** | Sunshall pier | Casts his rod endlessly; gives the tutorial + tall tales | The guide; the heart of the game |
| **Tessa** | Rusty Hook tavern | Wipes the bar, lights lanterns at dusk | Makes the tavern feel lived-in; sells rumors (tips about secrets) |
| **Bram** | Fishing shack porch | Mends nets; nods when you pass | The "craftsman" — sells the *story* of each rod |
| **The Wandering Shell-gatherer** | Whisper Shallows | Walks the shallows, collects shells | Rare sight; makes the lagoon feel inhabited |
| **The Lone Fisherman** | The Drop cliff | Stares at the wreck; tells the Trench Devil tale | The zone's mood setter |
| **The Pilgrim** | Ember shrine | Kneels, bows, offers fish | The faith of the Old Kingdom, still alive |
| **The Frost Hermit** | Frost snow cave | Gives map fragments, warns about the Trench | The gatekeeper to endgame |
| **The Statue of the Last King** | Abyssal Trench | Faces the gate, forever | Not alive — but the most "alive" thing in the zone |

**Ambient life (non-named):**
- Gulls orbiting every island (2 per zone)
- Fish schools swimming in every zone + the bay (8-10 fish each, circling)
- Whale breaching at Sunshall bay mouth (scripted, rare)
- Villagers walking the green (2, with swinging arms)
- Lanternfish swarms at Whisper at night
- Ember particles rising from the caldera
- The lighthouse beam sweeping

**Why it feels alive:** every named NPC has a *behavior loop* (not a statue), every zone has *motion* (schools, particles, weather), and the world *reacts* — dawn tolls the bell, dusk lights the tavern, night brings the aurora and the whale song.

---

# STEP 9 — VISUAL POLISH

**Animation ideas:** villagers swing arms while walking; Old Salt's cast loop (swing + bob); the lighthouse beam rotating; fish schools banking; the whale breach (arc + splash + ripple); bells swinging at dawn; shrine flames flickering; palms swaying; the hermit warming hands.

**Particles:** ember updrafts (caldera), waterfall mist, fog wisps, snow drift (Frost), bioluminescent orbs (Abyss, night), lanternfish sparkles (Whisper night), campfire + tavern smoke, heat shimmer (Ember), gold sparkles at golden spots, catch-confetti at rare catches.

**Water effects:** the glitter path at golden hour, wave bobbing on buoys/boats, ripple rings at bites/casts, the dawn bell ripple, boat wakes (future), the whale splash.

**Weather:** trade-wind cloud drift (always), sea mist (The Drop), squall rain (storms), thunder + lightning flash (storms), aurora (Frost nights), ash fall (Ember).

**Day/night cycle:** 20-min day / 6-min night (existing). Day = warm, bright, safe. Night = indigo, light-matters, whale song, bioluminescence, aurora. **The same place, a different game** — the strongest retention tool in the palette.

**Special moments (designed, not accidental):**
- Dawn: the Drowned Bell tolls (if you're there)
- Dusk: tavern lanterns light, one by one
- Night: the aurora ignites over Frostreach
- Storm: the caldera glows through the rain
- The whale breach (first session)
- The Old One surfacing (endgame)

**Cinematic / screenshot locations (the "photo spots"):**
1. The Broken Lighthouse at sunset
2. The Whisper Arch framing Sunshall
3. The Dawnbreaker mast in fog
4. The Caldera glow at night
5. The Frozen Sailship under the aurora
6. The Whale Skeleton with bioluminescence through its ribs
7. The Hidden Isle at golden hour
8. The Trench Gate with the keystone glow
9. The Grotto crystals
10. The Great Fig Tree at night

---

# STEP 10 — BUILDING INSTRUCTIONS (for the developer)

## Map hierarchy
```
DataModel
└── Workspace
    ├── Terrain                     (real ground — Studio terrain script)
    ├── Sunshall_Island             (folder: spawn, pier, village, lighthouse, secrets)
    ├── Whisper_Lagoon              (sandbars, arch, ruin, islet)
    ├── TheDrop_Cliffs              (cliff ring, wreck, tower, grotto entrance)
    ├── Ember_Island                (caldera, falls, shrine, hidden passage)
    ├── Frostreach_Field            (floes, frozen ship, ice chapel, hermit cave)
    ├── Abyss_Basin                 (gate, skeleton, pillars, the Lair)
    ├── HiddenIsle                  (isle + cairn)
    ├── SunkenGrotto                (cave room)
    ├── RuinKit_*                   (arches/bells/statues/pillars as reusable models)
    └── ZoneRegion_*                (8 invisible region parts — required by code)
```

## Build order (what first)
1. **Sunshall first, completely** — spawn, pier, village, lighthouse. Everything else can wait; this is the first 2 minutes.
2. **The RuinKit** — build the arch/bell/statue/pillar models once, then scatter them everywhere. 80% of the "storybook" feel comes from this kit.
3. **Zone skeletons** — island shapes + region parts + zone buoy/label. Playable early.
4. **Zone details** — fillers, props, particles, NPCs.
5. **Secrets** — hidden paths, chests, the waterfall passage.
6. **Atmosphere pass** — lighting, fog, sound, weather, day/night grading.
7. **Screenshot pass** — walk the 10 photo spots; if a spot isn't pretty, fix the spot.

## Assets needed (checklist)
- 4 palm poses, 3 pine sizes, 5 coral species, 3 seagrass/kelp variants
- 4 rock sizes × 4 zone tints
- RuinKit: 3 arch states, 3 bells, 2 statues, 4 pillar states, 2 gates
- 4 wreckage pieces (crate, barrel, plank, oar)
- 1 rowboat, 1 whale (breach anim), fish school rig, gull rig, villager rig
- Weather: fog, rain, snow, ash, ember, aurora, bioluminescence particle systems
- 8 named NPC builds (simple rigs + idle/loop anims)

## Details that cannot be skipped
1. **The first 2 minutes** (whale breach, bell tower underwater, lighthouse sweep)
2. **The RuinKit** — without it there's no story
3. **Visible horizons** — every island visible from another
4. **Night = different game** — bioluminescence, aurora, whale song
5. **Sound layering** — waves + gulls + creak in every zone, zone-specific ambient
6. **The golden-hour grade** — warm light, long shadows, bloom, glitter path

## What makes the world feel premium
- **Lighting before everything.** A world with great lighting looks finished; a world with bad lighting looks broken, no matter how many parts.
- **Motion everywhere.** Schools, gulls, particles, NPC loops. Empty = dead.
- **Story in the environment.** The ruins aren't decoration; they're a mystery you assemble.
- **Sound.** Half of "alive" is audio. Every zone needs its own layer.
- **Restraint.** 3 palm poses > 30 random assets. One strong silhouette per sightline.
- **The horizon always promises.** If the player can see something, they will swim toward it.

---

# QUALITY CHECK (self-review)

| Question | Verdict | Action taken |
|---|---|---|
| Would a player enjoy walking around for an hour? | Yes — 6 zones + 2 secrets, each with a distinct mood, loopable hub, and visible destinations | Crescent layout guarantees a new sightline every 30 seconds |
| Does every area feel unique? | Yes — bright/free (Whisper), cold/dread (Drop), awe (Ember), beauty (Frost), dread-beauty (Abyss) | Each zone owns a color, light, sound, and emotion |
| Are there enough discoveries? | Yes — 24 landmarks, 8 hidden paths, 5 chests, 3 bells, 3 map fragments, 2 secret zones | Exploration kit covers guide/story/reward |
| Does the map feel alive? | Yes — 8 named NPCs with loops, ambient life in every zone, weather + day/night | Life rules: 2+ motion sources per view |
| Would players take screenshots? | Yes — 10 named photo spots + the whale + the aurora + the gate | Screenshot pass is a build phase |
| Does it look like a Roblox front-page game? | It can — the plan is: golden-hour grade + RuinKit story + motion + sound. The two risks are terrain quality (Studio terrain script) and lighting tuning (needs 2-3 in-Studio passes) | Both are explicitly in the build guide |

**Honest gap:** the auto-generated world implements a *simplified* version of this vision today (village, dock, landmarks, fish schools, NPC loops, particles). The full vision needs the terrain script + an art pass in Studio — but the plan above is the complete, ordered, no-guesswork path to get there.
