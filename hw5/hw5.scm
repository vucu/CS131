#lang racket

(define (bad-ld? obj) 
	(if (null? obj) #t 
		(if (not (pair? obj)) #t
			#f
		)
  	)
)

(define (null-ld? obj) 
	(if (bad-ld? obj) #f
		(if (not (eq? (car obj) (cdr obj))) #f
			#t
		)
  	)
)

(define (listdiff? obj) 
	(if (bad-ld? obj) #f 
		(if (null-ld? obj) #t 
			(if (not (pair? (car obj))) #f
				(listdiff? (cons (cdr (car obj)) (cdr obj)))
			)
		)
	)
)

; test
(define ils (append '(a e i o u) 'y))
(define d1 (cons ils (cdr (cdr ils))))
(define d2 (cons ils ils))
(define d3 (cons ils (append '(a e i o u) 'y)))
(define d4 (cons '() ils))
(define d5 0)
              