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

{
  require Encode;
  foreach (Encode->encodings(':all')) { print; print "\n"; }

  print "with :all\n";
  require Encode;
  foreach (Encode->encodings(':all')) { print; print "\n"; }

  print "alias: ", Encode::resolve_alias("646"), "\n";

  exit 0;
}
{
  requrie POSIX;
  print "perror defined: ",defined(&perror)?"yes":"no","\n";
  print "can('perror'): ",POSIX->can('perror')?"yes":"no","\n";
  $! = 3;
  POSIX::perror();
}

{
  print "strcspn defined: ",defined(&strcspn)?"yes":"no","\n";
  print "can('strcspn'): ",POSIX->can('strcspn')?"yes":"no","\n";
  POSIX::strcspn();
}

{
  print "TZNAME_MAX is ",POSIX::sysconf(POSIX::_SC_TZNAME_MAX()),"\n";
  exit 0;
}

exit 0;
