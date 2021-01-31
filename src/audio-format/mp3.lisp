(in-package #:format-abstract)

(defun determine-mp3 (id3-stream)
  "determine-id3"
  (let ((valid)
	(id3)
	(version)
	(revision)
	(tag)
	(result))
    (when (> (stream-size id3-stream) 10)
      (stream-seek id3-stream 0 :start)
      (setf id3 (stream-read-string id3-stream 3))
      (setf version (stream-read-u1 id3-stream))
      (setf revision (stream-read-u1 id3-stream))
      (when (> (stream-size id3-stream) 128)
	(stream-seek id3-stream 128 :end)
	(setf tag (stream-read-iso-string id3-stream 3)))
      (setf valid (or (string= tag "TAG")
		      (and (string= +ID3+ id3)
			   (or (= 2 version) (= 3 version) (= 4 version))))))
    (stream-seek id3-stream 0 :start)
    (if valid
	(progn (when id3
		 (push (list "mp3" "v2" version revision) result))
	       (when tag
		 (push (list "mp3" "v1" 1 ) result));;which version this exactly is???
	       (return-from determine-mp3 (list '"mp3" result)))
	NIL)))


;; (defun read-id3-stream (id3-stream))

(defclass-easy id3-header ()
    ((identifer :initform "ID3" :accessor identifier :allocation :class)
     major-version
     revision-number
     flags
     size))

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
