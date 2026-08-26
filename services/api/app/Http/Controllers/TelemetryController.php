<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TelemetryController extends Controller
{
    public function store(Request $request)
    {
        $payload = $request->validate([
            'events' => 'required|array',
            'events.*.name' => 'required|string',
            'events.*.params' => 'required|array',
            'events.*.ts' => 'required|numeric'
        ]);
        
        $inserts = array_map(function ($e) {
            return [
                'event_name' => $e['name'],
                'params' => json_encode($e['params']),
                'client_ts' => date('Y-m-d H:i:s', $e['ts']),
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }, $payload['events']);
        
        DB::table('telemetry_events')->insert($inserts);
        
        return response()->json(['success' => true]);
    }
}
