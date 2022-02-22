     *>this does math with the tokens. once parentheses are gona, that is.
       identification division.
       program-id. calculate.
       environment division.

       data division.
       working-storage section.
         01 i usage binary-long value 0.
         01 j usage binary-long value 0.
         01 d usage binary-long.
         01 temp_counter usage binary-long value 0.
         01 temp_list.
           03 temp_token_type pic x(1) synchronized occurs 2000 times.
           03 temp_numslist occurs 2000 times.
             05 temp_num usage pointer synchronized.
             05 padding5 pic x(100) synchronized.
       linkage section.
         01 token_list.
           03 token_type pic x(1) value ';' synchronized occurs 2000 times.
           03 numberslist occurs 2000 times.
             05 num usage pointer synchronized.
             05 padding1 pic x(100) synchronized.

       01 outdata.
         05 outnumber usage pointer synchronized.
         05 padding3 pic x(100).
         
       01 c_communication pic x(2000).
       01 passed pic x(1) value 'F'.
       
       01 pointers.
         03 plcounter usage binary-long value 0.
         03 pointerlist occurs 20000 times.
           05 pointerdata usage pointer synchronized.
           05 pointerpadding pic x(100) synchronized.

       procedure division
               using by reference token_list, outdata, c_communication,
                                  passed, pointers.
         *> clear variables.
         perform varying i from 1 by 1 until i = 2000
           string ';' into temp_token_type(i)
           call 'mpfr_init2' using by reference temp_num(i) by value 256 returning nothing
           add 1 to plcounter giving plcounter
           move temp_numslist(i) to pointerlist(plcounter)
         end-perform
         *> first, go through and multiply/divide.
         move 1 to temp_counter
         perform varying i from 2 by 1 until token_type(i) = ';'
           if token_type(i) = '+' or token_type(i) = '-' or
           token_type(i) = '*' or token_type(i) = '/' then
             move i to j
             subtract 1 from j giving j
             if token_type(j) <> 'N' then
               string z"Error: Multiple operators in a row." into c_communication
               exit section
             end-if
           end-if
           if token_type(i) = '+' then
             move outdata to temp_numslist(temp_counter)
             string 'N' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string '+' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string 'N' into temp_token_type(temp_counter)
             add 1 to i giving i
             move numberslist(i) to outdata
             exit perform cycle
           else if token_type(i) = '-' then
             move outdata to temp_numslist(temp_counter)
             string 'N' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string '-' into temp_token_type(temp_counter)
             add 1 to temp_counter giving temp_counter
             string 'N' into temp_token_type(temp_counter)
             add 1 to i giving i
             move numberslist(i) to outdata
             exit perform cycle
           else if token_type(i) = '*' then
             add 1 to i giving i
             call 'mpfr_mul' using outnumber outnumber numberslist(i) by value 0 returning nothing
             exit perform cycle
           else if token_type(i) = '/' then
             add 1 to i giving i
             call 'mpfr_cmp_si' using numberslist(i) by value 0 returning j
             if j = 0 then
               string z"Error: divide by zero." into c_communication
               string 'F' into passed
               exit section
             end-if
             call 'mpfr_div' using outnumber outnumber numberslist(i) by value 0 returning nothing
             exit perform cycle
           else if token_type(i) = ';' then
             exit perform
           end-if
         end-perform

         move outdata to temp_numslist(temp_counter)
         string 'N' into temp_token_type(temp_counter)
         add 1 to temp_counter giving temp_counter
         string ';' into temp_token_type(temp_counter)
         *> now for addition and subtraction.
         move temp_numslist(1) to outdata
          perform varying i from 2 by 1 until temp_token_type(i) = ';'
           if temp_token_type(i) = '+' then
             add 1 to i giving i
             call 'mpfr_add' using outnumber outnumber temp_numslist(i) by value 0 returning nothing
             exit perform cycle
           else if temp_token_type(i) = '-' then
             add 1 to i giving i
             call 'mpfr_sub' using outnumber outnumber temp_numslist(i) by value 0 returning nothing
             exit perform cycle
           else if temp_token_type(i) = ';' then
             exit perform
           end-if
         end-perform
         string 'T' into passed
         exit program.
