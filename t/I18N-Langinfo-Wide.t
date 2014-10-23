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
use Test::More tests => 7;

BEGIN {
 SKIP: { eval 'use Test::NoWarnings; 1'
           or skip 'Test::NoWarnings not available', 1; }
}

require I18N::Langinfo::Wide;

my $want_version = 2;
is ($I18N::Langinfo::Wide::VERSION, $want_version, 'VERSION variable');
is (I18N::Langinfo::Wide->VERSION,  $want_version, 'VERSION class method');
{ ok (eval { I18N::Langinfo::Wide->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { I18N::Langinfo::Wide->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}

require I18N::Langinfo;
my @itemnames = grep {/^[A-Z_]/} @I18N::Langinfo::EXPORT_OK;
diag "items: ", join(' ',@itemnames);
cmp_ok (@itemnames, '!=', 0, 'itemnames found');

sub itemname_to_item {
  my ($itemname) = @_;
  my $itemfullname = "I18N::Langinfo::$itemname";
  no strict 'refs';
  return &$itemfullname();
}

{
  my $good = 1;
  foreach my $itemname (@itemnames) {
    my $item = itemname_to_item ($itemname);
    my $value = I18N::Langinfo::Wide::langinfo ($item);

    if (! utf8::is_utf8 ($value)) {
      diag "$itemname not utf8::is_utf8";
      $good = 0;
    }

    if (defined &utf8::valid && ! utf8::valid ($value)) {
      diag "$itemname not utf8::valid";
      $good = 0;
    }
  }
  ok ($good, (scalar @itemnames) . ' values');
}

exit 0;
