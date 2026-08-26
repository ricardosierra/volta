# Offline-First Validation Report

## Scenario 1: Total Offline (Airplane Mode)
- **Boot**: Instant. Config falls back to local.
- **Progression**: Saved locally. Enqueued for upload.
- **Result**: PASS

## Scenario 2: Server Slow (5s Latency)
- **Boot**: Does not block on Config or Leaderboard.
- **Result**: PASS

## Scenario 3: Server Outage (500 Error)
- **Match Submission**: Retried with exponential backoff via OfflineQueue.
- **Result**: PASS
