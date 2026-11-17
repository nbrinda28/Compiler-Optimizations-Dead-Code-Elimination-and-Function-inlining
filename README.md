# Compiler-Optimizations-Dead-Code-Elimination-and-Function-Inlining
This is a repository created to reflect my exploration of dead code elimination and function inlining.

## Compiler Optimizations in C
### Big idea
In C, a compiler doesn't only translate C into machine code, but it can also rewrite the program as long as the **observable behavior** stays the same. Observable behavior includes what gets print, what gets returned, **volatile variables**, etc. The compiler can decide how other processes happen, which is called the **as-if rule**.

### Volatile Variables
**What is a volatile variable?**
Volatile is a keyword that signals to the compiler that the variable can change or be observed in ways the compiler cannot see. A compiler normally assumes that a variable only changes when our code changes it. The **volatile** keyword removes that assumption.

```
volatile int flag = 0;
volatile long sum = 0
```

### Optimization Levels
When we create an executable, we can decide the level at which the compiler attempts optimization.

<img width="450" height="213" alt="image" src="https://github.com/user-attachments/assets/d65d25f8-9bcf-4b1e-9acf-2a0e7a308b0c" />

(from Claude AI)

## Dead Code Elimination (DCE)
**Dead code** is code that cannot affect observable behavior. Two kinds include:
- **Unreachable code**: code that can never execute.
- **Dead stores/unused computations**: Values that are computed but never used.

```
int f(int x) {
    int unused = x * 2;     // computed, never used → dead
    if (0) {
        printf("never!\n"); // unreachable → dead
    }
    return x + 1;
}
```
With a flag of -01 or higher, the compiler transforms this into:

```
int f(int x) { return x + 1; }
```
The compiler knows to do this because it visualizes how data flows in a function.

**Why do Volatile Variables Stop Dead Code Elimination?**
Volatile objects are considered observable behavior, and DCE only removes code that doesn't affect observable behavior. The tradeoff for this is that a volatile accumulator could make your loop slower because it forces memory traffic, since the compiler cannot skip or combine operations on a volatile object.

### Real-World Examples of Dead Code Elimination
- **Debug code in released software**. Developers write logging and debug checks:
```
#ifdef DEBUG
    printf("x = %d\n", x);
#endif
```
  Modern compilers handle troubleshooting checks as dead code instead of programmers having to manually delete or comment them out.
