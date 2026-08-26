# API Deployment Runbook

## Requirements
- PHP 8.3
- PostgreSQL 16
- Redis 7

## Steps
1. Clone repository
2. `cd services/api`
3. `composer install --no-dev`
4. Copy `.env.example` to `.env` and configure DB/Redis credentials
5. Run `php artisan migrate --force`
6. Run `php artisan config:cache` and `route:cache`
7. Ensure Supervisor is running the queue workers:
   `php artisan queue:work --queue=default,matches --sleep=3 --tries=3`

## Backups
PostgreSQL must be backed up daily via `pg_dump`. Test restoration monthly.
