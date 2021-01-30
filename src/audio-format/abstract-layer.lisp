(in-package #:abstract-layer)

;; (defparameter *determine-funs* (list #'determine-flac
;; 				     ;; #'determine-mp3
;; 				     )
;;   "Funs used to determine audio type")


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
		  (return-from determine-audio-type (list file-type)))
		(let ((result (testf *determine-funs* target)))
		  (if result
		      result
		      (error (concatenate 'string "can't find audio-type for file: " (namestring (flexi-pathname target))
					  "~% check 1.if binary of your file is conrrect~%2. if your audio type is support 3. other reason")))))
	      (flexi-type target)));;get file shuffix from a flexi-stream
    (:file (with-audio-stream (audio-stream target)
	     (determine-audio-type audio-stream :stream)))))
