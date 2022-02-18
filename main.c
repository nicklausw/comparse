#include <orca/discord.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

extern char *mathParse(char*);

void on_ready(struct discord *client) 
{
  const struct discord_user *bot = discord_get_self(client);
  log_info("Logged in as %s!", bot->username);
}

void on_message(struct discord *client, const struct discord_message *msg)
{
  if (msg->author->bot) return;

  int number = atoi(msg->content);

  // make sure input has no garbage.
  char s[2000];
  for(int c = 0; c < 2000; c++) {
    s[c] = '\0';
  }
  strcpy(s, msg->content);
  
  mathParse(s);

  // output can also have garbage.
  for(int c = 0; c < 2000; c++) {
    if(s[c] == '\\') {
      s[c] = '\0';
      break;
    }
  }
  
  bool isNumber = true;
  for(int c = 1; c < strlen(s); c++) {
    if(!isdigit(s[c])) {
      isNumber = false;
      break;
    }
  }
  
  if(isNumber == true) {
    char newOutput[20];
    for(int c = 0; c < 20; c++) {
      if(c == 9) {
	newOutput[c] = '.';
      } else if(c > 9) {
	newOutput[c] = s[c - 1];
      } else if(c == 19) {
	newOutput[c] = '\0';
      } else {
	newOutput[c] = s[c];
      }
    }
    sprintf(s, "%.2f", atof(newOutput));
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
  
  struct discord *client = discord_init(argv[1]);
  discord_set_on_ready(client, &on_ready);
  discord_set_on_message_create(client, &on_message);
  discord_run(client);

  return 0;
}
