#!perl -Tw

use strict;
use warnings;

use Template::Timer;
use Template::Test;

BEGIN {
    no warnings;

    # Return fake times for consistent output
    use Time::HiRes;
    sub Time::HiRes::gettimeofday { return 0.000; };
    sub Time::HiRes::tv_interval  { return 0.000; };
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
L1   0.000          P input text
L2   0.000           P (evaluated block)
L2   0.000   0.000   P (evaluated block)
L1   0.000   0.000  P input text
-->
