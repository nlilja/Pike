/*
 * $Id: odbc.pike,v 1.4 2000/04/29 00:10:32 kinkie Exp $
 *
 * Glue for the ODBC-module
 */

#if constant(Odbc.odbc)
inherit Odbc.odbc;

int|object big_query(object|string q, mapping(string|int:mixed)|void bindings)
{  
  if (!bindings)
    return ::big_query(q);
  return ::big_query(.sql_util.emulate_bindings(q,bindings));
}

#else /* !constant(Odbc.odbc) */
#error "ODBC support not available.\n"
#endif /* constant(Odbc.odbc) */
