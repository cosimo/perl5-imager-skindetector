#!/usr/bin/env perl
#
# Tries to tell you how much skin color there
# seems to be in the specified image.
# Don't expect miracles, though.
#
# Usage:
#   perl is_skinny.pl <some_png_picture>
#
# Example:
#   perl is_skinny.pl ferrari.png
#
# $Id$

use strict;
use Imager::SkinDetector;

my $name = $ARGV[0]
    or die "Usage: $0 <picture_filename>\n";

my $img  = Imager::SkinDetector->new(file => $name)
    or die "Can't load image '$name'.\n";

my $skin = $img->skinniness();

printf "skinniness: %3.2f%%\n", ($skin * 100);

