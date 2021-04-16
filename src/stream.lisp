(defpackage #:stream
  (:use #:cl
	#:flexi-streams)
  (:export #:dump-byte
	   #:make-audio-stream
	   #:flexi-pathname
	   #:flexi-type
	   #:load-byte
	   #:parse-stream
	   #:stream-copy
	   #:stream-read-iso-string
	   #:stream-read-bytes
	   #:stream-read-byte-sequence
	   ;; #:stream-read-char
	   #:stream-read-n-bytes
	   #:stream-read-string
	   #:stream-read-u1
	   #:stream-read-u2
	   #:stream-read-u3
	   #:stream-read-u4
	   #:stream-read-u8
	   #:stream-read-u16
	   #:stream-read-u34
	   #:stream-read-utf-8-string
	   #:stream-seek
	   #:stream-size
	   #:stream-write-byte-sequence
	   #:stream-write-u1
	   #:stream-write-u2
	   #:stream-write-u3
	   #:stream-write-u4
	   #:stream-write-u8
	   #:stream-write-u16
	   #:stream-write-u34
	   #:stream-write-utf-8-string
	   #:stream-write-string
	   #:with-audio-stream))

(in-package #:stream)

(defun flexi-pathname (flexi-stream)
  (pathname (flexi-stream-stream flexi-stream)))

(defmacro with-audio-stream ((audio-stream audio-file &rest args) &body body)
  `(with-open-file (,audio-stream ,audio-file :element-type '(unsigned-byte 8) ,@args)
     (setf ,audio-stream (flexi-streams:make-flexi-stream ,audio-stream :external-format :utf-8))
     ,@body))

(defun stream-copy (infile pos outstream)
  (with-audio-stream (instream infile)
    (stream-seek instream pos :start)
    (let ((buffer (make-array 8192 :element-type '(unsigned-byte 8))))
      (loop for pos = (read-sequence buffer instream)
	    while (plusp pos)
	    do (write-sequence buffer outstream :end pos)))))

(defun flexi-type (flexi-stream)
  "get pathname-type from a flexi stream"

  (pathname-type (flexi-pathname flexi-stream)))

(defun stream-seek (stream &optional (offset 0) (from :current))
  "Move the FILE-POSITION of a stream"
  (ecase from
    (:start (file-position stream offset))
    (:current (file-position stream (+ (file-position stream) offset)))
    (:end (file-position stream (- (stream-size stream) offset)))))

(defun stream-size (flexi-stream)
  (file-length (flex:flexi-stream-stream flexi-stream)))

;; (defun stream-read-char (instream len)

;;   (let ((string
;; 	  (make-array 5 :fill-pointer 0 :adjustable t :element-type 'character)))
;;     (dotimes (char len)
;;       (vector-push-extend (read-char instream) string))
;;     string))

(defun load-byte (count pos byte)
  "a shortcut to read [count] bits start at [pos] from byte"
  (ldb (byte count pos) byte))

(defmacro dump-byte (count pos num byte)
  "a shortcut to set [count] bits num at [pos] for byte"
  `(setf (ldb (byte ,count ,pos) ,byte) ,num))

;; (defun stream-read-n-bytes (instream len &key (bits-per-byte 8) (endian :l))
;;   "read n byte, for each byte, read bist-per-byte bits"
;;   (let ((result 0)
;; 	(bytes (stream-read-byte-sequence instream len)))
;;     (when (eq :b endian)
;;       (setf bytes (nreverse bytes)))
;;     (labels ((read-bytes (count)
;; 	       (setf (ldb (byte bits-per-byte (* count 8)) result) (elt bytes count))
;; 	       (unless (= 0 count)
;; 		 (read-bytes (1- count)))))
;;       (nreverse bytes)
;;       (read-bytes (1- len)))
;;     result))

(defun stream-read-n-bytes (instream len &key (bits-per-byte 8) (endian :l))
  "read n byte, for each byte, read bist-per-byte bits"
  (let ((result 0))
    (ecase endian
      (:l (labels ((read-l (count)
		     (setf (ldb (byte bits-per-byte (* count 8)) result) (read-byte instream))
		     (unless (= 0 count)
		       (read-l (1- count)))))
	    (read-l (1- len))))

      (:b (labels ((read-b (count)
		     (setf (ldb (byte bits-per-byte (* count 8)) result) (read-byte instream))
		     (unless (= count len)
		       (read-b (1+ count)))))
	    (setf len (1- len))
	    (read-b 0))))
    result))

(defun stream-write-n-bytes (bytes outstream len &key (bits-per-byte 8) (endian :l))
  "read n byte, for each byte, read bist-per-byte bits"
  (ecase endian
      (:l (labels ((write-l (count)
		     (write-byte (ldb (byte bits-per-byte (* count 8)) bytes) outstream)
		     (unless (= 0 count)
		       (write-l (1- count)))))
	    (write-l (1- len))))
      (:b (labels ((write-b (count)
		     (write-byte (ldb (byte bits-per-byte (* count 8)) bytes) outstream)
		     (unless (= count len)
		       (write-b (1+ count)))))
	    (setf len (1- len))
	    (write-b 0)))))

(defun stream-read-byte-sequence (instream len)
  (let ((sequence (make-array len :element-type 'octet)))
    (read-sequence sequence instream)
    sequence))

(defun stream-write-byte-sequence (sequence outstream)
  (write-sequence sequence outstream))

(defun stream-read-string (instream len)
  (let ((string (make-string len :element-type 'character)))
    (read-sequence string instream)
    string))

(defun stream-write-string (string instream)
  (write-sequence string instream))

(defun stream-read-iso-string (instream len)
  "Read an ISO-8859-1 string of len"
  (flex:octets-to-string (stream-read-byte-sequence instream len) :external-format :iso-8859-1))

(defun stream-write-iso-string (string outstream)
  "Write an ISO-8859-1 string of len to outstream"
  (stream-write-byte-sequence (flex:string-to-octets string :external-format :iso-8859-1)
			      outstream))

(defun stream-read-utf-8-string (instream len)
  "Read an UTF-8 string of length LEN."

  (octets-to-string (stream-read-byte-sequence instream len)
		    :external-format :utf-8))

(defun stream-write-utf-8-string (string outstream)
  "Read an UTF-8 string of length LEN."

  (write-sequence string outstream)
  ;; (write-sequence (string-to-octets string
  ;; 				    :external-format :utf-8)
  ;; 		  outstream)
  )

(defun stream-read-u1 (instream)
  (read-byte instream))

(defun stream-write-u1 (byte outstream)
  (write-byte byte instream))

(defun stream-read-u2 (instream &optional (endian :l))
  (stream-read-n-bytes instream 2 :endian endian))

(defun stream-write-u2 (bytes outstream &optional (endian :l))
  (stream-write-n-bytes bytes outstream 2 :endian endian))

(defun stream-read-u3 (instream &optional (endian :l))
  (stream-read-n-bytes instream 3 :endian endian))

(defun stream-write-u3 (bytes outstream &optional (endian :l))
  (stream-write-n-bytes bytes outstream 3 :endian endian))

(defun stream-read-u4 (instream &optional (endian :l))
  (stream-read-n-bytes instream 4 :endian endian))

(defun stream-write-u4 (bytes outstream &optional (endian :l))
  (stream-write-n-bytes bytes outstream 4 :endian endian))

(defun stream-read-u8 (instream &optional (endian :l))
  (stream-read-n-bytes instream 8 :endian endian))

(defun stream-write-u8 (bytes outstream &optional (endian :l))
  (stream-write-n-bytes bytes outstream 8 :endian endian))

(defun stream-read-u16 (instream &optional (endian :l))
  (stream-read-n-bytes instream 16 :endian endian))

(defun stream-write-u16 (bytes outstream &optional (endian :l))
  (stream-write-n-bytes bytes outstream 16 :endian endian))

(defun stream-read-u34 (instream &optional (endian :l))
  (stream-read-n-bytes instream 34 :endian endian))

(defun stream-write-u34 (bytes outstream &optional (endian :l))
  (stream-write-n-bytes bytes outstream 34 :endian endian))
