<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Todo; 

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::get('/todos', function () {
    return Todo::all();
});

Route::post('/todos', function (Request $request) {
    $request->validate([
        'title' => 'required|string|max:255',
    ]);

    $todo = Todo::create([
        'title' => $request->title,
        'is_done' => false,
    ]);

    return $todo;
});

Route::put('/todos/{id}', function (Request $request, $id) {
    $todo = Todo::findOrFail($id);

    $request->validate([
        'is_done' => 'required|boolean',
    ]);

    $todo->update([
        'is_done' => $request->is_done,
    ]);

    return $todo;
});

Route::delete('/todos/{id}', function ($id) {
    $todo = Todo::findOrFail($id);
    $todo->delete();

    return response()->json(['message' => 'Todo deleted successfully']);
});
