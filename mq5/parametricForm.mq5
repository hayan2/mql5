//--- 250P

#define A 2 + 3
#define B 5 - 1
#define MUL(a, b) ((a) * (b))
// double  c = ((2 + 3) * (5 - 1)) ;
double c = MUL(A, B);
Print("c = ", c);
// result  c = 20

#define A 2 + 3
#define B 5 - 1
#define MUL(a, b) a* b
// double  c = 2 + 3 * 5 - 1;
double c = MUL(A, B);
Print("c=", c);
// result c = 16