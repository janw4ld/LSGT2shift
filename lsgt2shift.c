#include <stdio.h>
#include <stdlib.h>

#include <linux/input.h>

int read_event(struct input_event *event) {
    return fread(event, sizeof(struct input_event), 1, stdin) == 1;
}

void write_event(const struct input_event *event) {
    if (fwrite(event, sizeof(struct input_event), 1, stdout) != 1) {
        exit(EXIT_FAILURE);
    }
}

int main(void) {
    struct input_event input;
    setbuf(stdin, NULL), setbuf(stdout, NULL);

    while (read_event(&input)) {
        if (input.type == EV_KEY && input.code == KEY_102ND) {
            input.code = KEY_LEFTSHIFT;
        }
        write_event(&input);
    }
}
