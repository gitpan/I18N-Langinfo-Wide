#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use strict;
use warnings;
use POSIX::Wide;


{
  delete $ENV{'LANGUAGE'};
  require POSIX;
  print POSIX::setlocale(POSIX::LC_ALL(),'fr_FR'),"\n";

  $! = 4;
  print $!,"\n";
  print $POSIX::Wide::ERRNO,"\n";

  print $^E,"\n";
  print utf8::is_utf8("$^E"),"\n";
  print $POSIX::Wide::EXTENDED_OS_ERROR,"\n";
  print utf8::is_utf8("$POSIX::Wide::EXTENDED_OS_ERROR"),"\n";
  exit 0;
}
