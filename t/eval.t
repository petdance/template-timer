#!perl -Tw

use strict;
use warnings;

use Template::Timer;
use Template::Test;

BEGIN {
    no warnings;

    # Return fake times for consistent output
    use Time::HiRes;
    my $interval = 0; # Make the tv_interval return different numbers each time
    sub Time::HiRes::gettimeofday { return 0.000; }
    sub Time::HiRes::tv_interval  { return $interval += 0.250; }
}

$Template::Test::DEBUG = 1;

my $tt = Template->new({
        CONTEXT => Template::Timer->new,
    });

my $vars = {
    place    => 'hat',
    fragment => "The cat sat on the [% place %]\n",
};


test_expect(\*DATA, $tt, $vars);

__DATA__
-- test --
[% fragment | eval -%]
-- expect --
The cat sat on the hat

<!-- SUMMARY
L1 250.000          P input text
L2 500.000           P (evaluated block)
L2 750.000 1000.000   P (evaluated block)
L1 1250.000 1500.000  P input text
-->
