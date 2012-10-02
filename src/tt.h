/*

Copyright 2012 Carl D Hamann

This file is part of tt.

tt is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

tt is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with tt.  If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef TT_H
#define TT_H

#include <sys/types.h>
#include <time.h>

#define TT_CMDLINE_MAX 1024
#define TT_LINK_MAX 1024

#ifdef TT_X_PROPS
#define TT_X_PROP_MAX 1024
#endif

struct task
{
	pid_t pid;
	time_t atime;
	char cmdline[TT_CMDLINE_MAX];
	char cwd[TT_LINK_MAX];
	char exe[TT_LINK_MAX];
	char tty[TT_LINK_MAX];
#ifdef TT_X_PROPS
	char wm_class[X_PROP_MAX];
	char wm_command[X_PROP_MAX];
	char wm_icon_name[X_PROP_MAX];
	char wm_name[X_PROP_MAX];
#endif
};

#endif
