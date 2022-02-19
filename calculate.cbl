     *>this does math with the tokens. once parentheses are gona, that is.
       identification division.
       program-id. calculate.
       environment division.

       data division.
       working-storage section.
         01 i usage binary-long value 0.
         01 j usage binary-long value 0.
         01 temp_counter usage binary-long value 0.
         01 temp_list.
           05 temp_token_type pic x(1) occurs 2000 times.
           05 temp_num float-long occurs 2000 times.
       linkage section.
         01 token_list.
           05 token_type pic x(1) occurs 2000 times.
           05 num usage float-long occurs 2000 times.

       01 outnumber usage float-long.
       01 c_communication pic x(2000).
       01 passed pic x(1) value 'F'.

       procedure division
       using by reference token_list, outnumber, c_communication, passed.
         *> clear variables.
         perform varying i from 1 by 1 until i = 2000
           string ';' into temp_token_type(i)
           move 0 to temp_num(i)
         end-perform
         *> first, go through and multiply/divide.
         move 1 to temp_counter
         perform varying i from 2 by 1 until token_type(i) = ';'
           if token_type(i) = '+' or token_type(i) = '-' or
           token_type(i) = '*' or token_type(i) = '/' then
             move i to j
             subtract 1 from j giving j
             if token_type(j) <> 'N' then
               string "Error: Multiple operators in a row.\" into c_communication
               exit section
             end-if
           end-if
           if token_type(i) = '+' then
             move outnumber to temp_num(temp_counter)
             string 'N' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string '+' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string 'N' into temp_token_type(temp_counter)
             add 1 to i giving i
             move num(i) to outnumber
             exit perform cycle
           else if token_type(i) = '-' then
             move outnumber to temp_num(temp_counter)
             string 'N' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string '-' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string 'N' into temp_token_type(temp_counter)
             add 1 to i giving i
             move num(i) to outnumber
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

         move outnumber to temp_num(temp_counter)
         string 'N' into temp_token_type(temp_counter)
         add 1 to temp_counter giving temp_counter
         string ';' into temp_token_type(temp_counter)
         *> now for addition and subtraction.
         move temp_num(1) to outnumber
          perform varying i from 2 by 1 until temp_token_type(i) = ';'
           if temp_token_type(i) = '+' then
             add 1 to i giving i
             add temp_num(i) to outnumber giving outnumber
             exit perform cycle
           else if temp_token_type(i) = '-' then
             add 1 to i giving i
             subtract temp_num(i) from outnumber giving outnumber  
             exit perform cycle
           else if temp_token_type(i) = ';' then
             exit perform
           end-if
         end-perform
         string 'T' into passed 
         exit program.
