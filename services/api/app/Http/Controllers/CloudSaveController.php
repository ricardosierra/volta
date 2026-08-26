<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class CloudSaveController extends Controller
{
    public function update(Request $request)
    {
        $payload = $request->validate([
            'version' => 'required|integer',
            'state' => 'required|array'
        ]);
        
        // Monotonic reconciliation
        // In real app, we check if $payload['state']['xp'] > $db['xp'], etc.
        
        return response()->json(['success' => true, 'updated_at' => now()]);
    }
}
