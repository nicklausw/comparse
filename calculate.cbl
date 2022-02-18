     *>this does math with the tokens. once parentheses are gona, that is.
       identification division.
       program-id. calculate.
       environment division.

       data division.
       working-storage section.
       01 i pic 9(9) value 0.
       linkage section.
         01 token_list.
           05 token_type pic x(1) occurs 2000 times.
           05 num pic s9(9)v9(9) occurs 2000 times.
         01 current_token pic 9(9).
       

         01 outnumber pic s9(9)v9(9).

       procedure division using by reference token_list, outnumber.
         move 2 to i
         perform varying i from 2 by 1 until token_type(i) = ';'
           if token_type(i) = '+' then
             add 1 to i giving i
             add num(i) to outnumber giving outnumber
             exit perform cycle
           else if token_type(i) = '-' then
             add 1 to i giving i
             subtract num(i) from outnumber giving outnumber
             exit perform cycle
           else if token_type(i) = '*' then
             add 1 to i giving i
             multiply num(i) by outnumber giving outnumber
             exit perform cycle
           else if token_type(i) = '/' then
             add 1 to i giving i
             divide outnumber by num(i) giving outnumber
             exit perform cycle
           else if token_type(i) = ';' then
             exit perform
           end-if
         end-perform
         exit program.
