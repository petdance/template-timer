#!perl -Tw

use strict;
use warnings;

use Template::Timer;
use Template::Test;

BEGIN {
    no warnings;

    # Return fake times for consistent output
    use Time::HiRes;
    my $time = 1;
    my $inc  = 1;
    sub Time::HiRes::time { return ($time += $inc++)/1000 };
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

# print $tt->process( \*DATA, $vars );
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

I am an INCLUDEd file.

I am a PROCESSed file.


<!-- SUMMARY
L1      0.000             P input text
L2      2.000              P (evaluated block)
L2      5.000      3.000   P (evaluated block)
L2      9.000              I include.tt
L3     14.000               P include.tt
L3     20.000      6.000    P include.tt
L2     27.000     18.000   I include.tt
L2     35.000              P process.tt
L2     44.000      9.000   P process.tt
L1     54.000     54.000  P input text
-->
