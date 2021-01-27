(in-package #:format-abstract)

(defclass-easy file ()
    (file-path
     file-name
     file-type)
    "class use to hold info on file itself")

(defclass-easy flac-file (flac file)
    ())

;; (declaim (inline determine-audio-type
;; 		 -get-fun-
;; 		 parse-audio-stream))
(defparameter *determine-funs* (list #'determine-flac
				     ;; #'determine-mp3
				     )
  "Funs used to determine audio type")

;; (defun determine-audio-type (target &optional (type :file))
;;   "determine audio type"
;;   (funcall (-get-fun- (flexi-type target)
;; 		      "determine")
;; 	   target))


(defun -get-fun- (audio-type fun-name)
  "Return function used to make corresponding obj"
  (if (find-function (concatenate 'string (nstring-upcase fun-name) "-" (string-upcase audio-type))
		     :format-abstract)
      (find-function (concatenate 'string (nstring-upcase fun-name) "-" (string-upcase audio-type))
		     :format-abstract)
      NIL
      ;; (error (concatenate 'string "Can't find function: " fun-name "-" audio-type " check if name of your audio is wrong"))
      ))


(defun determine-audio-type (target &optional (type :file))
  "determine audio type"
  (ecase type
    (:stream ((lambda (file-type)
		(when (and file-type
			   (-get-fun- file-type "determine")
			   (funcall (-get-fun- file-type "determine")
				    target))
		  (return-from determine-audio-type file-type))
		(let ((result (testf *determine-funs* target)))
		  (if result
		      result
		      (error (concatenate 'string "can't find audio-type for file: " (namestring (flexi-pathname target))
					  "~% check 1.if binary of your file is conrrect~%2. if your audio type is support")))))
	      (flexi-type target)))
    (:file (with-audio-stream (audio-stream target)
	     (determine-audio-type audio-stream :stream)))))


(defgeneric parse-audio-stream (audio-obj audio-stream)
  (:documentation "fill audio-obj using info get from audio-stream"))


(defgeneric get-audio-tag (audio-file tag-key)
  (:documentation "get tag info of audio-file using tag-key"))

(defgeneric show-tags (audio-file)
  (:documentation "show all tags of audio-file"))

(defgeneric set-audio-tag (audio-file tag-key tag-value)
  (:documentation "set tag info of audio-file using tag-key and value, multipule value is support if file format support.e.g. '(audio-file Artist a b)) will turn to (Artist a) (Artist b)"))

(defgeneric append-audio-tag (audio-file tag-key tag-value)
  (:documentation "append tag-value to tag-key, multipule value is support if file format support.e.g. '(audio-file Artist a b)) will turn to (Artist a) (Artist b)"))

(defgeneric commit-audio (audio-file)
  (:documentation "commit tag change, not changed tag will remain"))

(defgeneric write-audio-file (audio-file out-file)
  (:documentation "write audio-file to out-file"))

;; (defgeneric set-tag-artist (audio-file tag-value)
;;   (:documentation "set tag info of audio-file using tag-value, multipule value is support if file format support.e.g. '(audio-file '(a b))) will turn to (Artist a) (Artist b)"))

;; (defun parse-audio-stream (audio-type audio-stream)
;;   (funcall (-get-fun- audio-type
;; 		      "parse")
;; 	   audio-stream))

;; (defun make-audio (audio-stream audio-type)
;;   ())
