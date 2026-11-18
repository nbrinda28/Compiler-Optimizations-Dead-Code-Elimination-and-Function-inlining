#include <stdio.h>

static int is_debug(void) { return 0; }

static __attribute__((noinline)) void debug_overlay(void) {
    puts("debug overlay");
}

int main(void) {
    if (is_debug()) debug_overlay();
    puts("scene");
    return 0;
}