<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('profile_id')->constrained()->cascadeOnDelete();
            $table->string('idempotency_key')->unique();
            $table->string('mode');
            $table->integer('score');
            $table->float('duration_sec');
            $table->boolean('is_flagged')->default(false);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index(['profile_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};
