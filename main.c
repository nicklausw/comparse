#include <concord/discord.h>
#include <mpfr.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern void mathParse(char*);

void on_ready(struct discord *client) 
{
  const struct discord_user *bot = discord_get_self(client);
  log_info("Logged in as %s!", bot->username);
}

void do_math(struct discord *client, const struct discord_message *msg)
{
  if (msg->author->bot) return;
  if(!strlen(msg->content)) return;

  char *s = calloc(2000, 1);

  strcpy(s, msg->content);

  // append a semicolon so you don't have to.
  strcat(s, ";");

  mathParse(s);

  struct discord_create_message params = { .content = s };
  discord_create_message(client, msg->channel_id, &params, NULL);
  free(s);
}

int main(int argc, char **argv)
{
  if(argc != 2) {
    printf("wrong number of args\n");
    return 1;
  }
  
  struct discord *client = discord_init(argv[1]);
  discord_set_on_ready(client, &on_ready);
  discord_set_on_command(client, "domath", &do_math);
  discord_set_on_command(client, "Domath", &do_math);
  discord_set_on_command(client, "DoMath", &do_math);
  discord_run(client);
  return 0;
}
