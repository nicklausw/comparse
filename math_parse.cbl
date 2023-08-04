       identification division.
       program-id. math_parse.
       environment division.
     
       data division.
       working-storage section.
      *>  temp_str is giant to make sure the message fits 2000 chars.
         01 temp_str pic x(200000).
         01 math_string pic x(2000).
         01 found_parentheses usage binary-long value 1.
         01 counter usage binary-long value 0.
         01 parenthsize usage binary-long value 0.
         01 alt_pos usage binary-long value 0.
         01 i usage binary-long value 0.
         01 j usage binary-long value 0.
         01 commas usage binary-long value 0.

         01 building_number pic x(1) value 'F'.
         01 building_offset usage binary-long value 0.
         01 building_space pic x(2000) value zeroes.

         01 current_token usage binary-long value 1.

         01 token_list.
           03 token_type pic x(1) synchronized occurs 2000 times.
           03 numberslist occurs 2000 times.
             05 num usage pointer synchronized.
             05 mpfr_padding pic x(32) synchronized.
           
         01 didwefinish pic x(1) value 'F' synchronized.

         01 alt_list.
             03 alt_token_type pic x(1) synchronized occurs 2000 times.
             03 alt_numslist occurs 2000 times.
               05 alt_num usage pointer synchronized.
               05 alt_mpfr_padding pic x(32) synchronized.
     
       linkage section.
         01 c_communication pic x(2000) synchronized.
     
       procedure division using c_communication.
      *> copy input to where we can work with it piece-by-piece.
         move c_communication to math_string
         string 'F' into building_number
         string 'F' into didwefinish
         move 1 to current_token

         perform varying counter from 1 by 1 until counter = 2000
           string ';' into token_type(counter)
           call 'mpfr_init2' using num(counter), by value 4984
           string ';' into alt_token_type(counter)
           call 'mpfr_init2' using alt_num(counter), by value 4984
         end-perform

         perform varying counter from 1 by 1 until counter = 100
           string ';' into building_space(counter:1)
         end-perform

      *> end program if ending marker (semicolon) not found.
         perform varying counter from 1 by 1 until counter = 2000
           if math_string(counter:1) = ';' then
             exit perform
           end-if
         end-perform
         if counter = 2000 then
           string z"No semicolon found." into c_communication
           go to cleanup.

         move 0 to parenthsize

      *>first: split into tokens.
         perform varying counter from 1 by 1 until counter = 2000
           if math_string(counter:1) = ' ' or math_string(counter:1) = ',' then
             exit perform cycle
           else if math_string(counter:1) <> '*' and math_string(counter:1) <> '/' and
           math_string(counter:1) <> '+' and math_string(counter:1) <> '-' and
           math_string(counter:1) <> '(' and math_string(counter:1) <> ')' and
           math_string(counter:1) <> ';' and math_string(counter:1) <> '.' and
           math_string(counter:1) <> '^' and
           math_string(counter:1) is not numeric then
             string "Bad symbol: " math_string(counter:1) z"." into c_communication
             go to cleanup
           end-if
           *> if we're still getting a number's contents...
           if building_number = 'F' then
             if (math_string(counter:1) is numeric) or
              (math_string(counter:1) = '.') then
               string 'T' into building_number
               string 'N' into token_type(current_token)
               move 1 to building_offset
               move math_string(counter:1) to building_space(building_offset:1)
               add 1 to building_offset
               exit perform cycle
             else
               move math_string(counter:1) to
               token_type(current_token)
               if token_type(current_token) = ';' then
                  exit perform
               end-if

               if token_type(current_token) = ')' then
                 subtract 1 from parenthsize
                 if parenthsize < 0 then
                   string z"Parenthesis error." into c_communication
                   go to cleanup
                 end-if
                 if current_token > 1 then
                   move current_token to j
                   subtract 1 from j
                   if token_type(j) = '(' then
                     string z"Parenthesis error." into c_communication
                     go to cleanup
                   end-if
                 end-if
               end-if
              
               if token_type(current_token) = '(' then
                   add 1 to parenthsize
                 if counter > 1 then
                   subtract 1 from current_token
                   if token_type(current_token) = 'N' or token_type(current_token) = ')' then
                     *> implied multiplication
                     add 1 to current_token
                     string '*' into token_type(current_token)
                     add 1 to current_token
                     string '(' into token_type(current_token)
                   else
                     add 1 to current_token
                   end-if
                 end-if
               end-if
               add 1 to current_token
             end-if
           else
             if (math_string(counter:1) is numeric) or
              (math_string(counter:1) = '.') then
               move math_string(counter:1) to building_space(building_offset:1)
               add 1 to building_offset
             else
               string 'F' into building_number
               subtract 1 from building_offset
               string building_space(1:building_offset) x'00' into temp_str
               call 'mpfr_set_str' using num(current_token), temp_str, by value 10, 0
               add 1 to current_token
               move math_string(counter:1) to token_type(current_token)
               if token_type(current_token) = ';' then
                 exit perform
               end-if

               if token_type(current_token) = ')' then
                 subtract 1 from parenthsize
                 if parenthsize < 0 then
                   string z"Parenthesis error." into c_communication
                   go to cleanup
                 end-if
                 if current_token > 1 then
                   move current_token to j
                   subtract 1 from j
                   if token_type(j) = '(' then
                     string z"Parenthesis error." into c_communication
                     go to cleanup
                   end-if
                 end-if
               end-if
               if token_type(current_token) = '(' then
                 add 1 to parenthsize
                 if counter > 1 then
                   subtract 1 from current_token
                   if token_type(current_token) = 'N' or token_type(current_token) = ')' then
                     *> implied multiplication
                     add 1 to current_token
                     string '*' into token_type(current_token)
                     add 1 to current_token
                     string '(' into token_type(current_token)
                   else
                     add 1 to current_token
                   end-if
                 end-if
               end-if

               add 1 to current_token
             end-if
           end-if
         end-perform

         if parenthsize <> 0 then
           string z"Parenthesis error." into c_communication
           go to cleanup.

         move current_token to j
         subtract 1 from j
         if token_type(j) <> 'N' and token_type(j) <> ')' then
           string z"Can't end statement with operator." into c_communication
           go to cleanup.
         
         move 1 to j
         if token_type(j) <> 'N' and token_type(j) <> '(' then
           string z"Can't start statement with operator." into c_communication
           go to cleanup.

     *>  parentheses blocks are trouble. let's resolve them.
         move 0 to found_parentheses
         string "T" into didwefinish
         perform until found_parentheses = 1
           call 'reduce_parentheses' using alt_list, token_list,
           didwefinish, found_parentheses, c_communication
           if didwefinish <> "T" then
             go to cleanup
           end-if
         end-perform

         call 'calculate'
         using token_list, c_communication, didwefinish
         if didwefinish <> "T" then
           go to cleanup
         end-if
         call 'mpfr_sprintf' using temp_str, z"%.3Rf", numberslist(1)

         string 'T' into didwefinish


         *> get string length first.
         move 1 to j
         perform until temp_str(j:1) = x'00'
           add 1 to j
         end-perform
         
         *> subtract ".xxx" and a digit
         subtract 6 from j
         divide j by 3 giving i
         move i to commas
         add i to j
         add 6 to j
         if j > 2001 then
           string z"Error: result can't fit in message." into c_communication
           go to cleanup
         end-if
           
         *> we now have the new string's length
         string x'00' into c_communication(j:1)
         subtract 4 from j
         subtract i from j giving i
         move temp_str(i:4) to c_communication(j:4)
         subtract 1 from j
         move 0 to i
         move j to alt_pos
         subtract commas from alt_pos

         *> now copy over the numbers with commas inbetween.
         perform varying counter from j by -1 until counter = 0
           move temp_str(alt_pos:1) to c_communication(counter:1)
           if counter <> 1 then  
             add 1 to i
           end-if
           if i = 3 then
             subtract 1 from counter
             string ',' into c_communication(counter:1)
             move 0 to i
           end-if
             subtract 1 from alt_pos
         end-perform.

       cleanup.
         perform varying counter from 1 by 1 until counter = 2000
           call 'mpfr_clear' using numberslist(counter)
           call 'mpfr_clear' using alt_numslist(counter)
         end-perform
         
         exit program.
