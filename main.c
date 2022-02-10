#include <orca/discord.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern char *cobolstuff(char *coolstring);

void on_ready(struct discord *client) 
{
  const struct discord_user *bot = discord_get_self(client);
  log_info("Logged in as %s!", bot->username);
}

void on_message(struct discord *client, const struct discord_message *msg)
{
  if (msg->author->bot) return;

  int number = atoi(msg->content);

  char* s;
  cobolstuff(s);
  for(int c = 0; c < strlen(s); c++) {
    // COBOL strings don't end with zero.
    // so I chose this symbol for it.
    if(s[c] == '\\') s[c] = '\0';
  }

  discord_async_next(client, NULL); // make next request non-blocking (OPTIONAL)
  struct discord_create_message_params params = { .content = s };
  discord_create_message(client, msg->channel_id, &params, NULL);
}

int main(int argc, char **argv)
{
  if(argc != 2) {
    printf("wrong number of args\n");
    return 1;
  }

  /* initialize the COBOL run-time library */
  cob_init(0, NULL);
  
  struct discord *client = discord_init(argv[1]);
  discord_set_on_ready(client, &on_ready);
  discord_set_on_message_create(client, &on_message);
  discord_run(client);

  /* shutdown the COBOL run-time library, keep program running */
  (void)cob_tidy();

  return 0;
}