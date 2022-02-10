#include <orca/discord.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>

extern int doublenumber(cob_u32_t*);

void on_ready(struct discord *client) 
{
  const struct discord_user *bot = discord_get_self(client);
  log_info("Logged in as %s!", bot->username);
}

void on_message(struct discord *client, const struct discord_message *msg)
{
  if (msg->author->bot) return;

  int number = atoi(msg->content);

  /* call the static module and store its return code */
  char out[500] = "";
  sprintf(out, "%d", doublenumber(&number));

  discord_async_next(client, NULL); // make next request non-blocking (OPTIONAL)
  struct discord_create_message_params params = { .content = out };
  discord_create_message(client, msg->channel_id, &params, NULL);
}

int main(void)
{
  /* initialize the COBOL run-time library */
  cob_init(0, NULL);
  
  struct discord *client = discord_init(BOT_TOKEN);
  discord_set_on_ready(client, &on_ready);
  discord_set_on_message_create(client, &on_message);
  discord_run(client);

  /* shutdown the COBOL run-time library, keep program running */
  (void)cob_tidy();

  return 0;
}