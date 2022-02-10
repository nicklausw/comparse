              identification division.
              program-id. cobolstuff.
              environment division.
       
              data division.
              linkage section.
              01 coolstring pic x(2000).
       
              procedure division using by reference coolstring.
                  string "This is COBOL!\" into coolstring.
                  exit program.
       