#include <concord/discord.h>
#include <concord/log.h>
#include <mpfr.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern void math_parse(char*);

// case insensitive, check if a starts with b
bool starts_with(const char *a, const char *b) {
   if(strncasecmp(a, b, strlen(b)) == 0) return 1;
   return 0;
}

void on_ready(struct discord *client, const struct discord_ready *event) {
    log_info("Logged in as %s!", event->user->username);
}

void on_message(struct discord *client, const struct discord_message *msg) {
  if (msg->author->bot) return;

  if(!starts_with(msg->content, "domath ") || strlen(msg->content) <= 7) {
    return;
  }

  // subtract space taken by "domath " but let us add a semicolon if needed
  // discord messages can be up to 2000 chars long
  char *s = calloc(2000 - 7 + 1, 1);

  strcpy(s, msg->content + 7);

  // append a semicolon so you don't have to.
  // this is the end-of-statement marker for the cobol
  strcat(s, ";");

  math_parse(s);

  struct discord_create_message params = { .content = s };
  discord_create_message(client, msg->channel_id, &params, NULL);
  free(s);
}

int main(int argc, char **argv) {
  if(argc != 2) {
    printf("wrong number of args\n");
    return 1;
  }
  
  struct discord *client = discord_init(argv[1]);
  discord_add_intents(client, DISCORD_GATEWAY_MESSAGE_CONTENT);
  discord_set_on_ready(client, &on_ready);
  discord_set_on_message_create(client, &on_message);
  discord_run(client);
  return 0;
}
