package main

import rl "vendor:raylib"

main:: proc() {

    AnimationName :: enum {
        Idle,
        Run
    }

    Animation :: struct {
        texture: rl.Texture2D,
        frame_timer: f32,
        current_frame: int,
        frame_length: f32,
        no_of_frames: int,
        name: AnimationName
    }
    
    Player :: struct {
        position: rl.Vector2,
        size: rl.Vector2,
        color: rl.Color,
    }
    player_velocity: rl.Vector2
    player_grounded: bool
    player_flip: bool
   
    player_run_num_of_frames := 4
    
    player: Player = {
        { 120, 230 },
        { 80, 60 },
        { 10, 255, 0, 255 }
    }

    // -------------------------- Animation Stuff -------------------------------------------

    player_run_frame_timer: f32  // ---> how long the current frame gonna run
    player_run_current_frame: int // ---> in which frame we're currently on
    player_run_frame_length: f32 // ---> contains how long long we want each frame to be displayed before going to next
    
    rl.InitWindow( 1280, 720, "Odin + Raylib" )
    
    player_texture := rl.LoadTexture("cat_run.png")
    idle_texture := rl.LoadTexture("cat_idle.png")
    
    // Animations
    player_run :Animation = {
        no_of_frames = 4,
        texture = player_texture,
        frame_length = 0.1,
        name = .Run
    }
   
    player_idle :Animation = {
        no_of_frames = 2,
        texture = idle_texture,
        frame_length = 0.5,
        name = .Idle
    }

    rl.SetTargetFPS(1000)
    player_animation := player_idle
    for !rl.WindowShouldClose() {
        rl.ClearBackground( {  28, 20, 38, 255} )
        rl.BeginDrawing()

        // Key Controls
        if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
            
            player_velocity.x = 200
            player_flip = false

            if player_animation.name != .Run {
                player_animation = player_run
            }

        } else if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
            
            player_velocity.x = -200
            player_flip = true

            if player_animation.name != .Run {
                player_animation = player_run
            }
            
        } else {
            player_velocity.x = 0

            if player_animation.name != .Idle {
                player_animation = player_idle
            }

        }
        
        player_velocity.y += 2000 * rl.GetFrameTime()
        if player_grounded && rl.IsKeyPressed( .SPACE ) {
            player_velocity.y = -600
            player_grounded = false
        }
        
        player.position += player_velocity * rl.GetFrameTime()

        // boundaries
        if player.position.y > f32(rl.GetScreenHeight()) - player.size.y {
            player.position.y = f32(rl.GetScreenHeight()) - player.size.y
            player_grounded = true
        }

        if player.position.y < 0 {
            player.position.y = 0
        }

        if player.position.x < 0 {
            player.position.x = 0
        }

        if player.position.x > f32(rl.GetScreenWidth()) - player.size.x {
            player.position.x = f32(rl.GetScreenWidth()) - player.size.x
        }

        player_run_width := f32( player_animation.texture.width )
        player_run_height := f32( player_animation.texture.height )

        // Animation Update
        player_animation.frame_timer += rl.GetFrameTime()
        if player_animation.frame_timer > player_animation.frame_length {
            player_animation.current_frame += 1
            player_animation.frame_timer = 0

            if player_animation.current_frame == player_animation.no_of_frames {
                player_animation.current_frame = 0
            }
        }

        // Animation Draw
        draw_player_src := rl.Rectangle {
            x = f32( player_animation.current_frame ) * player_run_width / f32( player_animation.no_of_frames ),
            y = 0,
            width = player_run_width / f32(player_animation.no_of_frames),
            height = player_run_height
        }

        if player_flip {
            draw_player_src.width = -draw_player_src.width
        }

        draw_player_dest := rl.Rectangle {
            x = player.position.x,
            y = player.position.y,
            width = (player_run_width * 4) / f32(player_animation.no_of_frames),
            height = player_run_height * 4
        }

        rl.DrawTexturePro(player_texture, draw_player_src, draw_player_dest, 0, 0, rl.WHITE)
        rl.EndDrawing()
    }


    free_all(context.temp_allocator)

    rl.CloseWindow()
}