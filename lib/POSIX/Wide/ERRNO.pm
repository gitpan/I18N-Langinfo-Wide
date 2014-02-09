# Copyright 2009, 2010, 2012, 2014 Kevin Ryde

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

package POSIX::Wide::ERRNO;
use 5.008001;  # for utf8::is_utf8()
use strict;
use warnings;
use I18N::Langinfo::Wide;
use Scalar::Util;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 8;

sub TIESCALAR {
  my ($class) = @_;
  my $self;
  return bless \$self, $class;
}

# dualvar() in Scalar::Util 1.22 (post perl 5.10.1) will propagate the
# utf8 flag on its own, for prior versions must turn it on explicitly
#
BEGIN {
  if (do { my $u = 'x';
           utf8::upgrade($u);
           my $e = Scalar::Util::dualvar(0,$u);
           utf8::is_utf8($e) }) {
    ### dualvar() is utf8
    eval "\n#line ".(__LINE__+1)." \"".__FILE__."\"\n" . <<'HERE' or die;
      sub FETCH {
        return Scalar::Util::dualvar
                 ($!, I18N::Langinfo::Wide::to_wide("$!"));
      }
      1;
HERE
  } else {
    ### dualvar() is not utf8, using _utf8_on()
    require Encode;
    eval "\n#line ".(__LINE__+1)." \"".__FILE__."\"\n" . <<'HERE' or die;
      sub FETCH {
        my $e = Scalar::Util::dualvar
                  ($!, I18N::Langinfo::Wide::to_wide("$!"));
        Encode::_utf8_on($e);
        return $e;
      }
      1;
HERE
  }
}

sub STORE {
  my ($self, $value) = @_;
  $! = $value;
}

1;
__END__

=for stopwords POSIX Ryde Langinfo

=head1 NAME

POSIX::Wide::ERRNO -- an internal part of POSIX::Wide

=head1 DESCRIPTION

This is the tie class used to implement the wide C<$ERRNO> variable in
C<POSIX::Wide>.  It's not designed for external use.

=head1 SEE ALSO

L<POSIX>, L<perltie>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/i18n-langinfo-wide/index.html>

=head1 LICENSE

I18N-Langinfo-Wide is Copyright 2009, 2010, 2012, 2014 Kevin Ryde

I18N-Langinfo-Wide is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

I18N-Langinfo-Wide is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
I18N-Langinfo-Wide.  If not, see L<http://www.gnu.org/licenses/>.

=cut
