

       identification division.
       program-id. reduce_parentheses.
       environment division.

       data division.
       working-storage section.
         01 counter usage binary-long value 0.
         01 parenthsize usage binary-long value 0.
         01 alt_pos usage binary-long value 0.
         01 endbound usage binary-long value 0.
         01 start_parenth_pos usage binary-long.
         01 end_parenth_pos usage binary-long.
         01 j usage binary-long value 0.

       linkage section.
         01 found_parentheses usage binary-long value 1.

         01 did_we_finish pic x(1) value 'F'.

         01 token_list.
           03 token_type pic x(1) occurs 2000 times.
           03 numbers_list occurs 2000 times.
             05 num usage pointer.
             05 mpfr_padding pic x(32).

         *> alt_list is for the set of tokens within each parentheses
         *> to then call 'calculate' on. If token_type forms
         *> (N+(N+N)) then alt_list will contain N+N 2 times,
         *> once for each set of parentheses
         01 alt_list.
           03 alt_token_type pic x(1) occurs 2000 times.
           03 alt_numslist occurs 2000 times.
             05 alt_num usage pointer.
             05 alt_mpfr_padding pic x(32).
         
         01 c_communication pic x(2000).

       procedure division using alt_list, token_list, did_we_finish, found_parentheses, c_communication.
       
         perform varying counter from 1 by 1 until counter = 2000
           string ';' into alt_token_type(counter)
           call 'mpfr_set_d' using alt_numslist(counter), by value 0, 0
         end-perform

         *> we need the semicolon's position.
         perform varying counter from 1 by 1 until counter = 2000
           if token_type(counter) = ';' then
             exit perform
           end-if
         end-perform
         move counter to endbound
           
         perform varying counter from endbound by -1 until counter = 0
           move 1 to found_parentheses
           if token_type(counter) = ')' then
             move counter to end_parenth_pos
           end-if
           if token_type(counter) = '(' then
             move counter to start_parenth_pos
             *> say we have a statement: (N+(N*N));
             *> adding 1 to counter focuses on the second N, because it was at
             *> that second opening parenthesis. we're going backwards.
             add 1 to counter
             *> token indexing technically starts at 2 (1 is initial number).
             move 1 to alt_pos
             move 0 to parenthsize
             perform varying j from counter by 1 until j = end_parenth_pos
               move token_type(j) to alt_token_type(alt_pos)
               call 'mpfr_set' using alt_numslist(alt_pos), numbers_list(j), by value 0
               add 1 to alt_pos
               add 1 to parenthsize
             end-perform

             *> here's where we handle that initial number.
             call 'calculate' using alt_list, c_communication, did_we_finish
             if did_we_finish <> "T" then
               move 0 to found_parentheses
               exit section
             end-if

             *> this puts the counter back on the start parenthesis.
             move start_parenth_pos to counter

             *> replace start parenthesis with evaluated number.
             call 'mpfr_set' using numbers_list(counter), alt_numslist(1), by value 0
             call 'mpfr_printf' using z"%.3Rf", numbers_list(counter)
             string 'N' into token_type(counter)
             move counter to j
             add parenthsize to j
             add 2 to j
             add 1 to counter
             *> counter is at dest, j is at src.
             perform varying j from j by 1 until token_type(j) = ';'
               move token_type(j) to token_type(counter)
               call 'mpfr_set' using numbers_list(counter), numbers_list(j), by value 0
               add 1 to counter
             end-perform

             string ';' into token_type(counter)
                 
             move 0 to found_parentheses
             exit perform
           end-if
         end-perform.
