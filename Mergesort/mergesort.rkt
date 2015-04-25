;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname mergesort) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;**************************************************
;; Programmer: Zain Haq
;; Last modified: December 1st 2014
;;**************************************************

;;(mergesort list comparator-fn) consumes a list, list and a comparator
;; function, comparator-fn and produces a sorted list based on comparator-fn
;; using the mergesort algorithim, which essentially splits list into sublists
;; and solves those sublists and merges those subslists back together at the end
;;mergesort: (listof X) (X X -> Bool) -> (listof X)
;;Examples:
(check-expect (mergesort '(3 1 2) >) '(3 2 1))
(check-expect (mergesort '(3 1 2) <) '(1 2 3))

(define (mergesort list comparator-fn)
  (local [(define half-list-length (/ (length list) 2))
          ;;(merge list1 list2) consumes two sorted lists, list1 and list2 and
          ;; merges them together
          ;;merge: (listof X) (listof X) -> (listof X)
          (define (merge list1 list2)
            (cond
              [(and (cons? list1) (empty? list2)) list1]
              [(and (empty? list1) (cons? list2)) list2]
              [(comparator-fn (first list1) (first list2)) 
               (cons (first list1) (merge (rest list1) list2))]
              [else (cons (first list2) (merge list1 (rest list2)))]))
          
          ;;(take list n) consumes a list, list and an integer, n, and produces 
          ;; the first n elements of the list, or the whole list if it contains 
          ;; less than n elements
          ;;take: (listof X) Nat -> (listof X)
          (define (take list n)
            (cond
              [(or (empty? list) (= n 0)) empty]
              [else (cons (first list) (take (rest list) (sub1 n)))]))]
    (cond
      [(empty? list) empty]
      [(empty? (rest list)) list]
      [else (merge (mergesort (take list (ceiling half-list-length)) 
                              comparator-fn)
                   (mergesort (take (reverse list) (floor half-list-length)) 
                              comparator-fn))])))

;;Tests:
(check-expect (mergesort empty >) empty)
(check-expect (mergesort '(1) <) '(1))
(check-expect (mergesort (list "b" "a" "c") string<?) (list "a" "b" "c"))
(check-expect (mergesort (list "b" "a" "c") string>?) (list "c" "b" "a"))
(check-expect (mergesort '(1 2 3 4 5 6 7) >) '(7 6 5 4 3 2 1))
(check-expect (mergesort '(1 2 3 4 5 6 7) <) '(1 2 3 4 5 6 7))
(check-expect (mergesort '(1 2 3 4 5 6) <) '(1 2 3 4 5 6))


