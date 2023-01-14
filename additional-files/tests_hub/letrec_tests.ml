
let letrec_tests : cg_test list = [
  {test = "(letrec ((run (lambda (a) (if (zero? a) a (run (__bin-sub-qq a 1)))))) (run 10))"; expected = "0"};
  {test = "(letrec ((run (lambda (a b) (if (zero? b) b (run a (a b 1))))))(run __bin-sub-qq 10))"; expected = "0"};
  {test = "(letrec ((run (lambda (a b) (if (zero? b) b (smaller_run a b)))) (smaller_run (lambda (a b) (run a (a b 1)))))(run __bin-sub-qq 10))"; expected = "0"};
  {test = "(letrec ((run (lambda (a b) (if (zero? b) b (apply smaller_run a b '())))) (smaller_run (lambda (a b) (apply run a (a b 1) '()))))(apply run __bin-sub-qq 10 '()))"; expected = "0"}
]
