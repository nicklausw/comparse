       identification division.
       program-id. mathParse.
       environment division.
     
       data division.
       working-storage section.
      *>  believe it or not, finding variable names in a language
      *>  based on English is freaking impossible.
         01 math_string pic x(2000).
         01 foundParentheses usage binary-long value 1.
         01 counter usage binary-long value 0.
         01 parenthsize usage binary-long value 0.
         01 alt_pos usage binary-long value 0.
         01 endbound usage binary-long value 0.
         01 q usage binary-long value 0.
         01 j usage binary-long value 0.
         01 dummy usage binary-long value 0.

         01 building_number pic x(1) value 'F'.
         01 building_offset usage binary-long value 0.
         01 building_space pic x(100) value zeroes.

         01 parenth_pos usage binary-long.

         01 current_token usage binary-long value 1.

         01 token_list.
           05 token_type pic x(1) value ';' occurs 2000 times.
           05 num usage float-long value 0 occurs 2000 times.

         01 alt_list.
            05 alt_token_type pic x(1) value ';' occurs 2000 times.
            05 alt_num usage float-long value 0 occurs 2000 times.
           
         01 outnumber usage float-long value 0.

         01 parenthnumber usage float-long value 0.
     
       linkage section.
         01 c_communication pic x(2000).
         01 finalnumber usage float-long.
         01 didwefinish pic x(1) value 'F'.
     
       procedure division
         using by reference c_communication, finalnumber, didwefinish.
      *> copy input to where we can work with it piece-by-piece.
         move c_communication to math_string

         move 0 to outnumber
         move 0 to parenthnumber
         string 'F' into building_number
         string 'F' into didwefinish
         move 1 to current_token

         perform varying counter from 1 by 1 until counter = 2000
           string ';' into token_type(counter)
           move 0 to num(counter)
           string ';' into alt_token_type(counter)
           move 0 to alt_num(counter)
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
           string "No semicolon found.\" into c_communication
           exit section.

      *>first: split into tokens.
         perform varying counter from 1 by 1 until counter = 2000
      *>if we're still getting a number's contents...
           if math_string(counter:1) = ' ' then
             exit perform cycle
           end-if
           if building_number = 'F' then
             if (math_string(counter:1) is numeric) or
              (math_string(counter:1) = '.') then
               string 'T' into building_number
               string 'N' into token_type(current_token)
               move 1 to building_offset
               move math_string(counter:1) to building_space(building_offset:1)
               add 1 to building_offset giving building_offset
               exit perform cycle
             else
               move math_string(counter:1) to
               token_type(current_token)
               if token_type(current_token) = ';' then
                  exit perform
               end-if
              
               if token_type(current_token) = '(' then
                 if counter > 1 then
                   subtract 1 from current_token giving current_token
                   if token_type(current_token) = 'N' or token_type(current_token) = ')' then
                     *> implied multiplication
                     add 1 to current_token giving current_token
                     string '*' into token_type(current_token)
                     add 1 to current_token giving current_token
                     string '(' into token_type(current_token)
                   else
                     add 1 to current_token giving current_token
                   end-if
                 end-if
               end-if
               add 1 to current_token giving current_token
             end-if
           else
             if (math_string(counter:1) is numeric) or
              (math_string(counter:1) = '.') then
               move math_string(counter:1) to building_space(building_offset:1)
               add 1 to building_offset giving building_offset
             else
               string 'F' into building_number
               subtract 1 from building_offset
                 giving building_offset
               unstring building_space(1:building_offset) into num(current_token)
               add 1 to current_token giving current_token
               move math_string(counter:1) to token_type(current_token)
               if token_type(current_token) = ';' then
                 exit perform
               end-if
               if token_type(current_token) = '(' then
                 if counter > 1 then
                   subtract 1 from current_token giving current_token
                   if token_type(current_token) = 'N' or token_type(current_token) = ')' then
                     *> implied multiplication
                     add 1 to current_token giving current_token
                     string '*' into token_type(current_token)
                     add 1 to current_token giving current_token
                     string '(' into token_type(current_token)
                   else
                     add 1 to current_token giving current_token
                   end-if
                 end-if
               end-if

               add 1 to current_token giving current_token
             end-if
           end-if
         end-perform

     *>  parentheses blocks are trouble. let's resolve them.
         move 0 to foundParentheses
         perform parenthLoop until foundParentheses = 1

         move num(1) to outnumber

         call 'calculate' using token_list, outnumber

         *> clear data that was input
         perform varying counter from 1 by 1 until counter = 2000
           string '\' into c_communication
         end-perform

         move outnumber to finalnumber
         string 'T' into didwefinish
         
         exit program.

       parenthLoop.
         perform varying counter from 1 by 1 until counter = 2000
           string ';' into alt_token_type(counter)
           move 0 to alt_num(counter)
         end-perform

         *> we need the semicolon's position.
         perform varying counter from 1 by 1 until counter = 2000
           if token_type(counter) = ';' then
             exit perform
           end-if
         end-perform
         move counter to endbound
           
         perform varying counter from endbound by -1 until counter = 0
           move 1 to foundParentheses
           if token_type(counter) = ')' then
             move counter to parenth_pos
           end-if
           if token_type(counter) = '(' then
             *> say we have a statement: (N+(N*N));
             *> adding 1 to counter focuses on the second N. we're going backwards.
             add 1 to counter giving counter
             *> token indexing technically starts at 2 (1 is initial number).
             move 2 to alt_pos
             move 0 to parenthsize
             perform varying j from counter by 1 until j = parenth_pos
               move token_type(j) to alt_token_type(alt_pos)
               move num(j) to alt_num(alt_pos)
               add 1 to alt_pos giving alt_pos
               add 1 to parenthsize giving parenthsize
             end-perform
             *> here's where we handle that initial number.
             move alt_num(2) to parenthnumber
             call 'calculate' using by reference alt_list, parenthnumber
             *> this puts the counter back on the start parenthesis.
             subtract 1 from counter giving counter
             *> replace start parenthesis with evaluated number.
             move parenthnumber to num(counter)
             string 'N' into token_type(counter)
             move counter to j
             add parenthsize to j giving j
             add 2 to j giving j
             add 1 to counter giving counter
             *> counter is at dest, j is at src.
             perform varying j from j by 1 until token_type(j) = ';'
               move token_type(j) to token_type(counter)
               move num(j) to num(counter)
               add 1 to counter giving counter
             end-perform

             string ';' into token_type(counter)
                 
             move 0 to foundParentheses
             exit perform
           end-if
         end-perform.
