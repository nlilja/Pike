/* imap_server.pike
 *
 * $Id: imap_server.pike,v 1.13 1999/02/13 18:04:05 grubba Exp $
 */

constant unauth_commands =
([ "noop" : .requests.noop,
   "capability" : .requests.capability,
   "logout" : .requests.logout,
   "login" : .requests.login,
   "authenticate" : .requests.authenticate
]);

constant auth_commands =
([ "noop" : .requests.noop,
   "logout" : .requests.logout,
   "capability" : .requests.capability,
   "select" : .requests.select,
   "examine" : .requests.examine,
   "create" : .requests.create_mailbox,
   "delete" : .requests.delete,
   "rename" : .requests.rename,
   "subscribe" : .requests.subscribe,
   "unsubscribe" : .requests.unsubscribe,
   "list" : .requests.list,
   "lsub" : .requests.lsub,
   "status" : .requests.status,
   "append" : .requests.append
]);

constant select_commands =
([ "noop" : .requests.noop,
   "logout" : .requests.logout,
   "capability" : .requests.capability,
   "select" : .requests.select,
   "examine" : .requests.examine,
   "create" : .requests.create_mailbox,
   "delete" : .requests.delete,
   "rename" : .requests.rename,
   "subscribe" : .requests.subscribe,
   "unsubscribe" : .requests.unsubscribe,
   "list" : .requests.list,
   "lsub" : .requests.lsub,
   "status" : .requests.status,
   "append" : .requests.append,
   "check" : .requests.check,
   "close" : .requests.close,
   "expunge" : .requests.expunge,
   "search" : .requests.search,
   "fetch" : .requests.fetch,
   "store" : .requests.store,
   "copy" : .requests.copy,
   "uid" : .requests.uid
]);

constant all_commands = unauth_commands | auth_commands | select_commands;

class connection
{
  object io;  // Protocol object 

  object db; /* Mail backend */

  mapping session = ([]); /* State information about this ession; primarily
			   * uid and mailboxid. */

  // object current_request;

  class get_line
  {
    function handler;

    void create(function h)
      {
	handler = h;
      }

    void `()(object line)
      {
	next_action(handler(line));
      }
  }

  class get_literal
  {
    function handler;

    void create(function h)
      {
	handler = h;
      }

    void `()(string s)
      {
	next_action(handler(s));
      }
  }
  
  void show_backtrace(mixed e)
    {
      werror(describe_backtrace(e));
    }

  void next_action(mapping action)
    {
      switch(action->action)
      {
      case "close":
	/* Close connection */
	io->close_imap();
      case "bad":
	io->send_bad_response(action->tag,
			      action->msg || "Invalid request");
	/* Fall through */
      case "finished":
	/* Finished processing this request. Remain in the same state. */
	io->get_request();
	break;
      case "expect_line":
	/* Callback for next line recieved */
	io->get_line(get_line(action->handler));
	break;
      case "expect_literal":
	/* Callback for recieving a literal */
	io->send_imap("+", action->msg || "Ready");
	io->get_literal(action->length, get_literal(action->handler));
	break;
      case "logged_in_state":
	io->use_commands(auth_commands);
	break;
      case "selected_state":
	io->use_commands(select_commands);
	break;
      default:
	throw( ({ sprintf("IMAP.pmod: Internal error, action = %O\n",
			  action), backtrace() }) );
      }
    }
  
  void handle_request(object(.requests.request) req)
    {
      mapping action;
      
      mixed e;
      if (e = catch(action = req->process(session, db, io->send_imap)))
	{
	  show_backtrace(e);
	  io->send_bad_response(req->tag, "Internal error");
	  return;
	}
      next_action(action);
    }

  void create(object f, int timeout, object backend,
	      mapping preauth, int|void debug)
    {
      io = .server(f, timeout, handle_request, debug);
      db = backend;

      if (preauth)
      {
	session = preauth->session;
	io->use_commands(auth_commands);

	io->send_imap("*", "PREAUTH", "IMAP4rev1", preauth->message);
      } else {
	io->use_commands(unauth_commands);
	io->send_imap("*", "OK", "IMAP4", "IMAP4rev1", "Service ready");
      }
    }
}

object db;

int debug_level;
int timeout;

object port;

void accept_callback(mixed id)
{
  if (debug_level)
    werror("IMAP accept\n");

  object f = port->accept();
  if (f)
    connection(f, timeout, db, 0, debug_level);
}

void create(object p, int portnr, int t, object server, int|void debug)
{
  port = p;
  timeout = t;
  db = server;
  debug_level = debug;

  if (!port->bind(portnr, accept_callback))
    throw( ({ "IMAP.imap_server->create: bind failed (port already bound?)\n",
              backtrace() }) );
  if (debug_level)
    werror("IMAP: Bound to port %d\n", portnr);
}

void close()
{
  if (port)
    destruct(port);
}
