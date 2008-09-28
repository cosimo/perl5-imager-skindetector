# $Id$

package Imager::SkinDetector;

use strict;
use Carp q(croak);
use base q(Imager);

our $VERSION = '0.02';

sub new {
    my ($class, %opt) = @_;

    return unless %opt;

    my $file = $opt{file};
    if (! defined $file) {
        return;
    }

    $class = ref($class) || $class;
    my $self = Imager->new();

    if (! $self->open(file=>$file)) {
        croak $self->errstr();
    }

    bless $self, $class;
}

sub minmax {
    local $_;
    my $max = my $min = $_[0];

    for(@_) {
        $max = $_ if $_ > $max;
        $min = $_ if $_ < $min;
    }
    return($min, $max);
}

# Naive rgb-to-hsv conversion. Slooow...
sub rgb2hsv {
    my($r, $g, $b) = @_;

    #$r = 255 if $r > 255;
    #$g = 255 if $g > 255;
    #$b = 255 if $b > 255;

    my($h1, $s1, $v1);
    my($max, $min, $diff);

    ($min, $max) = minmax($r, $g, $b);
    $diff = $max - $min;

    if($max == 0) {
        $h1 = $s1 = $v1 = 0;
    }
    else {
        $v1 = $max;
        $s1 = $diff / $max;
        if($s1 == 0) {
            $h1 = 0;
        }
        else {
            # Foley & VanDam HSV space
            if ($r == $max) {
                $h1 = ($g - $b) / $diff;
            }
            if ($g == $max) {
                $h1 = 2 + ($b - $r) / $diff;
            }
            if ($b == $max) {
                $h1 = 4 + ($r - $g) / $diff;
            }

            # Convert to range [0, 360] degrees
            $h1 *= 60; 
            $h1 += 360 if $h1 < 0;
        }
    }

    return($h1, $s1, $v1);
}

sub is_skin {
    my ($color) = $_[0];
    my ($r, $g, $b, $a) = $color->rgba;
    my ($h, $s, $v) = rgb2hsv($r, $g, $b);

    #print "RGBA(", join(', ', $r, $g, $b, $a), ")\n";
    #print "HSV (", join(', ', $h, $s, $v), "\n";
    #<STDIN>;

    # Hue 5..40 could be a good approximation of "white" skin
    if ($h >= 5 && $h <= 40 && $v > 60) {
        return 1;
    }

    # TODO Detect also black skin
    return 0;
}

sub skinniness {
    my ($img) = @_;

    return unless $img;

    my $width  = $img->getwidth() - 1;
    my $height = $img->getheight() - 1;

    my $skin_colors = 0;
    my $total_samples = 0;
    my $color;

    for (my $x = 0; $x < $width; $x += 10) {
        for (my $y = 0; $y < $height; $y += 10) {
            $color = $img->getpixel(x => $x, y => $y);
            if ($color && is_skin($color)) {
                $skin_colors++;
            }
            $total_samples++;
        }
    }

    if ($total_samples == 0) {
        return
    }

    return $skin_colors / $total_samples;
}

1;

__END__

=head1 NAME

Imager::SkinDetector - The great new Imager::SkinDetector!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Imager::SkinDetector;

    my $name = 'mypic.png';

    my $image = Imager::SkinDetector->new(file => $name)
        or die "Can't load image [$name]\n";

    my $skinniness = $image->skinniness();

    printf "Image is %3.2f%% skinny\n", $skinniness * 100;

=head1 DESCRIPTION

Have you ever needed to know if an image has some amount of
skin tone color? Did you find some tool to do it?
Free software? Yes? If so, please tell me right now!

If not, welcome to Imager-SkinDetector. It uses Imager as
processing engine, so it should have a decent speed.
Don't expect miracles, though.

I'm planning to use this as part of a set of tools
to automatically classify images as nudity or
"containing skin". It's only a plan. I might succeed
one day. Most probably I won't. :-)

Feel free to provide feedback and code.


=head1 FUNCTIONS

=head2 C<is_skin($color)>

Examines an C<Imager::Color> object and tells you if it
seems to be similar to skin color.

The algorithm is as stupid as you can get. No less.
And it only detects "white" skin colors for now. Sorry.

Example:

    my $color = Imager::Color->new(0, 255, 255);
    if (Imager::SkinDetector::is_color($color)) {
        print 'Yes, it seems to be skinny';
    } else {
        print 'Mmhhh, probably not';
    }

=head2 C<rgb2hsv(@rgb)>

Converts an RGB triplet into HSV, returned as a list of values.
C<H> is hue, 0 to 360.
C<S> is saturation, 0 to 1.
C<V> is value, 0 to 255.

Example:

    my @rgb = (255, 0, 0);
    my @hsv = Imager::SkinDetector::rgb2hsv(@rgb);

=head1 METHODS

=head2 C<skinniness()>

Returns a real value from 0 to 1, indicating how much skin
tone color is present in the given picture.
A return value of zero means no skin tone colors.
A return value of one means a picture that contains only skin
colors.

Example:

    # You might not be able to load '.png' pictures,
    # depending on your version of Imager and OS
    my $pic = 'coolpic.png';
    my $img = Imager::SkinDetector->new(file => $pic);
    my $skin = $img->skinniness();

    # $skin = 0.21313   -> 21.3% of skin colors

=head1 AUTHOR

Cosimo Streppone, C<< <cosimo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-imager-skindetector at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Imager-SkinDetector>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Imager::SkinDetector


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Imager-SkinDetector>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Imager-SkinDetector>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Imager-SkinDetector>

=item * Search CPAN

L<http://search.cpan.org/dist/Imager-SkinDetector>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Cosimo Streppone, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

