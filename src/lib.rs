mod game;

use godot::prelude::*;

struct GDExt;

#[gdextension]
unsafe impl ExtensionLibrary for GDExt {}
