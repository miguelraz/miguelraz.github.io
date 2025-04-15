@def title = "🚧 WIP 🚧 The road to typed globals in Julia"

Plan of attack:
- Add a type field to every global binding -> Easier task, probably mechanical. Look for it in the C code that implements global bindings.


1. At the behest of Stefan, he suggested the following:
> Figure out what happens when you do `x = 123` in global scope, that should help

### Finding what happens with `x = 123`
I tried `rg "assignment"` within `julia/src` and tried to clue where I could find the culprit.
I posted in Slack about it, and Simeon Schaub pointed me towards `src/interpreter.c` (which came up in one of the `rg` searches but I ignored it).

(Morning!) I finally landed on something interesting
```c
        else if (jl_is_expr(stmt)) {
    1             // Most exprs are allowed to end a BB by fall through
    2             jl_sym_t *head = ((jl_expr_t*)stmt)->head;
    3             if (head == jl_assign_sym) {
    4                 jl_value_t *lhs = jl_exprarg(stmt, 0);
    5                 jl_value_t *rhs = eval_value(jl_exprarg(stmt, 1), s);
    6                 if (jl_is_slot(lhs)) {
    7                     ssize_t n = jl_slot_number(lhs);
    8                     assert(n <= jl_source_nslots(s->src) && n > 0);
    9                     s->locals[n - 1] = rhs;
   10                 }
   11                 else {
   12                     jl_module_t *modu;
   13                     jl_sym_t *sym;
   14                     if (jl_is_globalref(lhs)) {
   15                         modu = jl_globalref_mod(lhs);
   16                         sym = jl_globalref_name(lhs);
   17                     }
   18                     else {
   19                         assert(jl_is_symbol(lhs));
   20                         modu = s->module;
   21                         sym = (jl_sym_t*)lhs;
   22                     }
   23                     JL_GC_PUSH1(&rhs);
   24                     jl_binding_t *b = jl_get_binding_wr(modu, sym, 1);
   25                     jl_checked_assignment(b, rhs);
   26                     JL_GC_POP();
   27                 }
   28             }
```
This is a block that checks if there is an expression, and if it is an assignment, to handle the assignment.

Specifically, it's the block on lines 23-26 that assigns to globals, but first it must (by fishing for the definition of `jl_get_binding_wr` and `jl_checked_assignment`)
* check there is a binding
* check the types match and assign the value (aka, actually carry out the `x = 123`.)

Now thinking a bit more clearly in the morning, it is not sufficient to just patch the assignment here in the `src/interpreter.c`,
because that would only help when the REPL is running, but also with the `jl_check_assignment` function itself.

Let's read what's in `jl_checked_assignment`:
```
JL_DLLEXPORT void jl_checked_assignment(jl_binding_t *b, jl_value_t *rhs) JL_NOTSAFEPOINT
    1 {
    2     if (b->constp) {
    3         jl_value_t *old = NULL;
    4         if (jl_atomic_cmpswap(&b->value, &old, rhs)) {
    5             jl_gc_wb_binding(b, rhs);
    6             return;
    7         }
    8         if (jl_egal(rhs, old))
    9             return;
   10         if (jl_typeof(rhs) != jl_typeof(old) || jl_is_type(rhs) || jl_is_module(rhs)) {
   11 #ifndef __clang_gcanalyzer__
   12             jl_errorf("invalid redefinition of constant %s",
   13                       jl_symbol_name(b->name));
   14 #endif
   15         }
   16         jl_safe_printf("WARNING: redefinition of constant %s. This may fail, cause incorrect answers, or produce other errors.\n",
   17                        jl_symbol_name(b->name));
   18     }
   19     jl_atomic_store_relaxed(&b->value, rhs);
   20     jl_gc_wb_binding(b, rhs);
   21 }
```

Ok let's see what's going on here:
1. The input is a `jl_binding_t` or a Julia `b`inding type pointer, and a `jl_value_t *rhs` a pointer to the type of the right hand side.
Hmmm - I don't know what this type is so I'll go grep around and see what that is.
(15 mins later) Ok, the grepping was kinda hit and miss and I scrolled aimlessly for a bit until I saw the `static` so I think that meant a definition and I think I found what `jl_binding_t` is in `module.c`:
```
static jl_binding_t *new_binding(jl_sym_t *name)
    1 {
    2     jl_task_t *ct = jl_current_task;
    3     assert(jl_is_symbol(name));
    4     jl_binding_t *b = (jl_binding_t*)jl_gc_alloc_buf(ct->ptls, sizeof(jl_binding_t));
    5     b->name = name;
    6     b->value = NULL;
    7     b->owner = NULL;
    8     b->globalref = NULL;
    9     b->constp = 0;
   10     b->exportp = 0;
   11     b->imported = 0;
   12     b->deprecated = 0;
   13     return b;
   14 }
```
So this must be what a "variable" looks like to Julia! We check that the `name` can be made into a symbol, allocate storage for a `jl_binding_t` through the `*b` pointer , and then proceed to
state it's value, and all the interesting internal knobs to work with it

In a humbling moment, I realize that this definition is literally atop of the previous one I just read. Literally 2 lines of code above.

Wiping away a single tear, let's consider if we should add a global type to this struct itself.

2. Now all those `b->things` make a lot more sense in the `jl_checked_assignment`:
You check if different properties apply by going through the pointer and do the appropriate way of assigning.

3. (15 minutes later) Hmm - I think this is still building a `jl_binding_t`, not specifically defining the struct for it. If I want to modify that struct itself I need to find the actual definition, because I'm actually looking at the the function `new_binding(jl_sym_t *name){...}`, which is a function that is given the pointer to a symbol and constructs a binding from it, not the structure of the binding itself.

4. Ok, the file I was looking at `src/module.c` where `jl_checked_assignment` is defined only imports `"julia.h"` and like 2 other files, so it stands to reason that the struct is defined from a place it's imported. Fire up the editor and I get:
```
typedef struct {
     1     // not first-class
     2     jl_sym_t *name;
     3     _Atomic(jl_value_t*) value;
     4     _Atomic(jl_value_t*) globalref;  // cached GlobalRef for this binding
     5     struct _jl_module_t* owner;  // for individual imported bindings -- TODO: make _Atomic
     6     uint8_t constp:1;
     7     uint8_t exportp:1;
     8     uint8_t imported:1;
     9     uint8_t deprecated:2; // 0=not deprecated, 1=renamed, 2=moved to another package
    10 } jl_binding_t;
```
Which is a weird looking struct but it's the C way to make one, via a `typedef` and putting the name after the `struct {...} name`.
5. (10 minutes later) OK so re-reading the assignment [about global type annotations](https://github.com/JuliaLang/julia/issues/8870#issuecomment-320101744), the point is to add a
special path to the function and if if there is a `x::Int = 123` typing, then make that type valid.

6. (post lunch slump) Chat has answered: Jeff suggests we just add a `jl_value_t *ty` to the struct and get it on with. Actually started a new `typedglobals` git branch and started adding code.

7. (spaced out on twitter for 10 minutes) Ok actually added code.
