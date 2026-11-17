# Compiler-Optimizations-Dead-Code-Elimination-and-Function-Inlining
This is a repository created to reflect my exploration of dead code elimination and function inlining.

## Compiler Optimizations in C
### Big idea
In C, a compiler doesn't only translate C into machine code, but it can also rewrite the program as long as the **observable behavior** stays the same. Observable behavior includes what gets print, what gets returned, **volatile variables**, etc. The compiler can decide how other processes happen, which is called the **as-if rule**.

#### Volatile Variables
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

A **tradeoff** for function inlining is code bloat. For example, if a large function is inlined at 50 call sites, there are 50 copies of this large function. This can hurt the **instruction cache**.

**What is the Instruction Cache**
CPUs have small, fast memories called **caches** that hold recently used data for quick reuse.
Most CPUs split the closest cache into two parts:
- **Data Cache**: holds the variables and arrays your programs reads/writes.
- **Instruction Cache**: holds the machine code instructions that the CPU executes.

The instruction cache is small and holds a limited amount of space. With inlining, several copies of a large function may get stored in the instruction cache, pushing other, possibly more important code, to be stored in lower levels such as RAM. The CPU would have to fetch the other code from these lower levels, which can cost multiple cycles and slow things down.

**Heuristics: a Possible Fix to the Tradeoff Above**
A **heuristic** is an educated guess. The compiler doesn't know for sure if inlining a call will make the program faster, so the compiler estimates the costs and benefits and compares them. 
For inlining, it considers:
- Function size: small functions over larger ones
- Number of call sites: static functions called once are almost always inlined since there's no duplication
- Where the call is: calls inside loops are worth inlining
- Constant arguments: inlining can simplify function bodies using known arguments.
- Recursion: recursive functions are harder to inline since the body contains a call to itself.

## Real-World Examples of Dead Code Elimination
- **Getters and setters**. In object-oriented programming, you write small methods like getX() that return a field. Calling them in a loop would be wasteful, so compilers inline them.
- **Small math helpers**. Functions like **min(a,b), abs(x), square(x)** are a line or two long. They might run billions of times per second in a game or graphics program, so inlining makes them just as fast as writing the math by hand.
- **The standard library.** Many things in C++'s standard library are small functions that rely on inlining. Without it, they would be much slower.
- **Java's JIT.** In Java, the JVM watches the methods that are running most often and inlines those.


