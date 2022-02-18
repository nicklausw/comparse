       identification division.
       program-id. mathParse.
       environment division.
     
       data division.
       working-storage section.
      *>  believe it or not, finding variable names in a language
      *>  based on English is freaking impossible.
         01 math_string pic x(2000).
         01 foundParentheses pic 9 value 1.
         01 counter pic 9(9) value 0.
         01 parenthsize pic 9(9) value 0.
         01 alt_pos pic 9(9) value 0.
         01 endbound pic 9(9) value 0.
         01 q pic 9(9) value 0.
         01 j pic 9(9) value 0.

         01 building_number pic x(1) value 'F'.
         01 building_offset pic 9(9) value 0.
         01 building_space pic x(100) value zeroes.

         01 parenth_pos pic 9(9).

         01 current_token pic 9(9) value 1.

         01 token_list.
           05 token_type pic x(1) value ';' occurs 2000 times.
           05 num pic s9(9)v9(9) value 0 occurs 2000 times.

         01 alt_list.
            05 alt_token_type pic x(1) value ';' occurs 2000 times.
            05 alt_num pic s9(9)v9(9) value 0 occurs 2000 times.
           
         01 outnumber pic s9(9)v9(9) value 0.

         01 parenthnumber pic s9(9)v9(9) value 0.
     
       linkage section.
         01 c_communication pic x(2000).
     
       procedure division using by reference c_communication.
      *> copy input to where we can work with it piece-by-piece.
         move c_communication to math_string

         move 0 to outnumber
         move 0 to parenthnumber
         string 'F' into building_number
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
           string  "No semicolon found." into c_communication
           exit section.

      *> first: split into tokens.
         perform varying counter from 1 by 1 until counter = 2000
      *>   if we're still getting a number's contents...
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
               add 1 to current_token giving current_token
             end-if
           end-if
         end-perform

         if current_token < 3 then
           string "Nothing to do." into c_communication
           exit section
         end-if
         if token_type(1) <> 'N' then
           string "First token must be a number."
             into c_communication
           exit section
         end-if

     *>        parentheses blocks are trouble. let's resolve them.
         move 0 to foundParentheses
         perform parenthLoop until foundParentheses = 1

         move num(1) to outnumber

         call 'calculate' using token_list, outnumber

         *> clear data that was input
         perform varying counter from 1 by 1 until counter = 2000
             string '\' into c_communication
         end-perform

         string outnumber into c_communication
         
         exit program.

      parenthLoop.
           display "logging parentheses loop."
           *> we need the semicolon's position.
           perform varying counter from 1 by 1 until counter = 2000
               if token_type(counter) = ';' then
                   exit perform
               end-if
           end-perform
           move counter to endbound
           
           perform varying counter from endbound by -1 until counter = 1
             move 1 to foundParentheses
             if token_type(counter) = ')' then
                 move counter to parenth_pos
             end-if
             if token_type(counter) = '(' then
                 display "contents before hellish loop:"
                 perform varying q from 1 by 1 until token_type(q) = ';'
                     if token_type(q) = 'N' then
                         display num(q) with no advancing
                     else
                         display token_type(q) with no advancing
                     end-if
                     if q = current_token then
                         exit perform
                     end-if
                 end-perform
                 display " "
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
                 add 1 to counter giving counter
                 move counter to j
                 add parenthsize to j giving j
                 *> counter is at dest, j is at src.
                 perform varying j from j by 1 until token_type(j) = ';'
                     move token_type(j) to token_type(counter)
                     move num(j) to num(counter)
                     add 1 to j giving j
                     add 1 to counter giving counter
                 end-perform

                 string ';' into token_type(counter)
                 
                 move 0 to foundParentheses
                 display "contents after hellish loop:"
                 perform varying q from 1 by 1 until token_type(q) = ';'
                     if token_type(q) = 'N' then
                         display num(q) with no advancing
                     else
                         display token_type(q) with no advancing
                     end-if
                     if token_type(q) = ';' then
                         exit perform
                     end-if
                 end-perform
                 display " "
             end-if
         end-perform.
