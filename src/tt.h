#ifndef TT_H
#define TT_H

#define TT_CMDLINE_MAX 1024
#define TT_LINK_MAX 1024

#ifdef TT_X_PROPS
#define TT_X_PROP_MAX 1024
#endif

struct task
{
	pid_t pid;
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
}

#endif
