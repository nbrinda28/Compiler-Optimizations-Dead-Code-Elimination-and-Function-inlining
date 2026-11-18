#include <stdio.h>
#include <stdlib.h>

#ifdef NOINLINE
#define MODE __attribute__((noinline))
#else
#define MODE __attribute__((always_inline)) inline
#endif

static MODE unsigned mix(unsigned x) { return x * 3u + 1u; }

int main(int argc, char *argv[]) {
    long reps = (argc > 1) ? atol(argv[1]) : 250000L;
    enum { N = 4096 };
    static unsigned a[N];
    for (int i = 0; i < N; i++) a[i] = i;
    for (long r = 0; r < reps; r++)
        for (int i = 0; i < N; i++)
            a[i] = mix(a[i]);
    printf("%u\n", a[N - 1]);
    return 0;
}