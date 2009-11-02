#!/usr/bin/perl -w
use strict;
use SDL;
use SDL::Color;
use SDL::Surface;
use SDL::Config;
use Devel::Peek;
use Data::Dumper;
use Test::More;
use SDL::Rect;

plan ( tests => 41);

use_ok( 'SDL::Video' ); 

my @done =
	qw/ 
	get_video_surface
	get_video_info
	video_driver_name
	list_modes
	set_video_mode
	video_mode_ok
	update_rect
	update_rects
	flip
	set_colors
	set_palette
	set_gamma
	set_gamma_ramp
	map_RGB
	map_RGBA
	unlock_surface
	lock_surface	
	convert_surface
	display_format
	display_format_alpha
	set_color_key
	set_alpha
	get_RGB
	get_RGBA
	load_BMP
	save_BMP
	fill_rect
	blit_surface
	set_clip_rect
	get_clip_rect
	/;

can_ok ('SDL::Video', @done); 

#testing get_video_surface
SDL::init(SDL_INIT_VIDEO);                                                                          
                                                                                                    
my $display = SDL::Video::set_video_mode(640,480,32, SDL_SWSURFACE );

if(!$display){
	 plan skip_all => 'Couldn\'t set video mode: '. SDL::get_error();
    }

#diag('Testing SDL::Video');

isa_ok(SDL::Video::get_video_surface(), 'SDL::Surface', '[get_video_surface] Checking if we get a surface ref back'); 

isa_ok(SDL::Video::get_video_info(), 'SDL::VideoInfo', '[get_video_info] Checking if we get videoinfo ref back');

my $driver_name = SDL::Video::video_driver_name();

pass '[video_driver_name] This is your driver name: '.$driver_name;



is( ref( SDL::Video::list_modes( $display->format , SDL_SWSURFACE )), 'ARRAY', '[list_modes] Returned an ARRAY! ');

cmp_ok(SDL::Video::video_mode_ok( 100, 100, 16, SDL_SWSURFACE), '>=', 0, "[video_mode_ok] Checking if an integer was return");

isa_ok(SDL::Video::set_video_mode( 100, 100 ,16, SDL_SWSURFACE), 'SDL::Surface', '[set_video_more] Checking if we get a surface ref back'); 


#TODO: Write to surface and check inf pixel in that area got updated.

SDL::Video::update_rect($display, 0, 0, 0, 0);

#TODO: Write to surface and check inf pixel in that area got updated.
SDL::Video::update_rects($display, SDL::Rect->new(0, 10, 20, 20));

my $value = SDL::Video::flip($display);
is( ($value == 0)  ||  ($value == -1), 1,  '[flip] returns 0 or -1'  );

$value = SDL::Video::set_colors($display, 0, SDL::Color->new(0,0,0));
is(  $value , 0,  '[set_colors] returns 0 trying to write to 32 bit display'  );

$value = SDL::Video::set_palette($display, SDL_LOGPAL|SDL_PHYSPAL, 0);

is(  $value , 0,  '[set_palette] returns 0 trying to write to 32 bit surface'  );

my $zero = [0,0,0,0]; 
SDL::Video::set_gamma_ramp($zero, $zero, $zero);  pass '[set_gamma_ramp] ran';

SDL::Video::set_gamma( 1.0, 1.0, 1.0 ); pass '[set_gamma] ran ';

my @b_w_colors;

for(my $i=0;$i<256;$i++){
	$b_w_colors[$i] = SDL::Color->new($i,$i,$i);
      }
my $hwdisplay = SDL::Video::set_video_mode(640,480,8, SDL_HWSURFACE );

if(!$hwdisplay){
	 plan skip_all => 'Couldn\'t set video mode: '. SDL::get_error();
    }

$value = SDL::Video::set_colors($hwdisplay, 0);
is(  $value , 0,  '[set_colors] returns 0 trying to send empty colors to 8 bit surface'  );

$value = SDL::Video::set_palette($hwdisplay, SDL_LOGPAL|SDL_PHYSPAL, 0);

is(  $value , 0,  '[set_palette] returns 0 trying to send empty colors to 8 bit surface'  );


$value = SDL::Video::set_colors($hwdisplay, 0, @b_w_colors);
is( $value , 1,  '[set_colors] returns '.$value  );

