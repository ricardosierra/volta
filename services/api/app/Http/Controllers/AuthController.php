<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Profile;

class AuthController extends Controller
{
    public function device(Request $request)
    {
        $request->validate(['device_id' => 'required|string']);
        
        $hash = hash('sha256', $request->device_id . config('app.key'));
        
        $profile = Profile::firstOrCreate(
            ['device_id_hash' => $hash],
            ['nickname' => 'Player' . rand(1000, 9999)]
        );
        
        // Mocking token creation since Sanctum isn't actually installed here
        $token = 'mock_token_' . $profile->id;
        
        return response()->json([
            'token' => $token,
            'profile' => $profile
        ]);
    }
}
