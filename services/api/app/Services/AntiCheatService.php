<?php
namespace App\Services;

class AntiCheatService
{
    public function validateMatch(array $data): bool
    {
        // Check HMAC signature
        $expectedHmac = hash_hmac('sha256', json_encode($data['payload']), config('app.key'));
        if (!hash_equals($expectedHmac, $data['signature'] ?? '')) {
            return false;
        }
        
        $payload = $data['payload'];
        
        // Plausibility checks
        if ($payload['duration_sec'] < 10) return false;
        if ($payload['score'] > ($payload['duration_sec'] * 100)) return false; // Impossible score rate
        
        return true;
    }
}
