#!/usr/bin/env perl
#
# Outputs some *simple* color histogram values
# based on hue of colors found in the picture
#
# Usage:
#   perl hue_frequencies.pl <some_png_picture>
#
# Example:
#   perl hue_frequencies.pl ferrari.png
#
# $Id: $

use strict;
use Imager::SkinDetector;

my $name = $ARGV[0]
    or die "Usage: $0 <picture_filename>\n";

my $img  = Imager::SkinDetector->new(file => $name)
    or die "Can't load image '$name'.\n";

my @freq = $img->hue_frequencies();

my $n = 0;
for (@freq) {
    printf "Interval n. %d\tValue: %.3f%%\n", ++$n, 100*$_;
}

