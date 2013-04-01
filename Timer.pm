package Template::Timer;

use warnings;
use strict;

=head1 NAME

Template::Timer - Rudimentary profiling for Template Toolkit

=head1 VERSION

Version 1.01_02

=cut

our $VERSION = '1.01_02';

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
    L1      0.000             P page/search/display.ttml
    L2      0.189              I element/framework/page-start.tt
    L3      0.206               P element/framework/page-start.tt
    L4      0.571                I element/framework/preface.tt
    L5      0.585                 P element/framework/preface.tt
    L5      2.318      1.733      P element/framework/preface.tt
    L4      2.332      1.761     I element/framework/preface.tt
    L4      2.348                I element/framework/header.tt

    L4    378.117      0.439     I element/framework/content/line-item/paging.tt
    L3    379.055    221.078    P element/framework/content/line-items.tt
    L2    379.099    221.131   I element/framework/content/line-items.tt
    L2    379.310              I element/atom/inplace-edit-mynotes.tt
    L3    379.321               P element/atom/inplace-edit-mynotes.tt
    L3    381.038      1.717    P element/atom/inplace-edit-mynotes.tt
    L2    381.050      1.740   I element/atom/inplace-edit-mynotes.tt
    L2    381.061              I element/framework/page-end.tt
    L3    381.068               P element/framework/page-end.tt
    L4    381.350                I element/framework/footer.tt
    L5    381.361                 P element/framework/footer.tt
    L5    382.988      1.627      P element/framework/footer.tt
    L4    383.001      1.651     I element/framework/footer.tt
    L4    383.015                I element/framework/epilogue.tt
    L5    383.022                 P element/framework/epilogue.tt
    L5    383.320      0.298      P element/framework/epilogue.tt
    L4    383.331      0.316     I element/framework/epilogue.tt
    L3    383.369      2.301    P element/framework/page-end.tt
    L2    383.377      2.316   I element/framework/page-end.tt
    L1    387.852    387.852  P page/search/display.ttml
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
    my $ip = uc substr( $sub, 0, 1 ); # Include or Process?

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

        local $depth = $depth + 1;
        my $spacing = ' ' x $depth;

        my $start = Time::HiRes::time();
        local $epoch = $epoch ? $epoch : $start;
        my $epoch_elapsed_start = _diff_disp($epoch, $start);
        my $start_stats = "L$depth $epoch_elapsed_start            $spacing$ip $template";
        push @totals, $start_stats;

        my $processed_data = $super->($self, $what, @_);

        my $end               = Time::HiRes::time();
        my $epoch_elapsed_end = _diff_disp($epoch, $end);
        my $level_elapsed     = _diff_disp($start, $end);
        my $end_stats         = "L$depth $epoch_elapsed_end $level_elapsed $spacing$ip $template";
        push @totals, $end_stats;

        if ( $depth > 1 ) {
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
    my $ending_point   = shift;

    return sprintf( '%10.3f', ($ending_point - $starting_point) * 1000 );
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
