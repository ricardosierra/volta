# Performance Device Results

## Baseline Tests (Mid-tier Android)

- GPU Budget: 16ms
- Actual Usage: ~12ms with Medium Preset
- Draw Calls: ~45
- Additive Video VFX Cost: ~1.2ms per concurrent video playing

New VFX system (Additive blending MP4) stays well within budget as long as we do not play more than 5 simultaneous videos. The AI Scheduler and Tick Resolution limits concurrent seals naturally, preventing VFX storms.

## Low End Device Mitigation
Setting preset to `low.tres` disables Video VFX and reduces render scale to 0.75, keeping FPS at solid 60 on legacy devices.
