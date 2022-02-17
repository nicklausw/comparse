       identification division.
       program-id. cobolstuff.
       environment division.
       
       data division.
       working-storage section.
      *Believe it or not, finding variable names in a language
      *based on English is freaking impossible.
       01 math_string pic x(1) occurs 2000 times indexed by i.
       linkage section.
       01 c_communication pic x(2000).
       
       procedure division using by reference c_communication.
           perform varying i from 1 by 1 until i = 2000
               move c_communication(i:i) to math_string(i)
           end-perform
           perform varying i from 1 by 1 until i = 2000
               if math_string(i) (1:1) = ';' then
                   exit perform
           end-perform
           if i = 2000 then
               string  "No semicolon found.\" into c_communication
           else
               string "Good message!\" into c_communication
           end-if
           exit program.
