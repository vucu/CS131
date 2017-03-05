#lang racket

(define (null-ld? obj) 
	(if (null? obj) #f 
		(if (not (pair? obj)) #f
			(if (not (eq? (car obj) (cdr obj))) #f
				#t
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
              