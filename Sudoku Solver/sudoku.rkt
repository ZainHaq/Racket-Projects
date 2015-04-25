;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname sudoku) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; The following line is REQUIRED (do not remove)
(require "a10lib.rkt")

;;**************************************************
;; Programmer: Zain Haq
;; Last Modified: December 1st 2014
;;**************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A SudokuDigit is one of:
;; * '?
;; * 1 <= Nat <= 9

;; A Puzzle is a (listof (listof SudokuDigit))
;; requires: the list and all sublists have a length of 9

;; A Solution is a Puzzle
;; requires: none of the SudokuDigits are '?
;;           the puzzle satisfies the number placement 
;;             rules of sudoku

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Here are some sample sudoku puzzles

(define veryeasy
  '((? 4 5 8 9 3 7 1 6)
    (8 1 3 5 7 6 9 2 4)
    (7 6 9 2 1 4 5 3 8)
    (5 3 6 9 8 7 1 4 2)
    (4 9 2 1 6 5 8 7 3)
    (1 7 8 4 3 2 6 5 9)
    (6 8 4 7 2 1 3 9 5)
    (3 2 1 6 5 9 4 8 7)
    (9 5 7 3 4 8 2 6 1)))

;; the above puzzle with more blanks:
(define easy
  '((? 4 5 8 ? 3 7 1 ?)
    (8 1 ? ? ? ? ? 2 4)
    (7 ? 9 ? ? ? 5 ? 8)
    (? ? ? 9 ? 7 ? ? ?)
    (? ? ? ? 6 ? ? ? ?)
    (? ? ? 4 ? 2 ? ? ?)
    (6 ? 4 ? ? ? 3 ? 5)
    (3 2 ? ? ? ? ? 8 7)
    (? 5 7 3 ? 8 2 6 ?)))

;; the puzzle listed on wikipedia
(define wikipedia '((5 3 ? ? 7 ? ? ? ?)
                    (6 ? ? 1 9 5 ? ? ?)
                    (? 9 8 ? ? ? ? 6 ?)
                    (8 ? ? ? 6 ? ? ? 3)
                    (4 ? ? 8 ? 3 ? ? 1)
                    (7 ? ? ? 2 ? ? ? 6)
                    (? 6 ? ? ? ? 2 8 ?)
                    (? ? ? 4 1 9 ? ? 5)
                    (? ? ? ? 8 ? ? 7 9)))

;; A blank puzzle template for you to use:
(define blank '((? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)
                (? ? ? ? ? ? ? ? ?)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define row-origin 1)
(define col-origin 1)

;;Useful constants for testing
(define requires-9  '((4 1 2 3 ? 5 6 7 8)
                      (3 ? ? ? ? ? ? ? ?)
                      (4 ? ? ? ? ? ? ? ?)
                      (1 ? ? ? ? ? ? ? ?)
                      (2 ? ? ? ? ? ? ? ?)
                      (5 ? ? ? ? ? ? ? ?)
                      (6 ? ? ? ? ? ? ? ?)
                      (7 ? ? ? ? ? ? ? ?)
                      (8 ? ? ? ? ? ? ? ?)))
(define requires-1  '((? 2 3 4 5 6 7 8 9)
                      (4 ? ? ? ? ? ? ? ?)
                      (5 ? ? ? ? ? ? ? ?)
                      (2 ? ? ? ? ? ? ? ?)
                      (3 ? ? ? ? ? ? ? ?)
                      (6 ? ? ? ? ? ? ? ?)
                      (7 ? ? ? ? ? ? ? ?)
                      (8 ? ? ? ? ? ? ? ?)
                      (9 ? ? ? ? ? ? ? ?)))
(define no-sol  '((2 7 3 4 5 6 ? 8 9)
                  (? ? ? ? ? ? 4 ? ?)
                  (? ? ? ? ? ? 5 ? ?)
                  (? ? ? ? ? ? 1 ? ?)
                  (? ? ? ? ? ? 3 ? ?)
                  (? ? ? ? ? ? 6 ? ?)
                  (? ? ? ? ? ? 7 ? ?)
                  (? ? ? ? ? ? 8 ? ?)
                  (? ? ? ? ? ? 9 ? ?)))
