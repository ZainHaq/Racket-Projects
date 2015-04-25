;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname solitaire) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; The following line is REQUIRED (do not remove)
(require "a10lib.rkt")

;;**************************************************
;; Programmer: Zain Haq 
;; Last modified: December 1st 2014
;;**************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Dimension is an Int
;; requires: 1 <= Dimension <= 9

;; A Peg [position] is an Int
;; requires: 11 <= Peg <= 99
;;           neither digit can be zero or greater than the
;;             Dimension (for the corresponding board)

;; A Board is a (list Dimension (listof Peg))
;; The list contains INVALID Peg positions

;; A State is a (listof Peg)
;; requires: list is non-emtpy
;;           each Peg is VALID for the corresponding board

;; A Solution is one of:
;; * 'any
;; * Peg


(define no-solution-text (list (list "No Solution Found")))

(define sample (list 4 (list 41 42 43 44)))
#|
....
....
....
    
|#

(define sample/init (list 22 23))
#|
....
.OO.
....
    
|#

(define cross (list 7 (list 11 12 16 17 21 22 26 27 61 62 66 67 71 72 76 77)))
#|
  ...  
  ...  
.......
.......
.......
  ...  
  ...  
|#

(define cross/init (list 13 14 15 23 24 25 31 32 33 34 35 36 37 41 42 43
                         45 46 47 51 52 53 54 55 56 57 63 64 65 73 74 75))
#|
  OOO  
  OOO  
OOOOOOO
OOO.OOO
OOOOOOO
  OOO  
  OOO  
|#

(define cross/submarine (list 34 42 43 44 45 46))
#|
  ...  
  ...  
...O...
.OOOOO.
.......
  ...  
  ...  
|#

(define cross/greek (list 24 34 42 43 44 45 46 54 64))
#|
  ...  
  .O.  
...O...
.OOOOO.
...O...
  .O.  
  ...  
|#

(define cross/small-diamond (list 24 33 34 35 42 43 45 46 53 54 55 64))
#|
  ...  
  .O.  
..OOO..
.OO.OO.
..OOO..
  .O.  
  ...  
|#

(define cross/big-diamond (list 14 23 24 25 32 33 34 35 36 41 42 43
                                45 46 47 52 53 54 55 56 63 64 65 74))
#|
  .O.  
  OOO  
.OOOOO.
OOO.OOO
.OOOOO.
  OOO  
  .O.  
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (make-neighbours board) (lambda (state) (neighbours board state)))