- **Shrinking apps and web pages.** Android's R8 and JavaScript bundlers use the same idea (called "tree shaking") to remove unused library functions.
- **Large codebases with legacy features.** Big projects can inherit features that are turned off by configuration. The compuler removes this disabled code from the final binary to the program is smaller without having to manually clean it up.
- **Security-sensitive code.** DCE can backfire. Programmers sometimes overwrite the memory space of used passwords with **00000..** to hide what the original password was. If this password is not printed or used, the compiler may treat that step as dead code (since it doesn't change the final observable behavior), and thus skip it. This would leave the actual password in the computer's memory, making it easy for hackers to access. This is why keywords like **volatile** are necessary, so the compiler does not write off important steps as dead code.

## Function Inlining
Calling a function usually has some cost. It requires arguments to be set up, the program to jump to the function, create a stack frame, and then jump back and clean up.
**Inlining** replaces a function call with the function's body.

```
static int square(int x) { return x * x; }

int main(void) {
    int a = square(5);
    ...
}
```
After inlining, it would be as if you wrote **int a = 5*5**, which yields the same result as if you called the function, but with fewer costs.
A larger benefit is that inlining can *enable other optimizations*.
For instance, **5*5** can then be constant-folded to 25, and if **a** is unused, then DCE removes it entirely.

**constant-folding** is when the compiler does math at compile-time when every value in an expression is already known, so the program doesn't have to recalculate every time it runs.

A **tradeoff** for function inlining is code bloat. For example, if a large function is inlined at 50 call sites, there are 50 copies of this large function. This can hurt the **instruction cache**.


### What is the Instruction Cache?

CPUs have small, fast memories called **caches** that hold recently used data for quick reuse.
Most CPUs split the closest cache into two parts:
- **Data Cache**: holds the variables and arrays your programs reads/writes.
- **Instruction Cache**: holds the machine code instructions that the CPU executes.

The instruction cache is small and holds a limited amount of space. With inlining, several copies of a large function may get stored in the instruction cache, pushing other, possibly more important code, to be stored in lower levels such as RAM. The CPU would have to fetch the other code from these lower levels, which can cost multiple cycles and slow things down.


### Heuristics: a Possible Fix to the Tradeoff Above

A **heuristic** is an educated guess. The compiler doesn't know for sure if inlining a call will make the program faster, so the compiler estimates the costs and benefits and compares them. 
For inlining, it considers:
- Function size: small functions over larger ones
- Number of call sites: static functions called once are almost always inlined since there's no duplication
- Where the call is: calls inside loops are worth inlining
- Constant arguments: inlining can simplify function bodies using known arguments.
- Recursion: recursive functions are harder to inline since the body contains a call to itself.

### Real-World Examples of Function Inlining
- **Getters and setters**. In object-oriented programming, you write small methods like getX() that return a field. Calling them in a loop would be wasteful, so compilers inline them.
- **Small math helpers**. Functions like **min(a,b), abs(x), square(x)** are a line or two long. They might run billions of times per second in a game or graphics program, so inlining makes them just as fast as writing the math by hand.
- **The standard library.** Many things in C++'s standard library are small functions that rely on inlining. Without it, they would be much slower.
- **Java's JIT.** In Java, the JVM watches the methods that are running most often and inlines those.

## Experimenting With Optimization Levels, Dead Code Elimination, and Function Inlining

### Experiment 1: Timing Across -O0 to -O3

bench.c
```
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
```
Printing **total** stops DCE from deleting the loop because it is considered an observable variable.

Build and time each level. In the command line:
```
for O in O0 O1 O2 O3; do gcc -$O bench.c -o bench_$O; done

for O in O0 O1 O2 O3; do
  echo "== -$O"
  for run in 1 2 3; do
    ( time ./bench_$O 1000000000 > /dev/null ) 2>&1 | grep real
  done
done
```
Run each level 3 times and record the average. Also check the binary size with `ls -l bench_O*` or `size bench_O*`.

### Experiment 2: Dead Code Elimination

**Part A: A loop that vanishes**

dce.c
```
int main(void) {
    long sum = 0;
    for (long i = 0; i < 1000000000; i++) sum += i;
    return 0;   // sum is never used
}
```
In terminal:
```
gcc -O0 dce.c -o dce0 && time ./dce0
gcc -O2 dce.c -o dce2 && time ./dce2
gcc -O2 -S dce.c -o dce2.s
cat dce2.s
```
At -O0, it takes about 1 second
At -O2, it's almost instant.
In dce2.s, **main** should be just a few instructions with no loop.

Now try `volatile long sum = 0;` and rebuild at -O2. 
The loop should come back because volatile accesses are observable behavior.

**Part B: A removed branch and function**

debug.c
```
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
```
In terminal:
```
gcc -O0 debug.c -o debug0
gcc -O2 debug.c -o debug2

nm debug0 | grep -E "is_debug|debug_overlay"   # both symbols present
nm debug2 | grep -E "is_debug|debug_overlay"   # both gone

gcc -O0 -S debug.c -o debug0.s
gcc -O2 -S debug.c -o debug2.s
grep call debug0.s    # call is_debug, call puts...
grep call debug2.s    # just the call to puts for "scene"
```
At -O2 the function `is_debug` is inlined (becoming 0). This is an example of **constant-folding**, since we know is_debug returns 0.
The `if(0)` branch is dead, and the `debug_overlay` has no callers left, so the compiler deletes the whole function.
This shows inlining, constant-folding, and DCE chaining together.

### Experiment 3: Function Inlining

Compare the assembly.

In terminal:
```
gcc -O0 -S bench.c -o bench0.s
gcc -O2 -S bench.c -o bench2.s
grep -n "call" bench0.s    # expect: call square
grep -n "call" bench2.s    # square call should be gone
```
Ask GCC what it inlined:
```
gcc -O2 -fopt-info-inline-optimized -c bench.c
```
Isolate inlining's effect on speed.
```
gcc -O2 bench.c -o bench_O2
gcc -O2 -fno-inline bench.c -o bench_O2_noinline
time ./bench_O2 1000000000
time ./bench_O2_noinline 1000000000
```
Any difference is due to inlining and other optimizations it may enable.

## Helpful Diagrams

Using the code snippet above:
```
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
```

<img width="444" height="257" alt="image" src="https://github.com/user-attachments/assets/2ed9f200-cffd-482c-8184-ebf2d13bbc4c" />

(From Claude AI: How inlining, constant-folding, and DCE can chain together)

<img width="377" height="144" alt="image" src="https://github.com/user-attachments/assets/8f304512-791c-408c-a12d-b30a7f6a31fc" />

(From Claude AI: Instruction Cache problem with inlining)

Note that **hot-code** is code that runs frequently, like a loop body. You want hot code to stay inside the cache so that it's easily accessible.

## Additional Resources
Claude AI Chat: https://claude.ai/share/1bdc886a-1bf3-4f69-84a4-4293d6cc1f43 

GCC Optimization Options: https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html

As-If Rule: https://en.cppreference.com/w/c/language/as_if

Dead Code Elimination: https://opencs.aalto.fi/en/courses/modern-and-emerging-programming-languages/part-7/3-compiler-optimization-techniques

Volatile and Naive Benchmarks: https://www.mathworks.com/help/bugfinder/ref/certcrec.msc06c.html

Constant-Folding: https://en.wikipedia.org/wiki/Constant_folding

Inlining and the Instruction Cache: https://en.wikipedia.org/wiki/Inline_expansion

Hot Code and Profile-Guided Optimization: https://arxiv.org/pdf/1403.6997

