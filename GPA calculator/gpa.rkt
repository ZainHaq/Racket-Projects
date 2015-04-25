;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname gpa) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;;Useful constant
(define sum-identity 0)

(define-struct student-record (name id grades))
;;A Student-Record is a (make-student-record Str Nat (listof Num))

;;(gpa sr-x) consumes a Student-Record, sr-x and produces the average of the 
;; grades in sr-x
;;gpa: Student-Record -> (anyof Num Sym)
;;Examples: 
(check-expect (gpa (make-student-record "Zain" 1 '(100 100))) 100)
(check-expect (gpa (make-student-record "Joe" 2 '(100 50))) 75)

(define (gpa sr-x)
  (local [(define lo-grades (student-record-grades sr-x))
          ;;(sum-of-grades lo-grades) computes the sum of all the grades(Num)
          ;; in a given, lo-grades
          ;;sum-of-grades: (listof Num) -> Num
          (define (sum-of-grades lo-grades)
            (cond
              [(empty? lo-grades) sum-identity]
              [else (+ (first lo-grades) 
                       (sum-of-grades (rest lo-grades)))]))] 
  (cond
    [(empty? lo-grades) 'nogrades]
    [else (/ (sum-of-grades lo-grades)
             (length lo-grades))])))

;;Tests:
(check-expect (gpa (make-student-record "John" 3 '(50 60))) 55)
(check-expect (gpa (make-student-record "James" 4 '(70 50 30))) 50)
(check-expect (gpa (make-student-record "Jon" 5 empty)) 'nogrades)
(check-expect (gpa (make-student-record "J-lo" 6 '(70 50 30 40))) 47.5)
(check-expect (gpa (make-student-record "Jay-Z" 7 '(10 60))) 35)
(check-expect (gpa (make-student-record "Jay-Leno" 8 '(80 70 40 10))) 50)
(check-expect (gpa (make-student-record "Jimmy" 9 '(10 10 10 20))) 12.5)


