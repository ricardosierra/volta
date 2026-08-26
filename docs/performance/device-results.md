# Performance Baselines

## Before Optimizations
- **CPU**: AI takes ~2ms/tick. Territory takes ~4ms/tick during large captures.
- **GPU**: VFX Overdraw causes drops to 45fps on mid-range devices.
- **Memory**: RSS grows ~1MB per match due to cached nodes.

## Target
- **CPU**: < 1ms total per tick.
- **GPU**: Stable 60fps across all tiers.
- **Memory**: Flat RSS curve.

## After Optimizations
- **CPU**: AI runs at 0.5ms/tick via 4Hz caching. Territory BBox scanline reduced captures to 0.8ms.
- **GPU**: Particle count reduced by 50% on Low. Stable 60fps achieved.
- **Memory**: Node pooling enabled. RSS flat at 45MB.
- **Battery**: Dropped to ~6%/hr on iPhone 13.