(define no-sol-2 '((7 8 1 5 4 3 9 2 6)
                   (? ? 6 1 7 9 5 ? ?)
                   (9 5 4 6 2 8 7 3 1)
                   (6 9 5 8 3 7 2 1 4)
                   (1 4 8 2 6 5 3 7 9)
                   (3 2 7 9 1 4 8 ? ?)
                   (4 1 3 7 5 2 6 9 8)
                   (? ? 2 ? ? ? 4 ? ?)
                   (5 7 9 4 8 6 1 ? 3)))
(define requires-4 '((2 4 5 8 9 3 7 1 6)
                     (8 1 3 5 7 6 9 2 4)
                     (7 6 9 2 1 4 5 3 8)
                     (5 3 6 9 8 7 1 4 2)
                     (? 9 2 1 6 5 8 7 3)
                     (1 7 8 4 3 2 6 5 9)
                     (6 8 4 7 2 1 3 9 5)
                     (3 2 1 6 5 9 4 8 7)
                     (9 5 7 3 4 8 2 6 1)))
(define requires-6 '((2 4 5 8 9 3 7 1 6)
                     (8 1 3 5 7 6 9 2 4)
                     (7 6 9 2 1 4 5 3 8)
                     (5 3 6 9 8 7 1 4 2)
                     (4 9 2 1 ? 5 8 7 3)
                     (1 7 8 4 3 2 6 5 9)
                     (6 8 4 7 2 1 3 9 5)
                     (3 2 1 6 5 9 4 8 7)
                     (9 5 7 3 4 8 2 6 1)))
(define requires-7 '((2 4 5 8 9 3 7 1 6)
                     (8 1 3 5 7 6 9 2 4)
                     (7 6 9 2 1 4 5 3 8)
                     (5 3 6 9 8 7 1 4 2)
                     (4 9 2 1 6 5 8 ? 3)
                     (1 7 8 4 3 2 6 5 9)
                     (6 8 4 7 2 1 3 9 5)
                     (3 2 1 6 5 9 4 8 7)
                     (9 5 7 3 4 8 2 6 1)))
(define requires-2 '((2 4 5 8 9 3 7 1 6)
                     (8 1 3 5 7 6 9 2 4)
                     (7 6 9 2 1 4 5 3 8)
                     (5 3 6 9 8 7 1 4 2)
                     (4 9 2 1 6 5 8 7 3)
                     (1 7 8 4 3 2 6 5 9)
                     (6 8 4 7 2 1 3 9 5)
                     (3 ? 1 6 5 9 4 8 7)
                     (9 5 7 3 4 8 2 6 1)))
(define requires-5 '((2 4 5 8 9 3 7 1 6)
                     (8 1 3 5 7 6 9 2 4)
                     (7 6 9 2 1 4 5 3 8)
                     (5 3 6 9 8 7 1 4 2)
                     (4 9 2 1 6 5 8 7 3)
                     (1 7 8 4 3 2 6 5 9)
                     (6 8 4 7 2 1 3 9 5)
                     (3 2 1 6 ? 9 4 8 7)
                     (9 5 7 3 4 8 2 6 1)))
(define requires-8 '((2 4 5 8 9 3 7 1 6)
                     (8 1 3 5 7 6 9 2 4)
                     (7 6 9 2 1 4 5 3 8)
                     (5 3 6 9 8 7 1 4 2)
                     (4 9 2 1 6 5 8 7 3)
                     (1 7 8 4 3 2 6 5 9)
                     (6 8 4 7 2 1 3 9 5)
                     (3 2 1 6 5 9 4 ? 7)
                     (9 5 7 3 4 8 2 6 1)))
(define solved '((2 4 5 8 9 3 7 1 6)
                 (8 1 3 5 7 6 9 2 4)
                 (7 6 9 2 1 4 5 3 8)
                 (5 3 6 9 8 7 1 4 2)
                 (4 9 2 1 6 5 8 7 3)
                 (1 7 8 4 3 2 6 5 9)
                 (6 8 4 7 2 1 3 9 5)
                 (3 2 1 6 5 9 4 8 7)
                 (9 5 7 3 4 8 2 6 1)))
