<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redis;

class LeaderboardController extends Controller
{
    public function show(string $board)
    {
        // Mock returning top 10 from Redis
        $redisKey = "leaderboard:{$board}:weekly";
        $top = Redis::zrevrange($redisKey, 0, 9, 'WITHSCORES');
        
        return response()->json(['board' => $board, 'top' => $top]);
    }
}
