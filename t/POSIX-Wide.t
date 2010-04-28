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

use 5.008;
use strict;
use warnings;
use Test::More tests => 44;

BEGIN {
 SKIP: { eval 'use Test::NoWarnings; 1'
           or skip 'Test::NoWarnings not available', 1; }
}

require POSIX::Wide;

my $want_version = 4;
is ($POSIX::Wide::VERSION, $want_version, 'VERSION variable');
is (POSIX::Wide->VERSION,  $want_version, 'VERSION class method');
{ ok (eval { POSIX::Wide->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { POSIX::Wide->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

is ($POSIX::Wide::ERRNO::VERSION, $want_version, 'VERSION variable');
is (POSIX::Wide::ERRNO->VERSION,  $want_version, 'VERSION class method');
{ ok (eval { POSIX::Wide::ERRNO->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { POSIX::Wide::ERRNO->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

sub my_printable_string {
  my ($str) = @_;
  $str =~ s{([^[:ascii:]]|[^[:print:]])}
           { sprintf('\x{%X}',ord($1)) }eg;
  return $str;
}

#------------------------------------------------------------------------------
# localeconv()

my %localeconv_is_string = (decimal_point     => 1,
                            currency_symbol   => 1,
                            int_curr_symbol   => 1,
                            mon_decimal_point => 1,
                            mon_thousands_sep => 1,
                            negative_sign     => 1);
my %localeconv_is_binary = (frac_digits     => 1, # number
                            int_frac_digits => 1, # number
                            mon_grouping    => 1, # numbers
                            n_cs_precedes   => 1, # boolean
                            n_sep_by_space  => 1, # boolean
                            n_sign_posn     => 1, # enum
                            p_cs_precedes   => 1, # boolean
                            p_sep_by_space  => 1, # boolean
                            p_sign_posn     => 1, # enum
                           );

{
  my $good = 1;
  my $l = POSIX::Wide::localeconv();
  my @keys = sort keys %$l;
  diag "keys: ", join(' ',@keys);
  cmp_ok (@keys, '!=', 0, 'keys found');

  foreach my $key (@keys) {
    my $value = $l->{$key};

    if (! $localeconv_is_string{$key}
        && ! $localeconv_is_binary{$key}) {
      diag "oops, key $key unrecognised (will assume binary)"
    }

    if ($localeconv_is_string{$key}) {
      # string

      if (! utf8::is_utf8 ($value)) {
        diag "$key not utf8::is_utf8";
        $good = 0;
      }
      if (defined &utf8::valid && ! utf8::valid ($value)) {
        diag "$key not utf8::valid";
        $good = 0;
      }

    } else {
      # binary

      if (utf8::is_utf8 ($value)) {
        diag "$key is utf8::is_utf8";
        $good = 0;
      }
    }
  }
  ok ($good, (scalar @keys) . ' values');
}

#------------------------------------------------------------------------------
# strerror()

{
  my $errno = POSIX::EBADF();
  my $str = POSIX::Wide::strerror ($errno);
  ok (utf8::is_utf8($str), "strerror($errno) is_utf8");
 SKIP: {
    (defined &utf8::valid)
      or skip 'utf8::valid not available', 1;
    ok (utf8::valid($str), "strerror($errno) utf8::valid");
  }
}

#------------------------------------------------------------------------------
# strftime()

# { my $t = POSIX::mktime (1,2,3,4,5,90,0,0,0);
#   local $, = ' '; print localtime($t),"\n";
#   print POSIX::ctime($t),"\n"; }

{
  my @date = (1,2,3,  # s,m,h
              4,5,90, # mday,mon,year  4 Jun 1990
              1,154,  # wday, yday localtime
              0);     # isdst

  # is this a bit bogus ?
  sub wide_chars_valid {
    my ($str) = @_;
    # Crib: FB_CROAK mangles the input $str with the bad part encountered,
    # including setting it to '' if all good
    if (eval { Encode::encode('UTF-8', $str, Encode::FB_CROAK()); 1 }) {
      return 1;
    } else {
      diag "Encode::encode error: ", $@;
      return 0;
    }
  }

  foreach my $elem (['',          ''],
                    ['foo',       'foo'],
                    ['foo %H',    'foo 03'],
                    ['%Hfoo',     '03foo'],
                    ['%H%Mfoo',   '0302foo'],
                    ['a%H%Mfoo',  'a0302foo'],
                    ['a%Hb%Mfoo', 'a03b02foo'],
                    ['a%Hb%M',    'a03b02'],

                    ["\x{263a}%H",   "\x{263a}03"],
                    ["%H\x{263a}",   "03\x{263a}"],
                    ["%H\x{263a}%M", "03\x{263a}02"],

                    ["\x{20AC}%H\x{263a}%M",    "\x{20AC}03\x{263a}02"],
                    ["%H\x{263a}%M\x{20AC}",    "03\x{263a}02\x{20AC}"],
                    ["%H%Ma\x{263a}%M\x{20AC}", "0302a\x{263a}02\x{20AC}"],
                   ) {
    my ($format, $want) = @$elem;
    my $got = POSIX::Wide::strftime($format, @date);
    is ($got, $want, "format: ".my_printable_string($format));
    ok (wide_chars_valid($got),
        "check wide chars from format: ".my_printable_string($format));
  }
}

#------------------------------------------------------------------------------
# $ERRNO

{
  $! = POSIX::EBADF();
  my $num = $POSIX::Wide::ERRNO + 0;
  my $str = "$POSIX::Wide::ERRNO";
  is ($num, POSIX::EBADF(), 'ERRNO number EBADF');
  ok (utf8::is_utf8($str),  'ERRNO string is_utf8');

 SKIP: {
    (defined &utf8::valid)
      or skip 'utf8::valid not available', 1;

    ok (utf8::valid($str), 'ERRNO string utf8::valid');
  }
}

require Scalar::Util;
diag 'Scalar::Util version ',Scalar::Util->VERSION;

exit 0;
