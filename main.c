#include <concord/discord.h>
#include <mpfr.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

extern void *mathParse(char*,mpfr_t*);

bool startsWith(char *a, char *b)
{
  for(int c = 0; c < strlen(a); c++) {
    if(!isdigit(a[c])) {
      a[c] = tolower(a[c]);
    }
  }
  if(strncmp(a, b, strlen(b)) == 0) return 1;
  return 0;
}

void on_ready(struct discord *client) 
{
  const struct discord_user *bot = discord_get_self(client);
  log_info("Logged in as %s!", bot->username);
}

void on_message(struct discord *client, const struct discord_message *msg)
{
  if (msg->author->bot) return;
  mpfr_t *finalResult = malloc(100);
  char *s = malloc(2000);

  // make sure input has no garbage.
  for(int c = 0; c < 2000; c++) {
    s[c] = '\0';
  }
  strcpy(s, msg->content);

  if(strlen(s) < strlen("domath ") + 1) {
    return;
  }
  if(!startsWith(s, "domath ")) {
    return;
  }
  // append a semicolon so you don't have to.
  strcat(s, ";");

  memcpy(s,&s[7],strlen(s) - 7);
  mathParse(s,finalResult);
 
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
  
  struct discord *client = discord_init(argv[1]);
  discord_set_on_ready(client, &on_ready);
  discord_set_on_message_create(client, &on_message);
  discord_run(client);
  return 0;
}
