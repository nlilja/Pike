/*\
||| This file a part of Pike, and is copyright by Fredrik Hubinette
||| Pike is distributed as GPL (General Public License)
||| See the files COPYING and DISCLAIMER for more information.
\*/

/*
 * $Id: svalue.h,v 1.54 2000/06/09 22:46:21 mast Exp $
 */
#ifndef SVALUE_H
#define SVALUE_H

#include "global.h"

#ifndef STRUCT_ARRAY_DECLARED
#define STRUCT_ARRAY_DECLARED
struct array;
#endif

#ifndef STRUCT_MAPPING_DECLARED
#define STRUCT_MAPPING_DECLARED
struct mapping;
#endif

#ifndef STRUCT_MULTISET_DECLARED
#define STRUCT_MULTISET_DECLARED
struct multiset;
#endif

#ifndef STRUCT_OBJECT_DECLARED
#define STRUCT_OBJECT_DECLARED
struct object;
#endif

#ifndef STRUCT_PROGRAM_DECLARED
#define STRUCT_PROGRAM_DECLARED
struct program;
#endif

#ifndef STRUCT_PIKE_STRING_DECLARED
#define STRUCT_PIKE_STRING_DECLARED
struct pike_string;
#endif

#ifndef STRUCT_CALLABLE_DECLARED
#define STRUCT_CALLABLE_DECLARED
struct callable;
#endif

struct processing
{
  struct processing *next;
  void *pointer_a, *pointer_b;
};

union anything
{
  struct callable *efun;
  struct array *array;
  struct mapping *mapping;
  struct multiset *multiset;
  struct object *object;
  struct program *program;
  struct pike_string *string;
  INT32 *refs;
  INT_TYPE integer;
  FLOAT_TYPE float_number;
  struct svalue *lval;   /* only used on stack */
  union anything *short_lval;   /* only used on stack */
};

#ifndef STRUCT_SVALUE_DECLARED
#define STRUCT_SVALUE_DECLARED
#endif
struct svalue
{
  unsigned INT16 type;
  unsigned INT16 subtype;
  union anything u;
};

#define PIKE_T_ARRAY 0
#define PIKE_T_MAPPING 1
#define PIKE_T_MULTISET 2
#define PIKE_T_OBJECT 3
#define PIKE_T_FUNCTION 4
#define PIKE_T_PROGRAM 5
#define PIKE_T_STRING 6
#define PIKE_T_TYPE 7		/* Not supported yet */
#define PIKE_T_INT 8
#define PIKE_T_FLOAT 9

#define PIKE_T_ZERO  14	/* Can return 0, but nothing else */
#define T_UNFINISHED 15	/* Reserved for the garbage-collector */
#define T_VOID       16	/* Can't return any value */
#define T_MANY       17

#define PIKE_T_SCOPE 243	/* Not supported yet */
#define PIKE_T_TUPLE 244	/* Not supported yet */
#define T_ASSIGN 245
#define T_DELETED 246
#define T_UNKNOWN 247
#define T_SHORT_LVALUE 248
#define T_LVALUE 249
#define T_ARRAY_LVALUE 250
#define T_MIXED 251
#define T_NOT 253
#define T_AND 254
#define T_OR 255


#define tArr(VAL) "\000" VAL
#define tArray tArr(tMix)
#define tMap(IND,VAL) "\001" IND VAL
#define tMapping tMap(tMix,tMix)
#define tSet(IND) "\002" IND
#define tMultiset tSet(tMix)
#define tObj "\003\000\000\000\000\000"

#define tFuncV(ARGS,REST,RET) MagictFuncV(RET,REST,ARGS)
#define tFunc(ARGS,RET) MagictFunc(RET,ARGS)

#define tTuple(T1,T2)		"\364" T1 T2
#define tTriple(T1,T2,T3)	tTuple(T1, tTuple(T2, T3))
#define tQuad(T1,T2,T3,T4)	tTriple(tTuple(T1, T2), T3, T4)

/* These two magic funcions are used to make MSVC++ work
 * even if 'ARGS' is empty.
 */