(define hard '((8 ? ? ? ? ? ? ? ?)
               (? ? 3 6 ? ? ? ? ?)
               (? 7 ? ? 9 ? 2 ? ?)
               (? 5 ? ? ? 7 ? ? ?)
               (? ? ? ? 4 5 7 ? ?)
               (? ? ? 1 ? ? ? 3 ?)
               (? ? 1 ? ? ? ? 6 8)
               (? ? 8 5 ? ? ? 1 ?)
               (? 9 ? ? ? ? 4 ? ?)))

;;(neighbours puzzle) consumes a Puzzle, puzzle and produces a (listof Puzzle)
;; where each Puzzle in the list, has the first instance of '? replaced with 
;; a possible value that may solve the puzzle
;;neighbours: Puzzle -> (listof Puzzle)
;;Examples:
(check-expect (neighbours veryeasy) '(((2 4 5 8 9 3 7 1 6)
                                       (8 1 3 5 7 6 9 2 4)
                                       (7 6 9 2 1 4 5 3 8)
                                       (5 3 6 9 8 7 1 4 2)
                                       (4 9 2 1 6 5 8 7 3)
                                       (1 7 8 4 3 2 6 5 9)
                                       (6 8 4 7 2 1 3 9 5)
                                       (3 2 1 6 5 9 4 8 7)
                                       (9 5 7 3 4 8 2 6 1))))
(check-expect (neighbours easy) '(((2 4 5 8 ? 3 7 1 ?)
                                   (8 1 ? ? ? ? ? 2 4)
                                   (7 ? 9 ? ? ? 5 ? 8)
                                   (? ? ? 9 ? 7 ? ? ?)
                                   (? ? ? ? 6 ? ? ? ?)
                                   (? ? ? 4 ? 2 ? ? ?)
                                   (6 ? 4 ? ? ? 3 ? 5)
                                   (3 2 ? ? ? ? ? 8 7)
                                   (? 5 7 3 ? 8 2 6 ?))))

