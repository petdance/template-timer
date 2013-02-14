package Template::Timer;

use warnings;
use strict;

=head1 NAME

Template::Timer - Rudimentary profiling for Template Toolkit

=head1 VERSION

Version 1.01_01

=cut

our $VERSION = '1.01_01';

=head1 SYNOPSIS

Template::Timer provides inline timings of the template processing
througout your code.  It's an overridden version of L<Template::Context>
that wraps the C<process()> and C<include()> methods.

Using Template::Timer is simple.

    use Template::Timer;

    my %config = ( # Whatever your config is
        INCLUDE_PATH    => '/my/template/path',
        COMPILE_EXT     => '.ttc',
        COMPILE_DIR     => '/tmp/tt',
    );

    if ( $development_mode ) {
        $config{ CONTEXT } = Template::Timer->new( %config );
    }

    my $template = Template->new( \%config );

Now when you process templates, HTML comments will get embedded in your
output, which you can easily grep for.  The nesting level is also shown.

    <!-- SUMMARY
    L1      0.014             P page/search/display.ttml
    L2    251.423              I element/framework/page-end.tt
    L3    251.434               P element/framework/page-end.tt
    L4    254.103                I element/framework/epilogue.tt
    L5    254.114                 P element/framework/epilogue.tt
    L4    251.748                I element/framework/footer.tt
    L5    251.759                 P element/framework/footer.tt

    ....

    L5    253.661      1.913      P element/framework/footer.tt
    L4    253.880      2.144     I element/framework/footer.tt
    L5    254.400      0.297      P element/framework/epilogue.tt
    L4    254.651      0.560     I element/framework/epilogue.tt
    L3    254.953      3.530    P element/framework/page-end.tt
    L2    255.167      3.755   I element/framework/page-end.tt
    L1    281.857    281.871  P page/search/display.ttml
    -->

Note that since INCLUDE is a wrapper around PROCESS, calls to INCLUDEs
will be doubled up, and slightly longer than the PROCESS call.

=cut

use base qw( Template::Context );
use Time::HiRes ();

our $depth = 0;
our $epoch = undef;
our @totals;

foreach my $sub ( qw( process include ) ) {
    no strict 'refs';
    my $super = __PACKAGE__->can($sub) or die;
    *{$sub} = sub {
        my $self = shift;
        my $what = shift;

        my $template
            = ref($what) eq 'Template::Document' ? $what->name
            : ref($what) eq 'ARRAY'              ? join( ' + ', @{$what} )
            : ref($what) eq 'SCALAR'             ? '(evaluated block)'
            :                                      $what
            ;

        my $level;
        my $processed_data;
        my $epoch_elapsed_start;
        my $epoch_elapsed_end;
        my $now   = [Time::HiRes::gettimeofday];
        my $start = [@{$now}];
        DOIT: {
            local $epoch = $epoch ? $epoch : [@{$now}];
            local $depth = $depth + 1;
            $level = $depth;
            $epoch_elapsed_start = _diff_disp($epoch);
            $processed_data = $super->($self, $what, @_);
            $epoch_elapsed_end = _diff_disp($epoch);
        }
        my $spacing = ' ' x $level;
        my $level_elapsed = _diff_disp($start);
        my $ip = uc substr( $sub, 0, 1 );
        my $start_stats = "L$level $epoch_elapsed_start            $spacing$ip $template";
        my $end_stats =   "L$level $epoch_elapsed_end $level_elapsed $spacing$ip $template";
        @totals = ( $start_stats, @totals, $end_stats );
        if ( $level > 1 ) {
            return $processed_data;
        }

        my $summary = join( "\n",
            '<!-- SUMMARY',
            @totals,
            '-->',
            '',
        );
        @totals = ();
        return "$processed_data\n$summary\n";
    }; # sub
} # for


sub _diff_disp {
    my $starting_point = shift;

    return sprintf( '%10.3f', Time::HiRes::tv_interval($starting_point) * 1000 );
}


=head1 AUTHOR

Andy Lester, C<< <andy at petdance.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-template-timer at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Thanks to
Randal Schwartz,
Bill Moseley,
and to Gavin Estey for the original code.

=head1 COPYRIGHT & LICENSE

Copyright 2005-2013 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

See http://www.perlfoundation.org/artistic_license_2_0 or the LICENSE.md
file that comes with the ack distribution.

=cut

1; # End of Template::Timer
