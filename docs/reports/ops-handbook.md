# Live Operations Handbook

## Content Cadence
- **Minor Patch**: Every 2 weeks (Balance tweaks, bug fixes).
- **Season Update**: Every 8 weeks (New Arena, New Cosmetic Track).

## Support SLA
- Critical bugs (Crash): Acknowledged in 4h, patched in 24h.
- Escalations: Addressed via community channels (Discord/Twitter).

## Incident Protocol
1. Page on-call engineer.
2. If API is down, fail gracefully to offline mode with `OfflineQueue`.
3. Post-mortem in `docs/backend/incidents/`.
