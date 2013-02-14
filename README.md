# Template::Timer

Template::Timer provides inline timings of the time Template Toolkit
spends in template processing througout your code.  It's an overridden
version of Template::Context that wraps the process() and include()
methods.

Using Template::Timer is simple.

    my %config = ( # Whatever your config is
        INCLUDE_PATH    => "/my/template/path",
        COMPILE_EXT     => ".ttc",
        COMPILE_DIR     => "/tmp/tt",
    );

    if ( $development_mode ) {
        $config{ CONTEXT } = Template::Timer->new( %config );
    }

    my $template = Template->new( \%config );

Now when you process templates, HTML comments will get embedded in your
output, which you can easily grep for.

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

# INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install


# COPYRIGHT AND LICENSE

Copyright 2005-2013 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

See http://www.perlfoundation.org/artistic_license_2_0 or the LICENSE.md
file that comes with the ack distribution.
