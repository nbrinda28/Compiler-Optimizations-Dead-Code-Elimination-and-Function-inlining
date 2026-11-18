int main(void) {
    volatile long sum = 0;   // volatile: every access is observable behavior
    for (long i = 0; i < 1000000000; i++) sum += i;
    return 0;
}