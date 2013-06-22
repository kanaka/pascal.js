#include <string.h> // memcpy
#include <unistd.h> // read

// temporarily unset __GNUC__ to avoid inline assembly
#define __SAVE_GNUC__ __GNUC__
#undef __GNUC__
#include <sys/select.h> // select, FD_*
#define __GNUC__ __SAVE_GNUC__

#include <stdlib.h>  // on_exit
#include <termios.h>

void termios_restore(void *orig_termios)
{
    // restore the terminal to orig_termios modes
    tcsetattr(0, TCSANOW, (struct termios*)orig_termios);
}

void termios_cleanup(int status, void *orig_termios)
{
    termios_restore(orig_termios);
    free(orig_termios); // probably not necessary
}

struct termios *termios_raw()
{
    struct termios *cur_termios;
    struct termios raw_termios;

    // get the current termios modes and register an exit handler to restore
    // the termios modes to the current settings
    cur_termios = malloc(sizeof(struct termios));
    tcgetattr(0, cur_termios);
    on_exit(termios_cleanup, cur_termios);

    // Make the terminal raw
    memcpy(&raw_termios, cur_termios, sizeof(raw_termios));
    cfmakeraw(&raw_termios);
    // But keep implementation specific output processing
    raw_termios.c_oflag |= OPOST;

    tcsetattr(0, TCSANOW, &raw_termios);

    return cur_termios;
}

int kbd_pending()
{
    struct timeval tv = { 0L, 0L };
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(0, &fds);
    return select(1, &fds, NULL, NULL, &tv);
}

int readchar()
{
    int sz;
    unsigned char c;
    if (read(0, &c, 1) < 1) {
        return -1;
    } else {
        return c;
    }
}

#ifdef KBD_MAIN
#include <stdio.h>
int main()
{
    struct termios *save_termios;
    char c;

    printf("Press a key\n");

    save_termios = termios_raw();

    while (!kbd_pending()) {
    }
    c = readchar();
    termios_restore(save_termios);
    printf("got character: %c\n", c);
}
#endif
