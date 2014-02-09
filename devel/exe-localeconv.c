/* Copyright 2014 Kevin Ryde

   This file is part of I18N-Langinfo-Wide.

   I18N-Langinfo-Wide is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 3, or (at your option) any later
   version.

   I18N-Langinfo-Wide is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
   for more details.

   You should have received a copy of the GNU General Public License along
   with I18N-Langinfo-Wide.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <locale.h>
#include <langinfo.h>

int
main (void)
{
  struct lconv *lconv = localeconv();
  printf ("%s  %d\n", lconv->positive_sign, lconv->positive_sign[0]);
  return 0;
}
