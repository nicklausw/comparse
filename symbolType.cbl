       identification division.
       program-id. symbolType.
       environment division.
       
       data division.
       working-storage section.
           01 tok_end pic 9 value 0.
           01 tok_num pic 9 value 1.
           01 tok_add pic 9 value 2.
           01 tok_sub pic 9 value 3.
           01 tok_mul pic 9 value 4.
           01 tok_div pic 9 value 5.
       linkage section.
           01 math_string pic x(2000).
           01 i pic 9(9).
           01 token_type pic 9.

       procedure division
           using by reference i, token_type, math_string.
           if math_string(i:1) = '*' then
               move tok_mul to token_type
           else if math_string(i:1) = '+' then
               move tok_add to token_type
           else if math_string(i:1) = '-' then
               move tok_sub to token_type
           else if math_string(i:1) = '/' then
               move tok_div to token_type
           else if math_string(i:1) = ';' then
               move tok_end to token_type
           end-if
           exit program.
