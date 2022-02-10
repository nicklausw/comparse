       identification division.
       program-id. doublenumber.
       environment division.
       data division.
       linkage section.
       01 num binary-double unsigned.
       procedure division using num.
           multiply 2 by num.
           move num to return-code.
           exit program.
