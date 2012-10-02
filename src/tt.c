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

#include <dirent.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/unistd.h>

#include "tt.h"

void die(const char* msg)
{
	fprintf(stderr, "%s\n", msg);
	exit(EXIT_FAILURE);
}

int main(void)
{
	DIR *proc;
	DIR *fd;
	struct dirent proc_entry;
	struct dirent *proc_entryp;
	struct dirent fd_entry;
	struct dirent *fd_entryp;
	char path[PATH_MAX];
	char fd_path[PATH_MAX];
	char file_path[PATH_MAX];
	struct stat info;
	int err;
	uid_t uid;

	uid = getuid();

	proc = opendir("/proc");

	if(proc == NULL)
	{
		die("Could not open proc");
	}

	err = readdir_r(proc, &proc_entry, &proc_entryp);

	while(err == 0 && proc_entryp != NULL)
	{
		snprintf(path, sizeof(path), "/proc/%s", proc_entry.d_name);

		err = stat(path, &info);

		if(err == 0)
		{
			if(info.st_uid == uid)
			{
				snprintf(fd_path, sizeof(fd_path), "%s/fd", path);

				fd = opendir(fd_path);

				if(fd == NULL)
				{
					fprintf(stderr, "Error reading path: %s\n", fd_path);
				}
				else
				{
					err = readdir_r(fd, &fd_entry, &fd_entryp);
					while(err == 0 && fd_entryp != NULL)
					{
						snprintf(fd_path, sizeof(fd_path), "%s/fd/%s", path, fd_entry.d_name);
						err = readlink(fd_path, file_path, sizeof(file_path));
						file_path[err] = 0;

						err = stat(file_path, &info);

						if(err != 0)
						{
							fprintf(stderr, "Could not stat: %s\n", file_path);
						}
						else
						{
							printf("%s\t%s\t%i\t%i\t%lu\t%lu\n", proc_entry.d_name, file_path, info.st_uid, major(info.st_rdev), info.st_atime, info.st_mtime);
						}

						err = readdir_r(fd, &fd_entry, &fd_entryp);
					}

					if(err != 0)
					{
						fprintf(stderr, "Could not read directory: %s\n", fd_path);
					}

					closedir(fd);
				}
			}
		}
		else
		{
			fprintf(stderr, "Error reading path: %s\n", path);
		}

		err = readdir_r(proc, &proc_entry, &proc_entryp);
	}

	if(err != 0)
	{
		die("Could not read proc");
	}

	closedir(proc);

	exit(EXIT_SUCCESS);
}
