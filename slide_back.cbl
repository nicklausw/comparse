     *>As the calculation is done, we want the formula to get smaller, obviously.
     *>When you turn A+B+C into D+C, this is what gets rid of that +B in memory.
       identification division.
       program-id. slide_back.
       environment division.

       data division.
       working-storage section.
         01 i usage binary-long value 0.

       linkage section.
         01 token_list.
           03 token_type pic x(1) value ';' synchronized occurs 2000 times.
           03 numberslist occurs 2000 times.
             05 num usage pointer synchronized.
             05 mpfr_padding pic x(32) synchronized.
         01 place usage binary-long.

       procedure division using token_list, place.

         perform varying i from place by 2 until token_type(i + 2) = ';'
           move token_type(i + 4) to token_type(i + 2)
           move token_type(i + 3) to token_type(i + 1)
           call 'mpfr_clear' using numberslist(i + 2)
           move numberslist(i + 4) to numberslist(i + 2)
           call 'mpfr_init2' using numberslist(i + 4), by value 4984
         end-perform.