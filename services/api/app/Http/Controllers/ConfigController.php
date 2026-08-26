<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ConfigController extends Controller
{
    public function index(Request $request)
    {
        $config = [
            'version' => 1,
            'max_xp_per_match' => 500,
            'match_timeout_sec' => 300
        ];
        
        $etag = md5(json_encode($config));
        
        if ($request->header('If-None-Match') === $etag) {
            return response('', 304);
        }
        
        return response()->json($config)->header('ETag', $etag);
    }
}
