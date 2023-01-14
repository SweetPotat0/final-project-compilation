(define apply
  (letrec ((run
             (lambda (a s)
               (if (pair? s)
                   (cons a
                     (run (car s)
                       (cdr s)))
                   a))))
    (lambda (f . s)
      (__bin-apply f
        (run (car s)
          (cdr s))))))

(define ormap
  (lambda (f . s)
    (letrec ((loop
               (lambda (s)
                 (and (pair? (car s))
                      (or (apply f (map car s))
                          (loop (map cdr s)))))))
      (loop s))))

(define andmap
  (lambda (f . s)
    (letrec ((loop
               (lambda (s)
                 (or (null? (car s))
                     (and (apply f (map car s))
                          (loop (map cdr s)))))))
      (loop s))))  

(define map
  (letrec ((map1
             (lambda (f s)
               (if (null? s)
                   '()
                   (cons (f (car s))
                     (map1 f (cdr s))))))
           (map-list
             (lambda (f s)
               (if (null? (car s))
                   '()
                   (cons (apply f (map1 car s))
                     (map-list f
                       (map1 cdr s)))))))
    (lambda (f . s)
      (if (null? s)
          '()
          (map-list f s)))))

(define reverse
  (letrec ((run
             (lambda (s r)
               (if (null? s)
                   r
                   (run (cdr s)
                     (cons (car s) r))))))
    (lambda (s)
      (run s '()))))

(define append
  (letrec ((run-1
             (lambda (s1 sr)
               (if (null? sr)
                   s1
                   (run-2 s1
                     (run-1 (car sr)
                       (cdr sr))))))
           (run-2
             (lambda (s1 s2)
               (if (null? s1)
                   s2
                   (cons (car s1)
                     (run-2 (cdr s1) s2))))))
    (lambda s
      (if (null? s)
          '()
          (run-1 (car s)
            (cdr s))))))

(define fold-left
  (letrec ((run
             (lambda (f unit ss)
               (if (ormap null? ss)
                   unit
                   (run f
                     (apply f unit (map car ss))
                     (map cdr ss))))))
    (lambda (f unit . ss)
      (run f unit ss))))

;;; Please remember that the order here is as per Scheme, and 
;;; not the correct order, which is in Ocaml!
(define fold-right
  (letrec ((run
             (lambda (f unit ss)
               (if (ormap null? ss)
                   unit
                   (apply f
                     `(,@(map car ss)
                       ,(run f unit (map cdr ss))))))))
    (lambda (f unit . ss)
      (run f unit ss))))

(define +
  (let* ((error (lambda () (error '+ "all arguments need to be numbers")))
         (bin+
           (lambda (a b)
             (cond ((rational? a)
                    (cond ((rational? b) (__bin-add-qq a b))
                          ((real? b) (__bin-add-rr (rational->real a) b))
                          (else (error))))
                   ((real? a)
                    (cond ((rational? b) (__bin-add-rr a (rational->real b)))
                          ((real? b) (__bin-add-rr a b))
                          (else (error))))
                   (else (error))))))
    (lambda s (fold-left bin+ 0 s))))

(define -
  (let* ((error (lambda () (error '- "all arguments need to be numbers")))
         (bin-
           (lambda (a b)
             (cond ((rational? a)
                    (cond ((rational? b) (__bin-sub-qq a b))
                          ((real? b) (__bin-sub-rr (rational->real a) b))
                          (else (error))))
                   ((real? a)
                    (cond ((rational? b) (__bin-sub-rr a (rational->real b)))
                          ((real? b) (__bin-sub-rr a b))
                          (else (error))))
                   (else (error))))))
    (lambda (a . s)
      (if (null? s)
          (bin- 0 a)
          (let ((b (fold-left + 0 s)))
            (bin- a b))))))

(define list (lambda args args))

(define make-string
  (let ((asm-make-string make-string))
    (lambda (n . chs)
      (let ((ch
              (cond ((null? chs) #\nul)
                    ((and (pair? chs)
                          (null? (cdr chs)))
                     (car chs))
                    (else (error 'make-string
                            "Usage: (make-string size ?optional-default)")))))
        (asm-make-string n ch)))))

(define make-vector
  (let ((asm-make-vector make-vector))
    (lambda (n . xs)
      (let ((x
              (cond ((null? xs) #void)
                    ((and (pair? xs)
                          (null? (cdr xs)))
                     (car xs))
                    (else (error 'make-vector
                            "Usage: (make-vector size ?optional-default)")))))
        (asm-make-vector n x)))))