#define MagictFuncV(RET,REST,ARGS) "\004" ARGS "\021" REST RET
#define MagictFunc(RET,ARGS) tFuncV(ARGS "", tVoid, RET)
#define tFunction tFuncV("" ,tOr(tZero,tVoid),tOr(tMix,tVoid))
#define tNone ""
#define tPrg "\005"
#define tProgram "\005"
#define tStr "\006"
#define tString "\006"
#define tType "\007"
#define tInt "\010\200\000\000\000\177\377\377\377"
#define tInt0 "\010\000\000\000\000\000\000\000\000"
#define tInt1 "\010\000\000\000\001\000\000\000\001"
#define tInt2 "\010\000\000\000\002\000\000\000\002"
#define tInt01 "\010\000\000\000\000\000\000\000\001"
#define tInt02 "\010\000\000\000\000\000\000\000\002"
#define tInt03 "\010\000\000\000\000\000\000\000\003"
#define tInt04 "\010\000\000\000\000\000\000\000\004"
#define tInt05 "\010\000\000\000\000\000\000\000\005"
#define tIntPos "\010\000\000\000\000\177\377\377\377"
#define tInt1Plus "\010\000\000\000\001\177\377\377\377"
#define tInt2Plus "\010\000\000\000\002\177\377\377\377"
#define tByte "\010\000\000\000\000\000\000\000\377"
#define tFlt "\011"
#define tFloat "\011"

#define tZero "\016"
#define tVoid "\020"
#define tVar(X) #X
#define tSetvar(X,Y) "\365" #X Y
#define tScope(X,T) "\363" #X Y
#define tNot(X) "\375" X
#define tAnd(X,Y) "\376" X Y
#define tOr(X,Y) "\377" X Y
#define tOr3(X,Y,Z) tOr(X,tOr(Y,Z))
#define tOr4(X,Y,Z,A) tOr(X,tOr(Y,tOr(Z,A)))
#define tOr5(X,Y,Z,A,B) tOr(X,tOr(Y,tOr(Z,tOr(A,B))))
#define tOr6(X,Y,Z,A,B,C) tOr(X,tOr(Y,tOr(Z,tOr(A,tOr(B,C)))))
#define tOr7(X,Y,Z,A,B,C,D) tOr(X,tOr(Y,tOr(Z,tOr(A,tOr(B,tOr(C,D))))))
#define tOr8(A,B,C,D,E,F,G,H) tOr(A,tOr7(B,C,D,E,F,G,H))
#define tMix "\373"
#define tMixed "\373"
#define tComplex tOr6(tArray,tMapping,tMultiset,tObj,tFunction,tProgram)
#define tStringIndicable tOr5(tMapping,tObj,tFunction,tProgram,tMultiset)
#define tRef tOr(tString,tComplex)
#define tIfnot(X,Y) tAnd(tNot(X),Y)
#define tAny tOr(tVoid,tMix)

#define BIT_ARRAY (1<<PIKE_T_ARRAY)
#define BIT_MAPPING (1<<PIKE_T_MAPPING)
#define BIT_MULTISET (1<<PIKE_T_MULTISET)
#define BIT_OBJECT (1<<PIKE_T_OBJECT)
#define BIT_FUNCTION (1<<PIKE_T_FUNCTION)
#define BIT_PROGRAM (1<<PIKE_T_PROGRAM)
#define BIT_STRING (1<<PIKE_T_STRING)
#define BIT_TYPE (1<<PIKE_T_TYPE)
#define BIT_INT (1<<PIKE_T_INT)
#define BIT_FLOAT (1<<PIKE_T_FLOAT)

#define BIT_ZERO (1<<PIKE_T_ZERO)

/* Used to signify that this array might not be finished yet */
/* garbage collect uses this */
#define BIT_UNFINISHED (1 << T_UNFINISHED)

/* This is only used in typechecking to signify that this 
 * argument may be omitted.
 */
#define BIT_VOID (1 << T_VOID)

/* This is used in typechecking to signify that the rest of the
 * arguments has to be of this type.
 */
#define BIT_MANY (1 << T_MANY)

#define BIT_NOTHING 0
#define BIT_MIXED 0x7fff
#define BIT_BASIC (BIT_INT|BIT_FLOAT|BIT_STRING|BIT_TYPE)
#define BIT_COMPLEX (BIT_ARRAY|BIT_MULTISET|BIT_OBJECT|BIT_PROGRAM|BIT_MAPPING|BIT_FUNCTION)
#define BIT_CALLABLE (BIT_FUNCTION|BIT_PROGRAM|BIT_ARRAY|BIT_OBJECT)

/* Max type which contains svalues */
#define MAX_COMPLEX PIKE_T_PROGRAM
/* Max type with ref count */
#define MAX_REF_TYPE PIKE_T_TYPE
/* Max type handled by svalue primitives */
#define MAX_TYPE PIKE_T_FLOAT

#define NUMBER_NUMBER 0
#define NUMBER_UNDEFINED 1
#define NUMBER_DESTRUCTED 2

#define FUNCTION_BUILTIN USHRT_MAX

#define is_gt(a,b) is_lt(b,a)
#define IS_ZERO(X) ((X)->type==PIKE_T_INT?(X)->u.integer==0:(1<<(X)->type)&(BIT_OBJECT|BIT_FUNCTION)?!svalue_is_true(X):0)