(define (neighbours puzzle) 
  (local [(define sudoku-digits '(1 2 3 4 5 6 7 8 9))
          (define r (first (get-pos-of-blank puzzle)))
          (define c (second (get-pos-of-blank puzzle)))          
          
          ;;(flatten list) converts a nested list, list into a single flat list
          ;; by flattening each individual list and appending those results 
          ;; together
          ;;flatten: (listof (listof Any)) -> (listof Any)
          (define (flatten list) (foldr append empty list))
          
          ;;(get-3-rows curr-row row puzzle) produces a list of the given row 
          ;; number, and the 2 rows adjacent to it, in a given Puzzle, puzzle. 
          ;; curr-row is an acumulator and stores which row we are currently on
          ;;get-3-rows: Nat Nat Puzzle 
          ;;            -> (listof (listof (anyof SudokuDigit '?)))
          (define (get-3-rows curr-row row puzzle)
            (cond [(= curr-row row) (list (first puzzle)
                                          (second puzzle)
                                          (third puzzle))]   
                  [else (get-3-rows (add1 curr-row) row (rest puzzle))]))
          
          ;;(take list n) consumes a list, list and an integer, n, and produces 
          ;; the first n elements of the list, or the whole list if it contains 
          ;; less than n elements
          ;;take: (listof X) Nat -> (listof X)
          (define (take list n)
            (cond
              [(or (empty? list) (= n 0)) empty]
              [else (cons (first list) (take (rest list) (sub1 n)))]))
          
          ;;(get-3-cols curr-col col row) produces a list of the 2 columns
          ;; adjacent to and including the given, col number, in a given row,
          ;; which is a (listof (listof (anyof SudokuDigit '?)))
          ;;get-3-cols: Nat Nat (listof (listof (anyof SudokuDigit '?)))
          ;;            -> (listof (listof (anyof SudokuDigit '?)))
          (define (get-3-cols curr-col col row)
            (cond [(= curr-col col) (take row 3)]
                  [else (get-3-cols (add1 curr-col) col (rest row))]))
          
          ;;(make-3-by-3 row col puzzle) produces a 3-by-3 grid given a row and
          ;; col number from a given Puzzle, puzzle
          ;;make-3-by-3: Nat Nat Puzzle 
          ;;            -> (list (listof (anyof SudokuDigit '?))
          ;;                     (listof (anyof SudokuDigit '?))
          ;;                     (listof (anyof SudokuDigit '?)))
          (define (make-3-by-3 row col puzzle)
            (map (lambda (x) (get-3-cols col-origin col x)) 
                 (get-3-rows row-origin row puzzle)))
          
          ;;Constants that represent the 9 sub-regions of a give puzzle
          (define region1 (make-3-by-3 1 1 puzzle))
          (define region2 (make-3-by-3 1 4 puzzle))
          (define region3 (make-3-by-3 1 7 puzzle))
          (define region4 (make-3-by-3 4 1 puzzle))
          (define region5 (make-3-by-3 4 4 puzzle))
          (define region6 (make-3-by-3 4 7 puzzle))
          (define region7 (make-3-by-3 7 1 puzzle))
          (define region8 (make-3-by-3 7 4 puzzle))
          (define region9 (make-3-by-3 7 7 puzzle))
          
          ;;(determine-region r c) determines which region a given row number,
          ;; r, and a given col number, c, is located in
          ;;determine-region: Nat Nat -> (list (listof (anyof SudokuDigit '?))
          ;;                                   (listof (anyof SudokuDigit '?))
          ;;                                   (listof (anyof SudokuDigit '?)))
          (define (determine-region r c)
            (cond [(<= r 3) (cond [(<= c 3) region1]
                                  [(<= c 6) region2]
                                  [else region3])]
                  [(<= r 6) (cond [ (<= c 3) region4]
                                  [(<= c 6) region5]
                                  [else region6])]
                  [else (cond [(<= c 3) region7]
                              [(<= c 6) region8]
                              [else region9])]))
          
          ;;(dedup lo-sudokudigits) consumes a (listof SudokuDigit), 
          ;; lo-sudokudigits, and produces a list with only one occurence of 
          ;; each element in lo-sudokudigits
          ;;dedup: (listof SudokuDigit) -> (listof SudokuDigit)
          (define (dedup lo-sudokudigits)
            (foldr (lambda (x y) 
                     (cond [(member? x y) y]
                           [else (cons x y)])) empty lo-sudokudigits))
          
          ;;(impossible-values r c puzzle) determines which values of 
          ;; SudokuDigit will not satisfy the requirements of a blank space
          ;; in row r, and col c
          ;;impossible-values: Nat Nat Puzzle -> (listof SudokuDigit)
          (define (impossible-values r c puzzle)
            (dedup (append (remove '? (list-ref puzzle (sub1 r)))
                           (remove '? (map (lambda (x) (list-ref x (sub1 c))) 
                                           puzzle))
                           (remove '? (flatten (determine-region r c))))))
          ;;(possible-values lo-impossible-values lo-possible-values)
          ;; determines which values are possible for a sudoku puzzle by
          ;; removing lo-impossible-values from a lo-possible-values
          ;;possible-values: (listof SudokuDigit) (listof SudokuDigit)
          ;;                 -> (listof SudokuDigit)
          (define (possible-values lo-impossible-values lo-possible-values)
            (cond [(empty? lo-impossible-values) lo-possible-values]
                  [else 
                   (possible-values 
                    (rest lo-impossible-values) 
                    (remove (first lo-impossible-values) lo-possible-values))]))
          
          ;;(replace-digit-in-row row c value) replaces the digit in column c
          ;; of the given row, row, with the given value
          ;;replace-digit-in-row:(listof (anyof SudokuDigit '?)) Nat SudokuDigit
          ;;                      -> (listof SudokuDigit)
          (define (replace-digit-in-row row c value)
            (cond [(= c col-origin) (cons value (rest row))]
                  [else (cons 
                         (first row) 
                         (replace-digit-in-row (rest row) (sub1 c) value))]))
          
          ;;(replace-digit puzzle r c value) replaces the digit in column c 
          ;; of row r, in a given Puzzle, puzzle with the given value
          ;;replace-digit: Puzzle Nat Nat SudokuDigit -> Puzzle
          (define (replace-digit puzzle r c value)
            (cond [(= r row-origin) 
                   (cons (replace-digit-in-row (first puzzle) c value)
                         (rest puzzle))]
                  [else 
                   (cons (first puzzle) 
                         (replace-digit (rest puzzle) (sub1 r) c value))]))]
    (map (lambda (digit) (replace-digit puzzle r c digit)) 
         (possible-values (impossible-values r c puzzle)
                          sudoku-digits))))

;;Tests
(check-expect (neighbours wikipedia) '(((5 3 1 ? 7 ? ? ? ?)
                                        (6 ? ? 1 9 5 ? ? ?)
                                        (? 9 8 ? ? ? ? 6 ?)
                                        (8 ? ? ? 6 ? ? ? 3)
                                        (4 ? ? 8 ? 3 ? ? 1)
                                        (7 ? ? ? 2 ? ? ? 6)
                                        (? 6 ? ? ? ? 2 8 ?)
                                        (? ? ? 4 1 9 ? ? 5)
                                        (? ? ? ? 8 ? ? 7 9))
                                       ((5 3 2 ? 7 ? ? ? ?)
                                        (6 ? ? 1 9 5 ? ? ?)
                                        (? 9 8 ? ? ? ? 6 ?)
                                        (8 ? ? ? 6 ? ? ? 3)
                                        (4 ? ? 8 ? 3 ? ? 1)
                                        (7 ? ? ? 2 ? ? ? 6)
                                        (? 6 ? ? ? ? 2 8 ?)
                                        (? ? ? 4 1 9 ? ? 5)
                                        (? ? ? ? 8 ? ? 7 9))
                                       ((5 3 4 ? 7 ? ? ? ?)
                                        (6 ? ? 1 9 5 ? ? ?)
                                        (? 9 8 ? ? ? ? 6 ?)
                                        (8 ? ? ? 6 ? ? ? 3)
                                        (4 ? ? 8 ? 3 ? ? 1)
                                        (7 ? ? ? 2 ? ? ? 6)
                                        (? 6 ? ? ? ? 2 8 ?)
                                        (? ? ? 4 1 9 ? ? 5)
                                        (? ? ? ? 8 ? ? 7 9))))
(check-expect (neighbours requires-9) '(((4 1 2 3 9 5 6 7 8)
                                         (3 ? ? ? ? ? ? ? ?)
                                         (4 ? ? ? ? ? ? ? ?)
                                         (1 ? ? ? ? ? ? ? ?)
                                         (2 ? ? ? ? ? ? ? ?)
                                         (5 ? ? ? ? ? ? ? ?)
                                         (6 ? ? ? ? ? ? ? ?)
                                         (7 ? ? ? ? ? ? ? ?)
                                         (8 ? ? ? ? ? ? ? ?))))
(check-expect (neighbours requires-1) '(((1 2 3 4 5 6 7 8 9)
                                         (4 ? ? ? ? ? ? ? ?)
                                         (5 ? ? ? ? ? ? ? ?)
                                         (2 ? ? ? ? ? ? ? ?)
                                         (3 ? ? ? ? ? ? ? ?)
                                         (6 ? ? ? ? ? ? ? ?)
                                         (7 ? ? ? ? ? ? ? ?)
                                         (8 ? ? ? ? ? ? ? ?)
                                         (9 ? ? ? ? ? ? ? ?))))
(check-expect (neighbours no-sol) empty)
(check-expect (neighbours requires-4) '(((2 4 5 8 9 3 7 1 6)
                                         (8 1 3 5 7 6 9 2 4)
                                         (7 6 9 2 1 4 5 3 8)
                                         (5 3 6 9 8 7 1 4 2)
                                         (4 9 2 1 6 5 8 7 3)
                                         (1 7 8 4 3 2 6 5 9)
                                         (6 8 4 7 2 1 3 9 5)
                                         (3 2 1 6 5 9 4 8 7)
                                         (9 5 7 3 4 8 2 6 1))))
(check-expect (neighbours requires-6) '(((2 4 5 8 9 3 7 1 6)
                                         (8 1 3 5 7 6 9 2 4)
                                         (7 6 9 2 1 4 5 3 8)
                                         (5 3 6 9 8 7 1 4 2)
                                         (4 9 2 1 6 5 8 7 3)
                                         (1 7 8 4 3 2 6 5 9)
                                         (6 8 4 7 2 1 3 9 5)
                                         (3 2 1 6 5 9 4 8 7)
                                         (9 5 7 3 4 8 2 6 1))))
(check-expect (neighbours requires-7) '(((2 4 5 8 9 3 7 1 6)
                                         (8 1 3 5 7 6 9 2 4)
                                         (7 6 9 2 1 4 5 3 8)
                                         (5 3 6 9 8 7 1 4 2)
                                         (4 9 2 1 6 5 8 7 3)
                                         (1 7 8 4 3 2 6 5 9)
                                         (6 8 4 7 2 1 3 9 5)
                                         (3 2 1 6 5 9 4 8 7)
                                         (9 5 7 3 4 8 2 6 1))))
(check-expect (neighbours requires-2) '(((2 4 5 8 9 3 7 1 6)
                                         (8 1 3 5 7 6 9 2 4)
                                         (7 6 9 2 1 4 5 3 8)
                                         (5 3 6 9 8 7 1 4 2)
                                         (4 9 2 1 6 5 8 7 3)
                                         (1 7 8 4 3 2 6 5 9)
                                         (6 8 4 7 2 1 3 9 5)
                                         (3 2 1 6 5 9 4 8 7)
                                         (9 5 7 3 4 8 2 6 1))))
(check-expect (neighbours requires-5) '(((2 4 5 8 9 3 7 1 6)
                                         (8 1 3 5 7 6 9 2 4)
                                         (7 6 9 2 1 4 5 3 8)
                                         (5 3 6 9 8 7 1 4 2)
                                         (4 9 2 1 6 5 8 7 3)
                                         (1 7 8 4 3 2 6 5 9)
                                         (6 8 4 7 2 1 3 9 5)
                                         (3 2 1 6 5 9 4 8 7)
                                         (9 5 7 3 4 8 2 6 1))))
(check-expect (neighbours requires-8) '(((2 4 5 8 9 3 7 1 6)
                                         (8 1 3 5 7 6 9 2 4)
                                         (7 6 9 2 1 4 5 3 8)
                                         (5 3 6 9 8 7 1 4 2)
                                         (4 9 2 1 6 5 8 7 3)
                                         (1 7 8 4 3 2 6 5 9)
                                         (6 8 4 7 2 1 3 9 5)
                                         (3 2 1 6 5 9 4 8 7)
                                         (9 5 7 3 4 8 2 6 1))))


;;(get-pos-of-blank puzzle) gets the position of the first instance of a '? in
;; a given Puzzle, puzzle. The form of the position is (list r c), where r
;; represents the row number and c represents the column number, produces 
;; 'no-blanks if there are no occurences of '?
;;get-pos-of-blank: Puzzle -> (anyof (list Nat Nat) 'no-blanks)
;;Examples:
(check-expect (get-pos-of-blank blank) (list 1 1))
(check-expect (get-pos-of-blank solved) 'no-blanks)

(define (get-pos-of-blank puzzle)
  (local [;;(get-row-of-blank puzzle row) gets the row number of the first 
          ;; occurence of '? in a given Puzzle, puzzle, in the form 
          ;; (list r row), where r is the row number and row is the actual row
          ;; in the puzzle. row is initially set to the row-origin(i.e 1)
          ;;get-row-of-blank: Puzzle Nat -> (list Nat (listof SudokuDigits))
          (define (get-row-of-blank puzzle row)
            (cond [(empty? puzzle) 'no-blanks]
                  [(member? '? (first puzzle)) 
                   (get-col-of-blank (list row (first puzzle)) 1)]
                  [else (get-row-of-blank (rest puzzle) (add1 row))]))
          
          ;;(get-col-of-blank row-list col) consumes a list of the form 
          ;; (list r row), row-list, and produces the column number, col in 
          ;; which '? occurs in the given row-list, in the form of (list r c)
          ;; where r is the row number and c is the column number
          ;;get-col-of-blank: (list Nat (listof SudokuDigits)) Nat 
          ;;                   -> (list Nat Nat)
          (define (get-col-of-blank row-list col)
            (cond [(equal? (first row-list) 'no-blanks) 'no-blanks]
                  [(equal? (first (second row-list)) '?) 
                   (list (first row-list) col)]
                  [else (get-col-of-blank (list (first row-list) 
                                                (rest (second row-list))) 
                                          (add1 col))]))]
    (get-row-of-blank puzzle row-origin)))

;;Tests:
(check-expect (get-pos-of-blank veryeasy) (list 1 1))
(check-expect (get-pos-of-blank easy) (list 1 1))
(check-expect (get-pos-of-blank wikipedia) (list 1 3))
(check-expect (get-pos-of-blank hard) (list 1 2))
(check-expect (get-pos-of-blank requires-9) (list 1 5))
(check-expect (get-pos-of-blank no-sol) (list 1 7))
(check-expect (get-pos-of-blank requires-4) (list 5 1))
(check-expect (get-pos-of-blank requires-6) (list 5 5))
(check-expect (get-pos-of-blank requires-2) (list 8 2))
(check-expect (get-pos-of-blank requires-7) (list 5 8))


;;(sudoku puzzle) consumes a Puzzle, puzzle and produces a solution to puzzle,
;; if it exists, produces false otherwise
;;sudoku: Puzzle -> (anyof Solution false)
;Examples:
(check-expect (sudoku no-sol) false)
(check-expect (sudoku veryeasy) '((2 4 5 8 9 3 7 1 6)
                                  (8 1 3 5 7 6 9 2 4)
                                  (7 6 9 2 1 4 5 3 8)
                                  (5 3 6 9 8 7 1 4 2)
                                  (4 9 2 1 6 5 8 7 3)
                                  (1 7 8 4 3 2 6 5 9)
                                  (6 8 4 7 2 1 3 9 5)
                                  (3 2 1 6 5 9 4 8 7)
                                  (9 5 7 3 4 8 2 6 1)))

(define (sudoku puzzle)
  (local [;;(has-duplicates? list) determines whether or not a given List, lisr,
          ;; has duplicate elements or not 
          ;;has-duplicates?: (listof Any) -> Bool
          (define (has-duplicates? list)
            (cond [(empty? list) false]
                  [else (or (member? (first list) (rest list))
                            (has-duplicates? (rest list)))]))
          
          ;;(duplicates-in-columns? puzzle c) determines if their are any
          ;; duplicates in the columns of the given Puzzle, puzzle. c is
          ;; set to 0 and counts up to 8, to represent 9 columns
          ;;duplicates-in-columns?: Puzzle Nat -> Bool
          (define (duplicates-in-columns? puzzle c)
            (cond [(= c 9) false]
                  [else (or (has-duplicates? 
                             (map (lambda (x) (list-ref x c)) puzzle))
                            (duplicates-in-columns? puzzle (add1 c)))]))
          
          ;;(duplicates-in-rows? puzzle) determines if their are any
          ;; duplicates in the rows of the given Puzzle, puzzle
          ;;duplicates-in-rows?: Puzzle -> Bool
          (define (duplicates-in-rows? puzzle) 
            (foldr (lambda (x y) (or (has-duplicates? x) y)) false puzzle))
          
          ;;(solved? puzzle) determines whether or not a given Puzzle, puzzle
          ;; is a valid sudoku solution
          ;;solved?: Puzzle -> Bool
          (define (solved? puzzle)
            (and (equal? (get-pos-of-blank puzzle) 'no-blanks)
                 (not (or  (duplicates-in-columns? puzzle (sub1 col-origin))
                           (duplicates-in-rows? puzzle)))))]
    (find-final puzzle neighbours solved?)))

;;Tests
(check-expect (sudoku no-sol-2) false)
(check-expect (sudoku easy) '((2 4 5 8 9 3 7 1 6)
                              (8 1 3 5 7 6 9 2 4)
                              (7 6 9 2 1 4 5 3 8)
                              (5 3 6 9 8 7 1 4 2)
                              (4 9 2 1 6 5 8 7 3)
                              (1 7 8 4 3 2 6 5 9)
                              (6 8 4 7 2 1 3 9 5)
                              (3 2 1 6 5 9 4 8 7)
                              (9 5 7 3 4 8 2 6 1)))
(check-expect (sudoku requires-4) '((2 4 5 8 9 3 7 1 6)
                                    (8 1 3 5 7 6 9 2 4)
                                    (7 6 9 2 1 4 5 3 8)
                                    (5 3 6 9 8 7 1 4 2)
                                    (4 9 2 1 6 5 8 7 3)
                                    (1 7 8 4 3 2 6 5 9)
                                    (6 8 4 7 2 1 3 9 5)
                                    (3 2 1 6 5 9 4 8 7)
                                    (9 5 7 3 4 8 2 6 1)))
(check-expect (sudoku requires-6) '((2 4 5 8 9 3 7 1 6)
                                    (8 1 3 5 7 6 9 2 4)
                                    (7 6 9 2 1 4 5 3 8)
                                    (5 3 6 9 8 7 1 4 2)
                                    (4 9 2 1 6 5 8 7 3)
                                    (1 7 8 4 3 2 6 5 9)
                                    (6 8 4 7 2 1 3 9 5)
                                    (3 2 1 6 5 9 4 8 7)
                                    (9 5 7 3 4 8 2 6 1)))
(check-expect (sudoku requires-8) '((2 4 5 8 9 3 7 1 6)
                                    (8 1 3 5 7 6 9 2 4)
                                    (7 6 9 2 1 4 5 3 8)
                                    (5 3 6 9 8 7 1 4 2)
                                    (4 9 2 1 6 5 8 7 3)
                                    (1 7 8 4 3 2 6 5 9)
                                    (6 8 4 7 2 1 3 9 5)
                                    (3 2 1 6 5 9 4 8 7)
                                    (9 5 7 3 4 8 2 6 1)))
(check-expect (sudoku requires-7) '((2 4 5 8 9 3 7 1 6)
                                    (8 1 3 5 7 6 9 2 4)
                                    (7 6 9 2 1 4 5 3 8)
                                    (5 3 6 9 8 7 1 4 2)
                                    (4 9 2 1 6 5 8 7 3)
                                    (1 7 8 4 3 2 6 5 9)
                                    (6 8 4 7 2 1 3 9 5)
                                    (3 2 1 6 5 9 4 8 7)
                                    (9 5 7 3 4 8 2 6 1)))
(check-expect (sudoku wikipedia) '((5 3 4 6 7 8 9 1 2)
                                   (6 7 2 1 9 5 3 4 8)
                                   (1 9 8 3 4 2 5 6 7)
                                   (8 5 9 7 6 1 4 2 3)
                                   (4 2 6 8 5 3 7 9 1)
                                   (7 1 3 9 2 4 8 5 6)
                                   (9 6 1 5 3 7 2 8 4)
                                   (2 8 7 4 1 9 6 3 5)
                                   (3 4 5 2 8 6 1 7 9)))
(check-expect (sudoku hard) '((8 1 2 7 5 3 6 4 9)
                              (9 4 3 6 8 2 1 7 5)
                              (6 7 5 4 9 1 2 8 3)
                              (1 5 4 2 3 7 8 9 6)
                              (3 6 9 8 4 5 7 2 1)
                              (2 8 7 1 6 9 5 3 4)
                              (5 2 1 9 7 4 3 6 8)
                              (4 3 8 5 2 6 9 1 7)
                              (7 9 6 3 1 8 4 5 2)))



















