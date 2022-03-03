#include <concord/discord.h>
#include <mpfr.h>
#include <libcob.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

extern void *mathParse(char*);

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

void test_math(struct discord *client, const struct discord_message *msg) {
  int precision = atoi(msg->content);
  char numberstring[] = "9999999999999999999999999999999999999999999999999999999";
  mpfr_t num, othernum;
  mpfr_init2(num, precision);
  mpfr_init2(othernum, precision);
  mpfr_set_str(num, numberstring, 10, 0);
  mpfr_set_str(othernum, numberstring, 10, 0);
  for(int i = 0; i < 10; i++) {
    mpfr_mul(num, num, othernum, 0);
  }
  mpfr_printf("PRECISION: %d\n\n%Rf\n\n",precision,num);
  mpfr_clear(num);
  mpfr_clear(othernum);
}

void do_math(struct discord *client, const struct discord_message *msg)
{
  if (msg->author->bot) return;
  char *s = malloc(2000);

  // make sure input has no garbage.
  for(int c = 0; c < 2000; c++) {
    s[c] = '\0';
  }
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
  discord_set_on_command(client, "DoMath", &do_math);
  discord_set_on_command(client, "testmath", &test_math);
  discord_set_on_command(client, "TestMath", &test_math);
  discord_run(client);
  return 0;
}
