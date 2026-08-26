<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\MatchResult;
use App\Services\AntiCheatService;

class MatchController extends Controller
{
    public function store(Request $request, AntiCheatService $antiCheat)
    {
        $data = $request->validate([
            'idempotency_key' => 'required|string',
            'payload' => 'required|array',
            'signature' => 'required|string'
        ]);
        
        $isFlagged = !$antiCheat->validateMatch($data);
        
        // Save match
        $match = MatchResult::firstOrCreate(
            ['idempotency_key' => $data['idempotency_key']],
            [
                'profile_id' => $request->user()->id ?? 1,
                'mode' => $data['payload']['mode'] ?? 'classic',
                'score' => $data['payload']['score'] ?? 0,
                'duration_sec' => $data['payload']['duration_sec'] ?? 0,
                'is_flagged' => $isFlagged
            ]
        );
        
        return response()->json(['success' => true, 'flagged' => $isFlagged]);
    }
}
