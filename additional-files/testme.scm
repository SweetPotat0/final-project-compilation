(letrec ((run (lambda (a) (if (zero? a) 234 (run (__bin-sub-qq a 1)))))) (run 6))