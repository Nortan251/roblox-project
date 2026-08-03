#!/usr/bin/env python3
"""Tidebound SFX synthesizer — generates original WAV sound effects.
All sounds are synthesized from scratch (sines, noise, envelopes): 100% legal,
no copyrighted audio. Upload the WAVs in Studio (Creator Dashboard > Audio),
then paste the asset IDs into Config.AUDIO_IDS.
"""
import math, os, random, struct, wave

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")

random.seed(2026)

def write_wav(name, samples):
    path = os.path.join(OUT, name + ".wav")
    os.makedirs(OUT, exist_ok=True)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(v * 32767))
        w.writeframes(bytes(frames))
    print(f"  wrote {name}.wav ({len(samples)/SR:.2f}s)")

def env(n, dur, attack=0.005, release=None, curve=1.0):
    """Amplitude envelope for sample index n over total dur seconds."""
    t = n / SR
    if t < attack:
        return t / attack
    if release is not None and t > dur - release:
        return max(0.0, (dur - t) / release)
    return 1.0

def sine(freq, dur, vol=0.5, attack=0.005, release=0.05, vibrato=0.0):
    out = []
    n_total = int(dur * SR)
    for n in range(n_total):
        f = freq * (1 + vibrato * math.sin(2 * math.pi * 6 * n / SR))
        phase = 2 * math.pi * f * n / SR
        out.append(vol * math.sin(phase) * env(n, dur, attack, release))
    return out

def sweep(f0, f1, dur, vol=0.4, attack=0.005, release=0.05):
    out = []
    n_total = int(dur * SR)
    for n in range(n_total):
        t = n / n_total
        f = f0 + (f1 - f0) * (t ** 1.5)
        phase = 2 * math.pi * f * n / SR
        out.append(vol * math.sin(phase) * env(n, dur, attack, release))
    return out

def noise(dur, vol=0.4, attack=0.005, release=0.1, lowpass=0.5):
    """White noise with a crude one-pole lowpass (0..1 cutoff)."""
    out = []
    lp = 0.0
    n_total = int(dur * SR)
    for n in range(n_total):
        lp += lowpass * (random.uniform(-1, 1) - lp)
        out.append(vol * lp * env(n, dur, attack, release))
    return out

def brown(dur, vol=0.6, attack=0.1, release=0.3):
    """Brown noise (thunder rumble)."""
    out = []
    b = 0.0
    n_total = int(dur * SR)
    for n in range(n_total):
        b = 0.98 * b + 0.02 * random.uniform(-1, 1)
        out.append(vol * b * 3.0 * env(n, dur, attack, release))
    return out

def add(base, overlay, offset_s=0.0):
    """Mix overlay into base at a time offset (samples)."""
    out = list(base)
    off = int(offset_s * SR)
    for i, v in enumerate(overlay):
        idx = i + off
        if idx < len(out):
            out[idx] += v
    return out

def fade_in(samples, seconds=0.01):
    n = int(seconds * SR)
    for i in range(min(n, len(samples))):
        samples[i] *= i / n
    return samples

def normalize(samples, peak=0.9):
    m = max(1e-6, max(abs(s) for s in samples))
    k = peak / m
    return [s * k for s in samples]

# ── Sounds ────────────────────────────────────────────────────────────────
print("Synthesizing Tidebound SFX...")

# ui_click: crisp short blip
write_wav("ui_click", normalize(add(sine(1400, 0.05, 0.5, release=0.03), sine(2100, 0.04, 0.25, release=0.02))))

# ui_error: low double-buzz
write_wav("ui_error", normalize(add(sine(180, 0.12, 0.4, release=0.06), add(sine(160, 0.12, 0.3, release=0.06), sine(120, 0.1, 0.3, release=0.05), 0.02), 0.04)))

