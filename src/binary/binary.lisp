(in-package #:binary)

(defmacro define-binary (packet-name ;; static-size-p
			 slots
			 &key size-packet opcode)
  (with-gensyms (objvar typevar datavar)
    `(progn
       (defclass ,packet-name NIL
	 ,(mapcar #'packet-slot->class-slot slots))

       (defmethod obj-to-data ((,objvar ,packet-name))
	 (with-slots ,(mapcar #'first slots) ,objvar
	   (append ,@(mapcar #'packet-slot->byte slots))))

       ;; (defmethod static-size-p ((,objvar ,packet-name))
       ;; 	 ,static-size-p)

       (defmethod size-packet ((,objvar ,packet-name))
	 ,(if size-packet
	      `(with-slots ,(mapcar #'first slots) ,objvar
		,size-packet)
	      "no size-packet defined"))

       (defmethod clx-proto-frame-opcode ((,objvar ,packet-name))
	 ,(if opcode
	      opcode
	      `(error (concatenate 'string "error-opcode-not-set " (symbol-name ',packet-name)))))

       (defmethod -clx-xim-read-frame- (,datavar (,typevar (eql ,(get-keyword packet-name))) &key)
	 (let ((,objvar (make-instance ',packet-name)))
	   (with-slots ,(mapcar #'first slots) ,objvar
	     ,@(mapcar #'(lambda (slot)
			   (data->slot slot datavar))
		       slots))
	   ,objvar)))))
