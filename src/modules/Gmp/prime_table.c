/* $Id: prime_table.c,v 1.3 1998/07/11 18:35:27 grubba Exp $
 *
 * Generates a table of small odd primes.
 */

#include <stdio.h>
#include <stdlib.h>

void fill_table(unsigned long *primes, unsigned long *squares, int length);
void write_table(char *program,
		 unsigned long *primes, unsigned long *squares, int length);

int
main(int argc, char **argv)
{
  int length;
  unsigned long *table;
  
  if ( (argc != 2) || ((length = atoi(argv[1])) < 1))
    {
      fprintf(stderr, "Usage: %s tablesize\n", argv[0]);
      exit(1);
    }

  table = (unsigned long *) malloc(2 * length * sizeof(*table));
  fill_table(table, table + length, length);
  write_table(argv[0], table, table + length, length);
  return 0;
}

void
fill_table(unsigned long *primes, unsigned long *squares, int length)
{
  int i;
  int j;
  unsigned long n;

  primes[0] = 2; squares[0] = 4;
  i = 1;
  n = 3;
  while (i < length)
    {
      for (j=0; (j < i) && (squares[j] <= n); j++)
	{
	  if (n % primes[j] == 0)
	    /* n is no prime */
	    goto outer;
	}
      primes[i] = n; squares[i] = n*n;
      i++;
    outer:
      n += 2;
    }
}


void
write_table(char *program, unsigned long *primes, unsigned long *squares, int length)
{
  int i;
  
  printf("/* Automatically generated by\n"
	 " * %s %d\n"
	 " * Do not edit.\n"
	 " */\n\n", program, length);
  printf("#define NUMBER_OF_PRIMES %d\n\n", length);

  printf("const unsigned long primes[NUMBER_OF_PRIMES] = {");
  for (i=0; i<length - 1; i++)
    {
      if (i % 10 == 0)
	printf("\n   ");
      printf("%ld, ", (long)primes[i]);
    }
  printf("%ld };\n\n", (long)primes[i]);

#if 0
  printf("const unsigned long prime_squares[NUMBER_OF_PRIMES] = {");
  for (i=0; i<length - 1; i++)
    {
      if (i % 10 == 0)
	printf("\n   ");
      printf("%d, ", squares[i]);
    }
  printf("%d };\n", squares[i]);
#endif
}
