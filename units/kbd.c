#include <string.h> // memcpy
#include <unistd.h> // read

// temporarily unset __GNUC__ to avoid inline assembly
#define __SAVE_GNUC__ __GNUC__
#undef __GNUC__
#include <sys/select.h> // select, FD_*
#define __GNUC__ __SAVE_GNUC__

#include <stdio.h>   // sscanf
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

// A pascal compatible readkey function that returns 0 if there is a pending
// escape code and translates escape codes to Pascal keyscan numbers. The
// keyscan mapping is based on fpc/rtl/inc/keyscan.inc
int escape_state = 0; // 0, 27
int readkey()
{
    int sz;
    unsigned char c;

    if ((sz = read(0, &c, 1)) < 1) {
        return -1;
    }
    if (escape_state == 27 && (c == 79 || c == 91)) {
        escape_state = 0;
        c = readkey();
        // TODO: more mappings
        switch (c) {
            // Arrow keys
            case 0x41: c = 0x48; break; // up
            case 0x42: c = 0x50; break; // down
            case 0x43: c = 0x4d; break; // right
            case 0x44: c = 0x4b; break; // left
        }
    } else if (escape_state == 27) {
        escape_state = 0;
        // TODO: key mapping
    } else if (c == 27 && kbd_pending()) {
        escape_state = 27;
        c = 0;
    }
    return c;
}

// read a string into dst until whitespace is detected. len is the maximum
// number of characters that can be read
int readstr(char * dst, int len) {
    int idx = 0, done = 0;
    unsigned int c;
    if (len == 0) {
        return 0;
    }
    while (idx < len - 1) {
        c = readkey();
        switch (c) {
            case -1:
            case 8:  // tab
            case 10: // line feed
            case 13: // carriage return
            case 32: // space
                done = 1;
                break;
            default:
                dst[idx] = c;
                idx++;
        }
        // echo typing
        if (isatty(0) && c > 0) {
            if (c == 10 || c == 13) {
                printf("\n");
            } else {
                printf("%c", c);
            }
            fflush(stdout);
        }
        if (done) {
            break;
        }
    }
    dst[idx] = '\0';
    return idx;
}

// Like sscanf but works on the raw terminal and is limited to a single input
// argument pointer. Passing more than one conversion specification in the
// format string will cause undefined behavior.
int raw_scanf(char * format, void * ptr) {
    char str[256];
    readstr(str, sizeof(str));
    return sscanf(str, format, ptr);
}

#ifdef KBD_MAIN1
int main()
{
    struct termios *save_termios;
    char c;

    save_termios = termios_raw();

    printf("Press keys to show codes, or q to exit\n");
    while (1) {
        c = readkey();
        printf("got character value: %d\n", c);
        if (c == 113) { break; }
    }
    termios_restore(save_termios);
}
#endif

#ifdef KBD_MAIN2
int main()
{
    struct termios *save_termios;
    save_termios = termios_raw();

    int i, j;
    raw_scanf("%d", &i);
    raw_scanf("%d", &j);
    printf("read integers %d and %d\n", i, j);
    termios_restore(save_termios);
}
#endif