#define IS_UNDEFINED(X) ((X)->type==PIKE_T_INT&&!(X)->u.integer&&(X)->subtype==1)

#define check_destructed(S) \
do{ \
  struct svalue *_s=(S); \
  if((_s->type == PIKE_T_OBJECT || _s->type==PIKE_T_FUNCTION) && !_s->u.object->prog) { \
    free_object(_s->u.object); \
    _s->type = PIKE_T_INT; \
    _s->subtype = NUMBER_DESTRUCTED ; \
    _s->u.integer = 0; \
  } \
}while(0)

/* var MUST be a variable!!! */
#define safe_check_destructed(var) do{ \
  if((var->type == PIKE_T_OBJECT || var->type==PIKE_T_FUNCTION) && !var->u.object->prog) \
    var=&dest_ob_zero; \
}while(0)

#define check_short_destructed(U,T) \
do{ \
  union anything *_u=(U); \
  if(( (1<<(T)) & (BIT_OBJECT | BIT_FUNCTION) ) && \
     _u->object && !_u->object->prog) { \
    free_object(_u->object); \
    _u->object = 0; \
  } \
}while(0)

#ifdef PIKE_DEBUG
extern void describe(void *); /* defined in gc.c */
#define check_type(T) if(T > MAX_TYPE && T!=T_LVALUE && T!=T_SHORT_LVALUE && T!=T_VOID && T!=T_DELETED && T!=T_ARRAY_LVALUE) fatal("Type error: %d\n",T)

#define check_svalue(S) debug_check_svalue(debug_malloc_pass(&(struct svalue) *(S)))

#define check_refs(S) do {\
 if((S)->type <= MAX_REF_TYPE && (!(S)->u.refs || (S)->u.refs[0] < 0)) { \
 describe((S)->u.refs); \
 fatal("Svalue to object without references.\n"); \
} }while(0)

#define check_refs2(S,T) do { \
if((T) <= MAX_REF_TYPE && (S)->refs && (S)->refs[0] <= 0) {\
 describe((S)->refs); \
 fatal("(short) Svalue to object without references.\n"); \
} }while(0)

#ifdef DEBUG_MALLOC
#define add_ref(X) ((INT32 *)debug_malloc_pass( &((X)->refs)))[0]++
#else
#define add_ref(X) (X)->refs++
#endif


#else

#define check_svalue(S)
#define check_type(T)
#define check_refs(S)
#define check_refs2(S,T)
#define add_ref(X) (X)->refs++

#endif

#define free_svalue(X) do { struct svalue *_s=(X); check_type(_s->type); check_refs(_s); if(_s->type<=MAX_REF_TYPE) { debug_malloc_touch(_s->u.refs); if(--*(_s->u.refs) <=0) { really_free_svalue(_s); } DO_IF_DMALLOC(_s->u.refs=(void *)-1;)  }}while(0)
#define free_short_svalue(X,T) do { union anything *_s=(X); TYPE_T _t=(T); check_type(_t); check_refs2(_s,_t); if(_t<=MAX_REF_TYPE && _s->refs) if(--*(_s->refs) <= 0) { really_free_short_svalue(_s,_t); } DO_IF_DMALLOC(_s->refs=(void *)-1;) }while(0)
#define add_ref_svalue(X) do { struct svalue *_tmp=(X); check_type(_tmp->type); check_refs(_tmp); if(_tmp->type <= MAX_REF_TYPE) { debug_malloc_touch(_tmp->u.refs); _tmp->u.refs[0]++; } }while(0)
#define assign_svalue_no_free(X,Y) do { struct svalue _tmp, *_to=(X), *_from=(Y); check_type(_from->type); check_refs(_from);  *_to=_tmp=*_from; if(_tmp.type <= MAX_REF_TYPE) { debug_malloc_touch(_tmp.u.refs); _tmp.u.refs[0]++; } }while(0)
#define assign_svalue(X,Y) do { struct svalue *_to2=(X), *_from2=(Y); free_svalue(_to2); assign_svalue_no_free(_to2, _from2);  }while(0)

extern struct svalue dest_ob_zero;

#ifdef DEBUG_MALLOC
#define free_svalues(X,Y,Z) debug_free_svalues((X),(Y),(Z), DMALLOC_LOCATION())
#else
#define free_svalues(X,Y,Z) debug_free_svalues((X),(Y),(Z))
#endif

/* Prototypes begin here */
void really_free_short_svalue(union anything *s, TYPE_T type);
void really_free_svalue(struct svalue *s);
void do_free_svalue(struct svalue *s);
void debug_free_svalues(struct svalue *s,INT32 num, INT32 type_hint DMALLOC_LINE_ARGS);
void assign_svalues_no_free(struct svalue *to,
			    struct svalue *from,
			    INT32 num,
			    INT32 type_hint);
