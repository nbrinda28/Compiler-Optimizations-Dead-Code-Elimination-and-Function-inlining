#include <stdio.h>
#include <stdlib.h>

static int square(int x) { return x * x; }

int main(int argc, char *argv[]) {
    long n = (argc > 1) ? atol(argv[1]) : 1000000000L;  // not a compile-time constant
    long total = 0;
    for (long i = 0; i < n; i++) {
        total += square(i % 100);
    }
    printf("%ld\n", total);   // result is used, so the loop isn't dead code
    return 0;
}