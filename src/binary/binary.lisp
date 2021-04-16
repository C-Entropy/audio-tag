(in-package #:binary)

(defun binary-slot->class-slot (slot)
  `(,(first slot) :initarg ,(intern (symbol-name (first slot)) "KEYWORD")
	  :initform NIL
		  :accessor ,(first slot)))

(defun stream->binary (slot stream)
  `(setf ,(first slot) (read-binary ,@(cdr slot) ,stream)))

(defun binary->stream (slot stream)
  (write-binary (first slot) stream))

(defmacro define-binary (binary-name slots)
  (with-gensyms (objvar typevar streamvar)
    `(progn
       (defclass ,binary-name NIL
	 ,(mapcar #'binary-slot->class-slot slots))

       (defmethod read-binary ((,typevar ',binary-name) ,streamvar)
	 (let ((,objvar (make-instance ',binary-name)))
	   (with-slots ,(mapcar #'first slots) ,objvar
	     ,@(mapcar #'(lambda (slot)
			   (stream->binary slot streamvar))
		       slots))
	   ,objvar))

       (defmethod write-binary ((,objvar ,binary-name) ,streamvar)
	 (with-slots ,(mapcar #'first slots) ,objvar
	   ,@(mapcar #'(lambda (slot)
			 (binary->stream slot streamvar))
		     slots))))))