void assign_svalues(struct svalue *to,
		    struct svalue *from,
		    INT32 num,
		    TYPE_FIELD types);
void assign_to_short_svalue(union anything *u,
			    TYPE_T type,
			    struct svalue *s);
void assign_to_short_svalue_no_free(union anything *u,
				    TYPE_T type,
				    struct svalue *s);
void assign_from_short_svalue_no_free(struct svalue *s,
				      union anything *u,
				      TYPE_T type);
void assign_short_svalue_no_free(union anything *to,
				 union anything *from,
				 TYPE_T type);
void assign_short_svalue(union anything *to,
			 union anything *from,
			 TYPE_T type);
unsigned INT32 hash_svalue(struct svalue *s);
int svalue_is_true(struct svalue *s);
int is_identical(struct svalue *a, struct svalue *b);
int is_eq(struct svalue *a, struct svalue *b);
int low_is_equal(struct svalue *a,
		 struct svalue *b,
		 struct processing *p);
int low_short_is_equal(const union anything *a,
		       const union anything *b,
		       TYPE_T type,
		       struct processing *p);
int is_equal(struct svalue *a,struct svalue *b);
int is_lt(struct svalue *a,struct svalue *b);
void describe_svalue(struct svalue *s,int indent,struct processing *p);
void print_svalue (FILE *out, struct svalue *s);
void clear_svalues(struct svalue *s, INT32 num);
void clear_svalues_undefined(struct svalue *s, INT32 num);
void copy_svalues_recursively_no_free(struct svalue *to,
				      struct svalue *from,
				      INT32 num,
				      struct processing *p);
void check_short_svalue(union anything *u, TYPE_T type);
void debug_check_svalue(struct svalue *s);
void real_gc_xmark_svalues(struct svalue *s, int num);
TYPE_FIELD real_gc_check_svalues(struct svalue *s, int num);
void real_gc_check_short_svalue(union anything *u, TYPE_T type);
TYPE_FIELD gc_check_weak_svalues(struct svalue *s, int num);
void gc_check_weak_short_svalue(union anything *u, TYPE_T type);
void real_gc_mark_svalues(struct svalue *s, int num);
void real_gc_mark_short_svalue(union anything *u, TYPE_T type);
TYPE_FIELD gc_mark_weak_svalues(struct svalue *s, int num);
int gc_mark_weak_short_svalue(union anything *u, TYPE_T type);
void real_gc_cycle_check_svalues(struct svalue *s, int num);
void real_gc_cycle_check_short_svalue(union anything *u, TYPE_T type);
TYPE_FIELD gc_cycle_check_weak_svalues(struct svalue *s, int num);
int gc_cycle_check_weak_short_svalue(union anything *u, TYPE_T type);
INT32 pike_sizeof(struct svalue *s);
/* Prototypes end here */

#define gc_xmark_svalues(S,N) real_gc_xmark_svalues(debug_malloc_pass(&(struct svalue) *(S)),N)
#define gc_check_svalues(S,N) real_gc_check_svalues(debug_malloc_pass(&(struct svalue) *(S)),N)
#define gc_check_short_svalue(U,T) real_gc_check_short_svalue(debug_malloc_pass(&(union anything) *(U)),T)
#define gc_mark_svalues(S,N) real_gc_mark_svalues(debug_malloc_pass(&(struct svalue) *(S)),N)
#define gc_mark_short_svalue(U,T) real_gc_mark_short_svalue(debug_malloc_pass(&(union anything) *(U)),T)
#define gc_cycle_check_svalues(S,N) real_gc_cycle_check_svalues(debug_malloc_pass(&(struct svalue) *(S)),N)
#define gc_cycle_check_short_svalue(U,T) real_gc_cycle_check_short_svalue(debug_malloc_pass(&(union anything) *(U)),T)

#ifndef NO_PIKE_SHORTHAND

#define T_ARRAY    PIKE_T_ARRAY
#define T_MAPPING  PIKE_T_MAPPING
#define T_MULTISET PIKE_T_MULTISET
#define T_OBJECT   PIKE_T_OBJECT
#define T_FUNCTION PIKE_T_FUNCTION
#define T_PROGRAM  PIKE_T_PROGRAM
#define T_STRING   PIKE_T_STRING
#define T_TYPE     PIKE_T_TYPE
#define T_FLOAT    PIKE_T_FLOAT
#define T_INT      PIKE_T_INT

#define T_ZERO	   PIKE_T_ZERO

#define T_TUPLE	   PIKE_T_TUPLE
#define T_SCOPE	   PIKE_T_SCOPE

#endif /* !NO_PIKE_SHORTHAND */


#endif /* !SVALUE_H */