;; try this when you are done: (but leave it commented out when you submit)
; (show (result->text cross (solitaire cross cross/init 'any)))

;;(build-board dimension) consumes a Dimension, dimension and produces a list
;; of rows, with each row containing a list of peg positions based on the given
;; dimension
;;build-board: Dimension -> (listof (listof Peg))
;;Examples:
(check-expect (build-board 1) '((11)))
(check-expect (build-board 2) '((11 12) (21 22)))

(define (build-board dimension)
  (local [(define coordinate-factor 10)]
    (build-list dimension (lambda (i)
                            (build-list dimension (lambda (j) 
                                                    (+ (* (add1 i) 
                                                          coordinate-factor) 
                                                       (add1 j))))))))

;;Tests:
(check-expect (build-board 3) '((11 12 13) (21 22 23) (31 32 33)))
(check-expect (build-board 4) '((11 12 13 14) 
                                (21 22 23 24)
                                (31 32 33 34)
                                (41 42 43 44)))
(check-expect (build-board 5) '((11 12 13 14 15) 
                                (21 22 23 24 25)
                                (31 32 33 34 35)
                                (41 42 43 44 45)
                                (51 52 53 54 55)))


;;(state->los board state) consumes a Board, board and a State, state and
;; produces a (listof Str) corresponding to one string per row. #\space 
;; represents an invalid postion, #\O represents a position occupied by a peg 
;; and #\. represents an empty peg
;;state->los: Board State -> (listof Str)
;;Examples:
(check-expect (state->los '(4 (41 42 43 44)) '(22 23))
              '("...." ".OO." "...." "    "))
(check-expect (state->los '(4 ()) '(22 23))
              '("...." ".OO." "...." "...."))

(define (state->los board state)
  (map (lambda (row) (list->string 
                      (map (lambda (x) (cond 
                                         [(member? x (second board)) #\space]
                                         [(member? x state) #\O]
                                         [else #\.]))
                           row)))
       (build-board (first board))))

;;Tests:
(check-expect (state->los '(3 ()) '(22))
              '("..." ".O." "..."))
(check-expect (state->los '(3 ()) '(12 21 22 23 32))
              '(".O." "OOO" ".O."))
(check-expect (state->los '(3 ()) '(11 12 13))
              '("OOO" "..." "..."))
(check-expect (state->los '(3 (21 22 23 31 32 33)) '(11 12 13))
              '("OOO" "   " "   "))
(check-expect (state->los '(3 (21 22 23 31 32 33)) '(11))
              '("O.." "   " "   "))
(check-expect (state->los cross cross/init) '("  OOO  "  
                                              "  OOO  "  
                                              "OOOOOOO" 
                                              "OOO.OOO" 
                                              "OOOOOOO" 
                                              "  OOO  "  
                                              "  OOO  "))
(check-expect (state->los cross cross/greek) '("  ...  "  
                                               "  .O.  "  
                                               "...O..." 
                                               ".OOOOO." 
                                               "...O..." 
                                               "  .O.  "  
                                               "  ...  "))


;;(make-solved? soln) consumes a Solution, soln and produces a function that 
;; consumes a state and produces whether or not that state is a solution
;;make-solved?: Solution -> (State -> Bool)
;;Examples:
(check-expect ((make-solved? 'any) '(44 45)) false)
(check-expect ((make-solved? 'any) '(44)) true)

(define (make-solved? soln)
  (lambda (state) (cond [(cons? (rest state)) false]
                        [(or (equal? soln 'any)
                             (equal? (first state) soln)) true]
                        [else false])))

;;Tests:
(check-expect ((make-solved? 'any) '(45)) true)
(check-expect ((make-solved? 44) '(45)) false)
(check-expect ((make-solved? 45) '(45)) true)
(check-expect ((make-solved? 45) '(44 45)) false)
(check-expect ((make-solved? 44) '(44 45)) false)
(check-expect ((make-solved? 11) '(11)) true)
(check-expect ((make-solved? 'any) '(11)) true)


;;(neighbours board state) consumes a Board, board and a State, state and
;; produces a (listof States) which corresponds to each legal move. It does 
;; this by checking all the possible moves of each peg in the state and then 
;; combines those results into a (listof States)
;;neighbours: Board State -> (listof States)
;;Examples:
(check-expect (neighbours '(4 (41 42 43 44)) '(22 23))
              (list '(24) '(21)))
(check-expect (neighbours '(4 (41 42 43 44)) '(22 23 24))
              (list '(21 24)))

(define (neighbours board state)
  (local [(define grid (build-board (first board)))
          (define left -1)
          (define right 1)
          (define up -10)
          (define down 10)
          (define list-directions (list up down left right))
          
          ;;(flatten list) converts a nested list, list into a single flat list
          ;; by flattening each individual list and appending those results 
          ;; together
          ;;flatten: (listof (listof Any)) -> (listof Any)
          (define (flatten list) 
            (foldr append empty  list))
          
          ;;(valid-pos? peg) consumes a Peg, peg and determines whether or not 
          ;; the position of peg is valid or not
          ;;valid-pos?: Peg -> Bool
          (define (valid-pos? peg)
            (and (member? peg (flatten grid))
                 (not (member? peg (second board)))
                 (not (member? peg state))))
          
          ;;(can-move? peg direction) consumes a Peg, peg and a direction and
          ;; determines if the peg can legally move in that direction
          ;;can-move?: Peg (anyof up down left right) -> Bool
          (define (can-move? peg direction)
            (and (member? (+ peg direction) state)
                 (valid-pos? (+ peg (* 2 direction)))))
          
          ;;(new-state peg direction) consumes a Peg, peg and a direction and 
          ;; if the peg can move in the given direction, then it produces the 
          ;; new state of the board, produces false otherwise
          ;;new-state: Peg (anyof up down left right) -> (anyof State false) 
          (define (new-state peg direction)
            (cond [(can-move? peg direction) 
                   (filter (lambda (x) (and (not (= x peg)) 
                                            (not (= x (+ peg direction))))) 
                           (cons (+ peg (* 2 direction)) state))]
                  [else false]))
          
          ;;(all-directions state) consumes a State, state and
          ;; produces a (listof States) which corresponds to each legal move. 
          ;; It does this by checking all the possible moves of each peg in 
          ;; each direction
          (define (all-directions state)
            (cond [(empty? state) empty]
                  [else (append (filter cons? 
                                        (map (lambda (x) 
                                               (new-state (first state) x))
                                                   list-directions))
                                (all-directions (rest state)))]))]
    (all-directions state)))

;;Tests:
(check-expect (neighbours '(4 (41 42 43 44)) '(22 32))
              (list '(12)))
(check-expect (neighbours '(4 (41 42 43 44)) '(22 23 33))
              (list '(24 33) '(21 33) '(13 22)))
(check-expect (neighbours '(4 (41 42 43 44)) '(22 23 32))
              (list '(24 32) '(21 32) '(12 23)))
(check-expect (neighbours '(4 (41 42 43 44)) '(22)) empty)
(check-expect (neighbours '(4 (41 42 43 44)) '(11 23)) empty)
(check-expect (neighbours '(4 (41 42 43 44)) '(21 23)) empty)
(check-expect (neighbours '(4 (41 42 43 44)) '(13 23)) '((33)))


;;(solitaire board state soln) consumes a Board, board, a State, state, and a
;; Solution, soln. If a Solution exists the it produces a (listof States)
;; correspond to the states leading to soln, produces false otherwise
;;solitaire: Board State Solution -> (anyof (listof State) false)
;;Examples:
(check-expect (solitaire sample sample/init 21) (list '(22 23) '(21)))
(check-expect (solitaire sample sample/init 31) false)

(define (solitaire board state soln)
  (find-route state (make-neighbours board) (make-solved? soln)))

;;Tests:
(check-expect (solitaire '(3 ()) '(11 12) 'any) (list '(11 12) '(13)))
(check-expect (solitaire sample sample/init 'any) (list '(22 23) '(24)))
(check-expect (solitaire '(4 (41 42 43 44)) '(22) 21) false)
(check-expect (solitaire '(4 (41 42 43 44)) '(22) 22) '((22)))
(check-expect (solitaire '(4 (41 42 43 44)) '(13 23) 'any) '((13 23) (33)))
(check-expect (solitaire cross cross/submarine 'any) 
              '((34 42 43 44 45 46) 
                (54 42 43 45 46) 
                (44 54 45 46) 
                (34 45 46) 
                (44 34) 
                (24)))
(check-expect (solitaire cross cross/submarine 54) 
              '((34 42 43 44 45 46) 
                (54 42 43 45 46) 
                (44 54 45 46) 
                (34 45 46) 
                (44 34) 
                (54)))


;;(result->text board result) consumes a Board, board, and a result from 
;; solitaire, result and produces a (listof (listof Str)) where each 
;; (listof Str) is the value produces by state->los for the corresponding state
;; , produces "No Solution Found" otherwise
;;result->text: Board (anyof (listof State) false) 
;;              -> (anyof "No Solution Found" (listof (listof Str)))
;;Examples:
(check-expect (result->text '(3 ()) (solitaire '(3 ()) '(11 12) 'any))
              (list (list "OO." "..." "...") (list "..O" "..." "...")))
(check-expect (result->text '(3 ()) (solitaire '(3 ()) '(11 12) 22))
              no-solution-text)

(define (result->text board result)
  (cond [(false? result) no-solution-text]
        [else (map (lambda (x) (state->los board x)) result)]))

;;Tests:
(check-expect (result->text '(3 ()) (solitaire cross cross/submarine 11))
              no-solution-text)
(check-expect (result->text '(3 ()) (solitaire cross cross/submarine 11))
              no-solution-text)
(check-expect (result->text sample (solitaire sample sample/init 'any))
              '(("...." ".OO." "...." "    ") ("...." "...O" "...." "    ")))
(check-expect (result->text sample (solitaire sample sample/init 21))
              '(("...." ".OO." "...." "    ") ("...." "O..." "...." "    ")))
(check-expect (result->text sample (solitaire sample sample/init 22))
              no-solution-text)
(check-expect (result->text sample (solitaire sample '(13 23) 'any))
              '(("..O." "..O." "...." "    ") ("...." "...." "..O." "    ")))
(check-expect (result->text sample (solitaire sample '(13 23) 32))
              no-solution-text)




