<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\MatchController;
use App\Http\Controllers\LeaderboardController;
use App\Http\Controllers\CloudSaveController;
use App\Http\Controllers\ChallengeController;
use App\Http\Controllers\ConfigController;

// Public/Auth
Route::post('/auth/device', [AuthController::class, 'device'])->middleware('throttle:10,1');
Route::get('/config', [ConfigController::class, 'index']);

// Protected (Mock middleware for now)
Route::middleware('throttle:60,1')->group(function () {
    Route::patch('/profile', [ProfileController::class, 'update']);
    
    Route::post('/matches', [MatchController::class, 'store']);
    
    Route::get('/leaderboards/{board}', [LeaderboardController::class, 'show']);
    
    Route::put('/save', [CloudSaveController::class, 'update']);
    
    Route::get('/challenges/daily', [ChallengeController::class, 'daily']);
    Route::post('/challenges/{id}/claim', [ChallengeController::class, 'claim']);
});
