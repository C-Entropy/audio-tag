(in-package #:format-abstract)

(defun determine-mp3 (id3-stream)
  "determine-id3"

  (when (>= (stream-size id3-stream) 10)
    (stream-seek id3-stream 0 :start)
    (when (string= +id3+  (stream-read-string id3-stream 3))
      (let ((major-version NIL ;; ()
			   )
	    (revision-number NIL ;; ()
			     ))
	(return-from determine-mp3 (list "mp3" major-version revision-number)))))
  NIL)

;; (defun read-id3-stream (id3-stream))


(defclass-easy mp3 ()
    ((identifier :initform "ID3" :accessor flag :allocation :class)
     major-version
     revision-number
     flags
     size)
    "class Flac")

;; (defmethod parse-audio-stream ((id3-obj id3) id3-stream)
;;   "Parse an MP3 stream"

;;   (setf (metadata-blocks id3-obj) (-parse-metadata-blocks- id3-stream))
;;   (setf (audio-frame-pos id3-obj) (stream-seek id3-stream))
;;   (setf (temp-vorbis id3-obj) (-get-vorbis-comments- id3-obj)))
