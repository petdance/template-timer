#!perl

use strict;
use warnings;

use Test::More tests => 1;

use Template::Timer;

pass( 'Module loaded' );

diag( "Testing Template::Timer $Template::Timer::VERSION" );
