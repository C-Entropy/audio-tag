(in-package #:format-abstract)

(defclass-easy file ()
    (file-path
     file-name
     file-type)
    "class use to hold info on file itself")

(defclass-easy flac-file (flac file)
    ())

(defclass-easy mp3-file (mp3 file)
    ())

(defparameter *determine-funs*
  (list #'determine-flac
	#'determine-mp3))

(defparameter +flac+ "fLaC"
  "constant for flac identifer")

(defparameter +ID3+ "ID3"
  "constant for id3 identifer")

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

(defgeneric set-audio-tags (audio-file audio-tag)
  (:documentation "set audio-tag body directly to audio-tag"))

(defgeneric commit-audio (audio-file)
  (:documentation "commit tag change, not changed tag will remain"))

(defgeneric write-audio-file (audio-file out-file)
  (:documentation "write audio-file to out-file"))


(defun -get-type-fun- (audio-type)
  (case (get-keyword audio-type)
    (:mp3 #'determine-mp3)
    (:flac #'determine-flac)))

(defun determine-audio-type (target &optional (type :file))
  "determine audio type"
  (ecase type
    (:stream ((lambda (file-type)
		(when (and file-type
			   (-get-type-fun- file-type)
			   (funcall (-get-type-fun- file-type)
				    target))
		  (return-from determine-audio-type (funcall (-get-type-fun- file-type)
				    target);; (list file-type)
		    ))
		(let ((result (testf *determine-funs* target)))
		  (if result
		      result
		      (error (concatenate 'string "can't find audio-type for file: " (namestring (flexi-pathname target))
					  "~% check 1.if binary of your file is conrrect~%2. if your audio type is support 3. other reason")))))
	      (flexi-type target)));;get file shuffix from a flexi-stream
    (:file (with-audio-stream (audio-stream target)
	     (determine-audio-type audio-stream :stream)))))
