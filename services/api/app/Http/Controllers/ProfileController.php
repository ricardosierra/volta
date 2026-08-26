<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function update(Request $request)
    {
        $request->validate(['nickname' => 'required|string|max:20']);
        
        // Mock sanitization (homoglyphs/blocklist)
        $cleanNickname = preg_replace('/[^a-zA-Z0-9 ]/', '', $request->nickname);
        
        $profile = $request->user();
        if ($profile) {
            $profile->nickname = $cleanNickname;
            $profile->save();
        }
        
        return response()->json(['success' => true, 'nickname' => $cleanNickname]);
    }
}
