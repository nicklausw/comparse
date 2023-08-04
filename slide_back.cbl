     *>As the calculation is done, we want the formula to get smaller, obviously.
     *>When you turn A+B+C into D+C, this is what gets rid of that +B in memory.
       identification division.
       program-id. slide_back.
       environment division.

       data division.
       working-storage section.
         01 place usage binary-long value 0.

       linkage section.
         01 token_list.
           03 token_type pic x(1) value ';' synchronized occurs 2000 times.
           03 numberslist occurs 2000 times.
             05 num usage pointer synchronized.
             05 padding1 pic x(32) synchronized.
         01 i usage binary-long.

       procedure division using token_list, i.

         perform varying place from i by 2 until token_type(place + 2) = ';'
           move token_type(place + 4) to token_type(place + 2)
           move token_type(place + 3) to token_type(place + 1)
           call 'mpfr_clear' using numberslist(place + 2)
           move numberslist(place + 4) to numberslist(place + 2)
           call 'mpfr_init2' using numberslist(place + 4), by value 4984
         end-perform.