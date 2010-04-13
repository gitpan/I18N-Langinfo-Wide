# Copyright 2009, 2010 Kevin Ryde

# This file is part of I18N-Langinfo-Wide.
#
# I18N-Langinfo-Wide is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# I18N-Langinfo-Wide is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with I18N-Langinfo-Wide.  If not, see <http://www.gnu.org/licenses/>.

package POSIX::Wide;
use 5.008;
use strict;
use warnings;
use POSIX ();
use Encode;
use I18N::Langinfo::Wide 'to_wide';

our $VERSION = 3;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw(localeconv perror strerror strftime $ERRNO);

# not yet ...
# our %EXPORT_TAGS = (all => \@EXPORT_OK);

use POSIX::Wide::ERRNO;
tie (our $ERRNO, 'POSIX::Wide::ERRNO');


# Possible funcs:
#
#   asctime
#   ctime
#       Believe always ascii day/month, or at least that's what glibc gives.
#
# Not sure:
#   tzname - always ascii?
#
# Different:
#   strcoll
#   strxfrm

our @_localeconv_string_fields = (qw(decimal_point
                                     thousands_sep
                                     int_curr_symbol
                                     currency_symbol
                                     mon_decimal_point
                                     mon_thousands_sep
                                     positive_sign
                                     negative_sign));

# POSIX.xs of perl 5.10.1 has mon_thousands_sep conditionalized, so allow
# for it and maybe other fields to not exist
#
sub localeconv {
  my $l = POSIX::localeconv();
  foreach my $key (@_localeconv_string_fields) {
    if (exists $l->{$key}) {
      $l->{$key} = to_wide($l->{$key});
    }
  }
  return $l;
}

# STDERR like POSIX/perror.al
sub perror {
  if (@_) { print STDERR @_,': '; }
  print STDERR strerror($!),"\n";
}

sub strerror {
  return to_wide (POSIX::strerror ($_[0]));
}

# \020-\176 is printable ascii
# only basic control chars are allows through to strftime, in particular Esc
# is excluded in case the locale is shift-jis etc and it means something
sub strftime {
  (my $fmt = shift) =~ s{(%[\020-\176\t\n\r\f\a]*)}
                        { to_wide(POSIX::strftime($1,@_)) }ge;
  return $fmt;
}


1;
__END__

=head1 NAME

POSIX::Wide -- POSIX functions returning wide-char strings

=head1 SYNOPSIS

 use POSIX::Wide;
 print POSIX::Wide::strerror(2),"\n";
 print POSIX::Wide::strftime("%a %d-%b\n",localtime());

=head1 DESCRIPTION

This is a few of the C<POSIX> module functions adapted to return Perl
wide-char strings instead of their usual locale charset byte strings.

=head1 EXPORTS

Nothing is exported by default, but each of the functions and the C<$ERRNO>
variable can be imported in the usual C<Exporter> way.  Eg.

    use POSIX::Wide 'strftime', '$ERRNO';

There's no C<:all> tag yet, as not sure if it would better import just the
new funcs, or get everything from C<POSIX>.

=head1 FUNCTIONS

=over 4

=item C<$str = POSIX::Wide::localeconv ($format, ...)>

Return a hashref of locale information

    { decimal_point => ...,
      grouping      => ...
    }

String field values are wide chars.  Non-string fields like C<grouping> or
number fields like C<frac_digits> are unchanged.

=item C<$str = POSIX::Wide::perror ($message)>

Print C<$message> and errno C<$!> to C<STDERR>, with wide-chars for the
errno string.

    $message: $!\n

=item C<$str = POSIX::Wide::strerror ($errno)>

Return a descriptive string for a given C<$errno> number.

=item C<$str = POSIX::Wide::strftime ($format, $sec, $min, $hour, $mday, $mon, $year, ...)>

Format a string of date-time parts.  C<$format> and the return are wide-char
strings.

The current implementation passes ASCII parts of C<$format>, including the
"%" formatting directives, to strftime().  This means C<$format> can include
characters which might not exist in the locale charset.

=item C<$num = $POSIX::Wide::ERRNO + 0>

=item C<$str = "$POSIX::Wide::ERRNO">

A magic dual-value variable similar to C<$!>, giving the C library C<errno>
as a number or string.  The string is wide-chars.

=back

=head1 SEE ALSO

L<POSIX>

L<Glib::Utils>, for a similar C<strerror>.

=head1 HOME PAGE

L<http://user42.tuxfamily.org/i18n-langinfo-wide/index.html>

=head1 LICENSE

I18N-Langinfo-Wide is Copyright 2008, 2009, 2010 Kevin Ryde

I18N-Langinfo-Wide is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

I18N-Langinfo-Wide is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
I18N-Langinfo-Wide.  If not, see <http://www.gnu.org/licenses/>.

=cut
