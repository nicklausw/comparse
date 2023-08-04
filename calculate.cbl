     *>this does math with the tokens. once parentheses are gona, that is.
       identification division.
       program-id. calculate.
       environment division.

       data division.
       working-storage section.
         01 i usage binary-long value 0.
         01 j usage binary-long.

       linkage section.
         01 token_list.
           03 token_type pic x(1) value ';' occurs 2000 times.
           03 numbers_list occurs 2000 times.
             05 num usage pointer.
             05 mpfr_padding pic x(32).
         
       01 c_communication pic x(2000).
       01 passed pic x(1) value 'F'.

       procedure division using token_list, c_communication, passed.

         *> check for errors
         perform varying i from 2 by 2 until token_type(i) = ';'
           if token_type(i) = '+' or token_type(i) = '-' or
           token_type(i) = '*' or token_type(i) = '/' or
           token_type(i) = '^' then
             if token_type(i - 1) <> 'N' then
               string z"Error: Multiple operators in a row." into c_communication
               string "F" into passed
               exit program
             end-if
             if token_type(i + 1) <> 'N' then
               string z"Error: Multiple operators in a row." into c_communication
               string "F" into passed
               exit program
             end-if
           end-if
         end-perform

         *> first, exponents.
         perform varying i from 2 by 1 until token_type(i) = ';'
           if token_type(i) = '^' then
             call 'mpfr_pow' using numbers_list(i - 1), numbers_list(i - 1), numbers_list(i + 1), by value 0
             subtract 1 from i
             call 'slide_back' using token_list, i
             exit perform cycle
           else
             add 1 to i
           end-if
         end-perform

         *> next, go through and multiply/divide.
         perform varying i from 2 by 1 until token_type(i) = ';'
           if token_type(i) = '*' then
             call 'mpfr_mul' using numbers_list(i - 1), numbers_list(i - 1), numbers_list(i + 1), by value 0
             subtract 1 from i
             call 'slide_back' using token_list, i
             exit perform cycle
           else if token_type(i) = '/' then
             call 'mpfr_cmp_si' using numbers_list(i + 1), by value 0 returning j
             if j = 0 then
               string z"Error: divide by zero." into c_communication
               string 'F' into passed
               exit program
             end-if
             
             call 'mpfr_div' using numbers_list(i - 1), numbers_list(i - 1), numbers_list(i + 1), by value 0
             subtract 1 from i
             call 'slide_back' using token_list, i
             exit perform cycle
           else
             add 1 to i
           end-if
         end-perform

         *> now for addition and subtraction.
          perform varying i from 2 by 1 until token_type(i) = ';'
           if token_type(i) = '+' then
             call 'mpfr_add' using numbers_list(i - 1), numbers_list(i - 1), numbers_list(i + 1), by value 0
             subtract 1 from i
             call 'slide_back' using token_list, i
             exit perform cycle
           else if token_type(i) = '-' then
             call 'mpfr_sub' using numbers_list(i - 1), numbers_list(i - 1), numbers_list(i + 1), by value 0
             subtract 1 from i
             call 'slide_back' using token_list, i
             exit perform cycle
           end-if
         end-perform
         string 'T' into passed.
