# comparse: CObol Math PARSE
This is a math parser written in gnuCOBOL for fun. It interfaces with the [Concord library](https://github.com/Cogmasters/concord/tree/dev) to take in statements via Discord.

## why?
To satisfy my own curiosity, and hopefully yours aswell. Writing a math parser is easy; writing one in a language based around tons of random keywords that the entire industry gave up on is a different story. Want to hire me to work on your COBOL project? I'd love to help! [Hit me up.](https://www.nicklausw.com/contact)

## aren't these lines a bit long for COBOL?
gnuCOBOL offers two modes for reading lines: free mode and fixed mode. Fixed mode is based off the design of a punch card, with the first 6 columns kept empty, the ridiculously short cutoff point, and so on. Free mode has fewer constraints and allows each line to go up to 255 characters. I'm using free mode for my sanity.

## will you redo the discord stuff in COBOL?
Nah. That strays slightly too far from the purpose of the language, keeping in mind that it was invented 2 decades before the internet. Besides, Concord is a wonderful library. Why would I stop using it?