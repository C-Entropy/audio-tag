(in-package :audio-tag)

(defgeneric make-audio-obj (audio-type)
  (:documentation "make audio obj depends on audio-type"))

(defmethod make-audio-obj ((audio-type (eql :FLAC)))
  (make-instance 'flac-file))

(defun -make-audio-obj- (audio-type)
  (make-audio-obj (get-keyword audio-type)))

(defun make-audio (audio-file)
  "Make a obj audio on audio-file"

  (with-audio-stream (audio-stream audio-file)
    (let ((audio-type (car (determine-audio-type audio-stream :stream))))
      (unless audio-type
	(error "unrecognized audio format"))
      (let ((audio-obj (-make-audio-obj- audio-type)))
	(setf (file-path audio-obj) (flexi-pathname audio-stream))
	(setf (file-name audio-obj) (flexi-pathname audio-stream))
	(setf (file-type audio-obj) audio-type)
	(parse-audio-stream audio-obj audio-stream)
	audio-obj))))

(defun save-audio (audio-obj ;; &optional
		   out-file &key (if-exists :error))
  "save audio file. If no tag changed, no write will be performed, save file at original place and name, if no out-file is specified
auto correct suffix according if correct is T"
  (when (string= (namestring (file-path audio-obj)) (namestring out-file))
    (error "don't support write file back directly now, please use a temp file manually"))
  (with-audio-stream (audio-stream out-file :direction :output :if-exists if-exists :if-does-not-exist :create)
    (write-audio-file audio-obj audio-stream)))
