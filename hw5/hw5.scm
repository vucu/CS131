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

(define (listdiff? obj) 
	(if (null? obj) #f
		(if (not (pair? obj)) #f
			(if (null-ld? obj) #t 
				(if (not (pair? (car obj))) #f
					(listdiff? (cons (cdr (car obj)) (cdr obj)))
				)
			)
		)
  	)
)

(define (cons-ld obj listdiff)
	(if (not (listdiff? listdiff)) (error "Not a listdiff!")
		(cons 
			(cons obj (car listdiff)) 
			(cdr listdiff)
		) 
	)
)


(define (car-ld listdiff)
	(if (not (listdiff? listdiff)) (error "Not a listdiff!")
		(if (null-ld? listdiff) (error "Empty listdiff!")
			(car (car listdiff))
		)
	)
)

(define (cdr-ld listdiff)
	(if (not (listdiff? listdiff)) (error "Not a listdiff!")
		(if (null-ld? listdiff) (error "Empty listdiff!")
			(cons 
				(cdr (car listdiff)) 
				(cdr listdiff)
			)
		)
	)
)

(define (listdiff obj . arg)
	(cons (cons obj arg) '())
)


(define (length-ld listdiff)
	(if (not (listdiff? listdiff)) (error "Not a listdiff!")
        (let acc ((fst (car listdiff)))
			(if (eq? fst (cdr listdiff)) 0
				(+ 1 (acc (cdr fst)))
			)
		)
	)
)

(define (append-ld listdiff . arg)
	(if (null? arg) listdiff   
		(let acc ((fst (cons listdiff arg)))
			(if (null? (cdr fst)) (car fst)
				(let app ((prefix (listdiff->list (car fst))))
					(if (null? prefix) (acc (cdr fst))
						(cons-ld (car prefix) (app (cdr prefix))))
				)
			)
		)
	)
)

(define (assq-ld obj alistdiff)
	(if (null-ld? alistdiff) #f
		(if (not (pair? (car alistdiff))) #f
			(if (eq? (car (car (car alistdiff))) obj) (car (car alistdiff))
				(assq-ld obj (cons (cdr (car alistdiff)) (cdr alistdiff)))
			)	
		)
	)
)

(define (list->listdiff list)
  	(if (not (list? list)) (error "Not a list!")
		(apply listdiff (car list) (cdr list))
	)
)

(define (listdiff->list listdiff)
  	(if (not (listdiff? listdiff)) (error "Not a listdiff!")
		(take (car listdiff) (length-ld listdiff))
	)
)

(define (expr-returning listdiff)
  	(if (not (listdiff? listdiff)) (error "Not a listdiff!")
		`(cons ',(take (car listdiff) (length-ld listdiff)) '())
	)
)