$value = SDL::Video::set_palette($hwdisplay, SDL_LOGPAL|SDL_PHYSPAL, 0, @b_w_colors );

is(  $value , 1,  '[set_palette] returns 1'  );

$value = SDL::Video::lock_surface($hwdisplay); pass '[lock_surface] ran returned: '.$value;

SDL::Video::unlock_surface($hwdisplay); pass '[unlock_surface] ran';

is( SDL::Video::map_RGB($hwdisplay->format, 10, 10 ,10) > 0, 1, '[map_RGB] maps correctly to 8-bit surface');
is( SDL::Video::map_RGBA($hwdisplay->format, 10, 10 ,10, 10) > 0, 1, '[map_RGBA] maps correctly to 8-bit surface');

isa_ok(SDL::Video::convert_surface( $display , $hwdisplay->format, SDL_SRCALPHA), 'SDL::Surface', '[convert_surface] Checking if we get a surface ref back'); 

isa_ok(SDL::Video::display_format( $display ), 'SDL::Surface', '[display_format] Returns a SDL::Surface');
isa_ok(SDL::Video::display_format_alpha( $display ), 'SDL::Surface', '[display_format_alpha] Returns a SDL::Surface');

is(  SDL::Video::set_color_key($display, SDL_SRCCOLORKEY, SDL::Color->new( 0, 10, 0 ) ),
   0,  '[set_color_key] Returns 0 on success' 
   ) ;

is(  SDL::Video::set_alpha($display, SDL_SRCALPHA, 100 ),
   0,  '[set_alpha] Returns 0 on success' 
   ) ;

is_deeply(SDL::Video::get_RGB($display->format, 0), [0,0,0], '[get_RGB] returns r,g,b');

is_deeply(SDL::Video::get_RGBA($display->format, 0), [0,0,0,255], '[get_RGBA] returns r,g,b,a');

my $bmp = 't/core_video.bmp';
unlink($bmp) if -f $bmp;
SDL::Video::save_BMP($display, $bmp);
ok(-f $bmp, '[save_BMP] creates a file');
my $bmp_surface = SDL::Video::load_BMP($bmp);
isa_ok($bmp_surface, 'SDL::Surface', '[load_BMP] returns an SDL::Surface');
unlink($bmp) if -f $bmp;

my $pixel = SDL::Video::map_RGB( $display->format, 255, 127, 0 );
SDL::Video::fill_rect( $display, SDL::Rect->new( 0, 0, 32, 32 ), $pixel );
ok( 1, '[fill_rect] filled rect' );

my $clip_rect = SDL::Rect->new(0, 0, 10, 20);
SDL::Video::get_clip_rect($display, $clip_rect);
is($clip_rect->x, 0, '[get_clip_rect] returns a rect with x 0');
is($clip_rect->y, 0, '[get_clip_rect] returns a rect with y 0');
is($clip_rect->w, 640, '[get_clip_rect] returns a rect with w 640');
is($clip_rect->h, 480, '[get_clip_rect] returns a rect with h 480');
SDL::Video::set_clip_rect($display, SDL::Rect->new(10, 20, 100, 200));
SDL::Video::get_clip_rect($display, $clip_rect);
is($clip_rect->x, 10, '[get_clip_rect] returns a rect with x 10');
is($clip_rect->y, 20, '[get_clip_rect] returns a rect with y 20');
is($clip_rect->w, 100, '[get_clip_rect] returns a rect with w 100');
is($clip_rect->h, 200, '[get_clip_rect] returns a rect with h 200');

my @left = qw/
	get_gamma_ramp
	GL_load_library
	GL_get_proc_address
	GL_get_attribute
	GL_set_attribute
	GL_swap_buffers
	GL_attr
	lock_YUV_overlay
	unlock_YUV_overlay
	display_YUV_overlay
	/;

my $why = '[Percentage Completion] '.int( 100 * $#done / ($#done + $#left) ) ."\% implementation. $#done / ".($#done+$#left); 

TODO:
{
	local $TODO = $why;
	pass "\nThe following functions:\n".join ",", @left; 
}
	diag  $why;


pass 'Are we still alive? Checking for segfaults';
