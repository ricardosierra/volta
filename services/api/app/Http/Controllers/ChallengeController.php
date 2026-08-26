<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    public function daily()
    {
        return response()->json([
            'challenges' => [
                ['id' => 1, 'desc' => 'Win 3 Classic Matches'],
                ['id' => 2, 'desc' => 'Capture 500 cells']
            ]
        ]);
    }
    
    public function claim(Request $request, int $id)
    {
        // Idempotency check and reward allocation
        return response()->json(['success' => true, 'reward' => 100]);
    }
}
