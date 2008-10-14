#!/usr/bin/env perl
#
# Tries to tell you if the picture could
# contain nudity. It's a rough attempt.
# Don't expect miracles.
#
# Usage:
#   perl contains_nudity.pl <some_png_picture>
#
# Example:
#   perl contains_nudity.pl ferrari.png
#
# $Id: is_skinny.pl 117 2008-10-11 12:09:21Z Cosimo $

use strict;
use Imager::SkinDetector;

my $name = $ARGV[0]
    or die "Usage: $0 <picture_filename>\n";

my $img  = Imager::SkinDetector->new(file => $name)
    or die "Can't load image '$name'.\n";

my $prob = $img->contains_nudity();

printf "Contains nudity: %3.2f%%\n", ($prob * 100);

