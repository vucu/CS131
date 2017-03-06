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
        (let count-length ((curlist (car listdiff)))
          (cond
            ((eq? curlist (cdr listdiff)) 0)
            (else (+ 1 (count-length (cdr curlist))))))
	)
)

(define (append-ld listdiff . args)
	(if (null? args) listdiff
	  (apply append-ld (cons (append (take (car listdiff) (length-ld listdiff)) 
	  								  (car (car args))) (cdr (car args))) 
	  					(cdr args))
	)
)

(define (assq-ld obj alistdiff)
	(if (null-ld? alistdiff) #f
	  (if (and (pair? (car alistdiff)) (eq? (car (car (car alistdiff))) obj))
	  	(car (car alistdiff))
	  	(if (pair? (car alistdiff))
	  		(assq-ld obj (cons (cdr (car alistdiff)) (cdr alistdiff)))
	  		#f
	  	)
	  )
	)
)

(define (list->listdiff list)
  	(if (list? list)
		(apply listdiff (car list) (cdr list))
		(error "Not a listdiff!")
	)
)

(define (listdiff->list listdiff)
  	(if (listdiff? listdiff)
		(take (car listdiff) (length-ld listdiff))
		(error "Not a listdiff!")
	)
)

(define (expr-returning listdiff)
  	(if (listdiff? listdiff)
		`(cons ',(take (car listdiff) (length-ld listdiff)) '())
		(error "Not a listdiff!")
	)
)


; test
(define ils (append '(a e i o u) 'y))
(define d1 (cons ils (cdr (cdr ils))))
(define d2 (cons ils ils))
(define d3 (cons ils (append '(a e i o u) 'y)))
(define d4 (cons '() ils))
(define d5 0)
(define d6 (listdiff ils d1 37))
(define d7 (append-ld d1 d2 d6))
(define e1 (expr-returning d1))
(listdiff? d1)                         
(listdiff? d2)                         
(listdiff? d3)                         
(listdiff? d4)                         
(listdiff? d5)                         
(listdiff? d6)                         
(listdiff? d7)                         
(null-ld? d1)                                                  
(null-ld? d6)                          
(car-ld d1)                                            
(car-ld d6)                            
(length-ld d1)                       
(length-ld d2)                      
(length-ld d6)                        
(length-ld d7)                        
(define kv1 (cons d1 'a))
(define kv2 (cons d2 'b))
(define kv3 (cons d3 'c))
(define kv4 (cons d1 'd))
(define d8 (listdiff kv1 kv2 kv3 kv4))
(eq? (assq-ld d1 d8) kv1)             
(eq? (assq-ld d2 d8) kv2)             
(eq? (assq-ld d1 d8) kv4)              

(eq? (car-ld d6) ils)                 
(eq? (car-ld (cdr-ld d6)) d1)          
(eqv? (car-ld (cdr-ld (cdr-ld d6))) 37)
(equal? (listdiff->list d6)
        (list ils d1 37))              
(eq? (list-tail (car d6) 3) (cdr d6))  

(listdiff->list (eval e1))             
(equal? (listdiff->list (eval e1))
        (listdiff->list d1))  
		
(length-ld d3)
              