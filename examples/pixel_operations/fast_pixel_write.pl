    use strict;
    use warnings;
    use SDL 2.408; 
    use SDLx::App; #this is in the github repo.
    use SDLx::Surface::Matrix;
    use SDL::Event;
    use SDL::Events;

    use SDL::Rect;
    use SDL::Video;

    my $app = SDLx::App->new(
        -title  => 'Application Title',
        -width  => 640,
        -height => 480,
        -depth  => 32
    );

    load_app();

    my $surface = load_surface();
    my $matrix = SDLx::Surface::pixel_array($surface);

    my $event = SDL::Event->new;    # create a new event

    foreach (0...100) {
        SDL::Events::pump_events();

        while ( SDL::Events::poll_event($event) ) {
            my $type = $event->type();    # get event type
            exit if $type == SDL_QUIT;
        }
        
        update();

        SDL::Video::update_rect( $app, 0, 0, $app->w, $app->h );
    }

    sub load_app {

        my $mapped_color =
          SDL::Video::map_RGB( $app->format(), 0, 0, 0 );    # blue

        SDL::Video::fill_rect( $app, SDL::Rect->new( 0, 0, $app->w, $app->h ),
            $mapped_color );
        return $app;
    }

    sub load_surface {

        my $surface =
          SDL::Surface->new( SDL_ANYFORMAT, 100, 100, 32, 0, 0, 0, 0 );
        my $mapped_color =
          SDL::Video::map_RGB( $surface->format(), 0, 0, 0 );    # blue

        SDL::Video::fill_rect( $surface,
            SDL::Rect->new( 0, 0, $surface->w, $surface->h ),
            $mapped_color );
        return $surface;
    }
    
    sub update {
        load_app();
            SDL::Video::blit_surface( $surface, SDL::Rect->new( 0, 0, $surface->w, $surface->h ),
                                      $app, SDL::Rect->new( ($app->w - $surface->w)/2 , ($app->h - $surface->h)/2, $app->w, $app->h ));
           SDL::Video::lock_surface($surface);                           
                                      
            foreach( 0 ... 100 )
            {
                   vec(${$matrix->[$_ - 1 ][ rand($surface->h) -1 ]}, 0, 32) = 0xFF0000FF;
                  
            }
        SDL::Video::unlock_surface($surface);
       
    }
