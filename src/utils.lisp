(in-package #:utils)

(defun get-keyword (string)
  (intern (string-upcase string) :keyword))

(defun slot->class-slot (slot)
  (if (listp slot)
      slot
      `(,slot :initarg ,(intern (symbol-name slot) "KEYWORD")
	      :accessor ,slot)))

(defun push-pair-hash (item hash-table)
  (push (cdr item) (gethash (car item) hash-table)))


(defmacro defclass-easy (class-name supper-class slots &optional (doc "None") )
  "macro for make new class easier(don't support parents yet)"
  `(defclass ,class-name ,supper-class
     ,(mapcar #'slot->class-slot slots)
     (:documentation ,doc)))

;; (defmacro defclass-easy (class-name supper-class slots &optional (doc "None") )
;;   "macro for make new class easier(don't support parents yet)"
;;   `(defclass ,class-name ,supper-class
;;      ,(mapcar #'(lambda (slot-name)
;; 		  `(,slot-name
;; 		    :initarg ,(intern (symbol-name slot-name) "KEYWORD")
;; 		    :accessor ,slot-name))
;;        slots)
;;      (:documentation ,doc)))

(defun mapf (functions &rest args)
  (declare (dynamic-extent args))
  "Applies each function to the arguments. Returns a list of results."
  (mapcar (lambda (function)
            (apply function args))
          functions))

(defun testf (functions item)
  "Return the first result of function which return not NIL, otherwise, NIL."

  (mapc (lambda (function)
	  (when (funcall function item)
	    (return-from testf (funcall function item))))
	functions)
  NIL)


;; (declaim (inline find-function))

(defun find-function (fun-name &optional (package *package*))
  "return function found, if none, return NIL"
  (if (find-symbol fun-name package)
      (symbol-function (find-symbol fun-name package))
      NIL))

(defun parse (subject key-fun value fun)
  ((lambda (key value)
   (when (and (setf key (funcall key-fun subject))
	      (setf value (funcall value-fun subject)))
       (floor key value)))
   NIL NIL))
