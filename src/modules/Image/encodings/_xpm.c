#include "global.h"
RCSID("$Id: _xpm.c,v 1.3 1999/04/09 04:11:36 per Exp $");

#include "config.h"

#include "interpret.h"
#include "svalue.h"
#include "pike_macros.h"
#include "object.h"
#include "program.h"
#include "array.h"
#include "error.h"
#include "constants.h"
#include "mapping.h"
#include "stralloc.h"
#include "multiset.h"
#include "pike_types.h"
#include "rusage.h"
#include "operators.h"
#include "fsort.h"
#include "callback.h"
#include "gc.h"
#include "backend.h"
#include "main.h"
#include "pike_memory.h"
#include "threads.h"
#include "time_stuff.h"
#include "version.h"
#include "encode.h"
#include "module_support.h"
#include "module.h"
#include "opcodes.h"
#include "cyclic.h"
#include "signal_handler.h"
#include "security.h"


#include "image.h"
#include "colortable.h"

extern struct program *image_program;

static int hextoint( int what )
{
  if(what >= '0' && what <= '9')
    return what-'0';
  if(what >= 'a' && what <= 'f')
    return 10+what-'a';
  if(what >= 'A' && what <= 'F')
    return 10+what-'A';
  return 0;
}

struct buffer
{
  int len;
  char *str;
};

static rgba_group decode_color( struct buffer *s )
{
  static struct svalue _parse_color;
  static struct svalue *parse_color;
  rgba_group res;
  res.alpha = 255;

  if(!s->len)
  {
    res.r=res.g=res.b = 0;
    return res;
  }
  if(s->str[0] == '#' && s->len>3)
  {
    switch(s->len)
    {
     default:
       res.r = hextoint(s->str[1])*0x10;
       res.g = hextoint(s->str[2])*0x10;
       res.b = hextoint(s->str[3])*0x10;
       break;
     case 7:
       res.r = hextoint(s->str[1])*0x10 + hextoint(s->str[2]);
       res.g = hextoint(s->str[3])*0x10 + hextoint(s->str[4]);
       res.b = hextoint(s->str[5])*0x10 + hextoint(s->str[6]);
       break;
     case 13:
       res.r = hextoint(s->str[1])*0x10 + hextoint(s->str[2]);
       res.g = hextoint(s->str[5])*0x10 + hextoint(s->str[6]);
       res.b = hextoint(s->str[9])*0x10 + hextoint(s->str[10]);
       break;
    }
    return res;
  }
  if(!parse_color)
  {
    push_text("Image");
    push_int(0);
    SAFE_APPLY_MASTER( "resolv", 2 );
    if(IS_ZERO(sp-1)) error("Internal error: No Image module!\n");
    push_text("`[]");
    f_index(2);
    if(IS_ZERO(sp-1)) error("Internal error: No Image[] function!\n");
    _parse_color = sp[-1];
    parse_color = &_parse_color;
    sp--;
  }
  push_string(make_shared_binary_string(s->str,s->len));
  apply_svalue( parse_color, 1 );
  push_text( "array" );
  apply( sp[-2].u.object, "cast", 1 );
  if(sp[-1].type == T_ARRAY && sp[-1].u.array->size == 3)
  {
    res.r = sp[-1].u.array->item[0].u.integer;
    res.g = sp[-1].u.array->item[1].u.integer;
    res.b = sp[-1].u.array->item[2].u.integer;
  } else {
    res.r = res.g = res.b = 0;
  }
  pop_stack(); /* array */
  pop_stack(); /* object */
  return res;
}


static rgba_group parse_color_line( struct pike_string *cn, int sl )
{
  int toggle = 0;
  int i;
  rgba_group res;
  for(i=sl; i<cn->len; i++)
  {
    switch(cn->str[i])
    {
     case ' ':
     case '\t':
       if(toggle)
       {
         struct buffer s;
         s.str = cn->str+i+1;
         s.len = cn->len-i-1;
         return decode_color(&s);
       }
     default:
       toggle=1;
    }
  }
  res.r = res.g = res.b = 0;
  res.alpha = 255;
  return res;
}

static rgba_group qsearch( char *s,int sl, struct array *c )
{
  int start = c->size/2;
  int lower = 0;
  int upper = c->size-1;
  struct pike_string *cn;
  while( 1 )
  {
    int i, ok=1;
    cn = c->item[start].u.string;
    for(i=0; i<sl; i++)
      if(cn->str[i] < s[i])
      {
        lower = start;
        start += (upper-start)/2;
        ok=0;
        break;
      } else if(cn->str[i] > s[i]) {
        upper = start;
        start -= (start-lower)/2;
        ok=0;
        break;
      }

    if(ok)
      return parse_color_line( cn,sl );
    if(upper-lower < 2)
    {
      rgba_group res;
      res.r = res.g = res.b = 0;
      res.alpha = 0;
      return res;
    }
  }
}