# cast_splash: noise burst + watery blip
splash = add(noise(0.45, 0.5, attack=0.002, release=0.25, lowpass=0.35), noise(0.3, 0.25, attack=0.002, release=0.15, lowpass=0.6), 0.02)
splash = add(splash, sweep(500, 900, 0.12, 0.12, release=0.1), 0.03)
write_wav("cast_splash", normalize(fade_in(splash, 0.005)))

# bite: cartoonish bloop (downward pitch)
write_wav("bite", normalize(add(sweep(650, 250, 0.16, 0.5), sine(1200, 0.06, 0.15, release=0.04))))

# reel_tick: tiny click
write_wav("reel_tick", normalize(sine(900, 0.03, 0.35, release=0.02)))

# catch_common: soft pluck
write_wav("catch_common", normalize(add(sine(440, 0.22, 0.4, release=0.18), add(sine(660, 0.2, 0.2, release=0.16), sine(880, 0.16, 0.12, release=0.12)))))

# catch_rare: two-note chime
chime = add(sine(880, 0.3, 0.4, release=0.24), sine(1320, 0.3, 0.25, release=0.24))
chime = add(chime, add(sine(880, 0.3, 0.4, release=0.24), sine(1760, 0.35, 0.3, release=0.28)), 0.11)
chime = add(chime, noise(0.5, 0.08, attack=0.02, release=0.4, lowpass=0.5), 0.1)
write_wav("catch_rare", normalize(chime))

# catch_mythic: arpeggio + shimmer
myth = sine(660, 0.4, 0.35, release=0.32)
myth = add(myth, sine(990, 0.4, 0.3, release=0.32), 0.09)
myth = add(myth, sine(1320, 0.45, 0.3, release=0.36), 0.18)
myth = add(myth, sine(1980, 0.5, 0.28, release=0.4), 0.27)
myth = add(myth, noise(0.8, 0.1, attack=0.1, release=0.6, lowpass=0.4), 0.2)
write_wav("catch_mythic", normalize(myth))

# levelup: rising sweep + chord
lv = sweep(400, 1200, 0.35, 0.35, release=0.2)
lv = add(lv, sine(523, 0.5, 0.25, release=0.4), 0.3)
lv = add(lv, sine(659, 0.5, 0.25, release=0.4), 0.3)
lv = add(lv, sine(784, 0.5, 0.25, release=0.4), 0.3)
write_wav("levelup", normalize(lv))

# coins: double cling
cling = add(sine(2400, 0.12, 0.3, release=0.1), sine(3200, 0.08, 0.15, release=0.06))
write_wav("coins", normalize(add(cling, add(cling, [], 0.0), 0.09)))

# streak: mini fanfare
fan = sine(523, 0.14, 0.35, release=0.1)
fan = add(fan, sine(659, 0.14, 0.35, release=0.1), 0.12)
fan = add(fan, sine(784, 0.14, 0.35, release=0.1), 0.24)
fan = add(fan, sine(1047, 0.3, 0.4, release=0.24), 0.36)
write_wav("streak", normalize(fan))

# storm: thunder rumble with a crack
crack = noise(0.08, 0.7, attack=0.001, release=0.06, lowpass=0.9)
rumble = brown(2.2, 0.55, attack=0.02, release=0.6)
write_wav("storm", normalize(add(rumble, crack, 0.0)))

# achievement: bell
bell = add(sine(1568, 0.5, 0.35, release=0.4), sine(2349, 0.4, 0.15, release=0.32))
bell = add(bell, noise(0.3, 0.05, attack=0.005, release=0.25, lowpass=0.6))
write_wav("achievement", normalize(bell))

# buy: register two-clicks + ding
buy = noise(0.03, 0.4, attack=0.001, release=0.02, lowpass=0.7)
buy = add(buy, noise(0.03, 0.4, attack=0.001, release=0.02, lowpass=0.7), 0.08)
buy = add(buy, sine(1100, 0.18, 0.3, release=0.14), 0.14)
write_wav("buy", normalize(buy))

print("Done. Upload these to Studio (Creator Dashboard > Audio) and set IDs in Config.AUDIO_IDS.")
