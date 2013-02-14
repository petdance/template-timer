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
    sub Time::HiRes::tv_interval  { return $interval += 0.001; }
}

$Template::Test::DEBUG = 1;

my $tt = Template->new({
        CONTEXT => Template::Timer->new({
                INCLUDE_PATH => 't/',
            }),
    });

my $vars = {
    place    => 'hat',
    fragment => "The cat sat on the [% place %]\n",
    numbers  => [ 2112, 5150, 90125 ],
};


test_expect(\*DATA, $tt, $vars);

__DATA__
-- test --
[% fragment | eval -%]
[% FOR n IN numbers %]
    n = [% n -%]
[% END %]

[% INCLUDE include.tt %]
[% PROCESS process.tt %]
-- expect --
The cat sat on the hat

    n = 2112
    n = 5150
    n = 90125

I am in INCLUDEd file.

I am a PROCESSed file.


<!-- SUMMARY
L1      1.000             P input text
L2     11.000              P process.tt
L2      5.000              I include.tt
L3      6.000               P include.tt
L2      2.000              P (evaluated block)
L2      3.000      4.000   P (evaluated block)
L3      7.000      8.000    P include.tt
L2      9.000     10.000   I include.tt
L2     12.000     13.000   P process.tt
L1     14.000     15.000  P input text
-->
