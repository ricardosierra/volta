# Performance Baselines

## Before Optimizations
- **CPU**: AI takes ~2ms/tick. Territory takes ~4ms/tick during large captures.
- **GPU**: VFX Overdraw causes drops to 45fps on mid-range devices.
- **Memory**: RSS grows ~1MB per match due to cached nodes.

## Target
- **CPU**: < 1ms total per tick.
- **GPU**: Stable 60fps across all tiers.
- **Memory**: Flat RSS curve.