void f__xpm_write_rows(  INT32 args )
{
  struct object *img;
  struct object *alpha;
  struct array *pixels;
  struct array *colors;
  struct image *iimg, *ialpha;
  rgb_group *dst, *adst;
  int y,x,  bpc;

  get_all_args("_xpm_write_rows",args,"%o%o%d%a%a",
               &img,&alpha,&bpc,&colors,&pixels);

  iimg = (struct image *)get_storage( img, image_program );
  ialpha = (struct image *)get_storage( alpha, image_program );
  if(!iimg || !ialpha)
    error("Sluta pilla p� interna saker..\n");

  dst = iimg->img;
  adst = ialpha->img;


  switch(bpc)
  {
   default:
    for(y = 0; y<iimg->ysize; y++)
    {
      char *ss = (char *)pixels->item[y+colors->size+1].u.string->str;
      for(x = 0; x<iimg->xsize; x++)
      {
        rgba_group color=qsearch(ss,bpc,colors);  ss+=bpc;
        dst->r = color.r;
        dst->g = color.g;
        (dst++)->b = color.b;
        if(!color.alpha)
          adst->r = adst->g = adst->b = color.alpha;
        adst++;
      }
    }
    break;
   case 2:
   {
     rgba_group p_colors[65536];
     int i;

     for(i=0; i<colors->size; i++)
     {
       short id = *((short *)colors->item[i].u.string->str);
       p_colors[id] = parse_color_line( colors->item[i].u.string, bpc );
     }
     for(y = 0; y<iimg->ysize; y++)
     {
       char *ss = (char *)pixels->item[y+colors->size+1].u.string->str;
       for(x = 0; x<iimg->xsize; x++)
       {
         rgba_group color=p_colors[*((short *)ss)];
         dst->r = color.r;
         dst->g = color.g;
         (dst++)->b = color.b;
         if(!color.alpha)
           adst->r = adst->g = adst->b = 0;
         ss+=bpc;
         adst++;
       }
     }
     break;
   }
   case 1:
   {
     rgba_group p_colors[256];
     int i;

     for(i=0; i<colors->size; i++)
     {
       unsigned char id = *((unsigned char *)colors->item[i].u.string->str);
       p_colors[id] = parse_color_line( colors->item[i].u.string, bpc );
     }
     for(y = 0; y<iimg->ysize; y++)
     {
       char *ss=(unsigned char *)pixels->item[y+colors->size+1].u.string->str;
       for(x = 0; x<iimg->xsize; x++)
       {
         rgba_group color=p_colors[*((short *)ss)];
         dst->r = color.r;
         dst->g = color.g;
         (dst++)->b = color.b;
         if(!color.alpha)
           adst->r = adst->g = adst->b = 0;
         ss+=bpc;
         adst++;
       }
     }
     break;
   }
  }
  pop_n_elems(args);
  push_int(0);
}

void f__xpm_trim_rows( INT32 args )
{
  struct array *a;
  int i,j=0;
  get_all_args("___", args, "%a", &a );
  for(i=0; i<a->size; i++)
  {
    char *ns;
    int len,start;
    struct pike_string *s = a->item[i].u.string;
    if(s->len > 4)
    {
      for(start=0; start<s->len; start++)
        if(s->str[start] == '/' || s->str[start] == '"')
          break;
      if(s->str[start] == '/')
        continue;
      for(len=start+1; len<s->len; len++)
        if(s->str[len] == '"')
          break;
      if(len>=s->len || s->str[len] != '"')
        continue;
      a->item[j].u.string=make_shared_binary_string(s->str+start+1,len-start-1);
      free_string(s);
      j++;
    }
  }
}

static struct program *image_encoding__xpm_program=NULL;
void init_image__xpm( )
{
  start_new_program();
   add_function( "_xpm_write_rows", f__xpm_write_rows, "mixed", 0); 
  add_function( "_xpm_trim_rows", f__xpm_trim_rows, "mixed", 0);
  image_encoding__xpm_program=end_program();

  push_object(clone_object(image_encoding__xpm_program,0));
  {
    struct pike_string *s=make_shared_string("_XPM");
    add_constant(s,sp-1,0);
    free_string(s);
  }
}

void exit_image__xpm(void)
{
  if(image_encoding__xpm_program)
  {
    free_program(image_encoding__xpm_program);
    image_encoding__xpm_program=0;
  }
}
