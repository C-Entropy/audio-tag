(in-package #:format-abstract)

(defun determine-flac (flac-stream)
  "determine-flac"

  (when (>= (stream-size flac-stream) 4)
    (stream-seek flac-stream 0 :start)
    (when (string= +flac+  (stream-read-string flac-stream 4))
      (return-from determine-flac '("flac"))))
  NIL)

;; (defun read-flac-stream (flac-stream))

(defclass-easy flac ()
    ((flag :initform "fLaC" :accessor flag :allocation :class)
     metadata-blocks
     audio-frame-pos
     temp-vorbis)
    "class Flac")

(defclass-easy metadata-block ()
    (lastp block-type body-len block-body)
    "class block")

(defclass-easy block-vorbis ()
    (vendor-length vendor-string comments-count comments)
    "class vorbis")

(defclass-easy block-streaminfo ()
    (min-block-size
     max-block-size min-frame-size
     max-frame-size sample-rate
     num-channels bits-per-sample
     total-samples md5-sig)
    "class block streaminfo")

(defclass-easy block-padding ()
    (padding)
    "for blocks we don't interst")

(defun -parse-block-header- (flac-stream)
  (let ((block-header (stream-read-u4 flac-stream)))
    (list (load-byte 1 31 block-header)
	  (load-byte 7 24 block-header)
	  (load-byte 24 0 block-header))))

(defun -parse-just-read- (flac-stream len)
  "just read in bytes, don't parse them"
  (stream-read-byte-sequence flac-stream len)
  ;; (stream-read-n-bytes flac-stream len)
  )

(defgeneric -parse-block-body- (block-body flac-stream len)
  (:documentation "parse block body"))

(defmethod -parse-block-body- ((stream-info block-streaminfo) flac-stream len)
  (let ((temp-val))
    (with-slots (min-block-size max-block-size min-frame-size max-frame-size sample-rate num-channels bits-per-sample total-samples md5-sig) stream-info
      (setf min-block-size (stream-read-u2 flac-stream))
      (setf max-block-size (stream-read-u2 flac-stream))
      (setf min-frame-size (stream-read-u3 flac-stream))
      (setf max-frame-size (stream-read-u3 flac-stream))
      (setf temp-val (stream-read-u8 flac-stream));;we read in an u8 as a temp-val and then parse it
      (setf sample-rate (load-byte 20 44 temp-val))
      (setf num-channels (1+ (load-byte 3 41 temp-val)))
      (setf bits-per-sample (1+ (load-byte 5 36 temp-val)))
      (setf total-samples (load-byte 36 0 temp-val))
      (setf md5-sig (stream-read-u16 flac-stream)))))

(defun -parse-comment-string- (string)
  (let ((=-position (position #\= string)))
    (assert (numberp =-position))
    (cons (intern (nstring-upcase (subseq string 0 =-position)) :keyword)
	  (subseq string (1+ =-position)))))

(defmethod -parse-block-body- ((vorbis block-vorbis) flac-stream len)
  (with-slots (vendor-length vendor-string comments-count comments) vorbis
    (setf vendor-length (stream-read-u4 flac-stream :b))
    (setf vendor-string (stream-read-string flac-stream vendor-length))
    (setf comments-count (stream-read-u4 flac-stream :b))
    (setf comments (make-hash-table))
    (dotimes (step comments-count)
      (push-pair-hash (-parse-comment-string- (stream-read-utf-8-string flac-stream (stream-read-u4 flac-stream :b))) comments))))

(defmethod -parse-block-body- ((padding block-padding) flac-stream len)
  (setf (padding padding) (-parse-just-read- flac-stream len)))

(defun -block-num-name- (block-num)
  ;; (format t "parse body ~A ~A~%" block-header (third block-header))
  (ecase block-num
    (0 :streaminfo)
    (1 :padding)
    (2 :application)
    (3 :seektable)
    (4 :comment)
    (5 :cuesheet)
    (6 :picture)))

(defun -get-body-instance- (block-num)
  (case block-num
    (0 'block-streaminfo)
    (4 'block-vorbis)
    (otherwise 'block-padding)))

(defun -block-name-num- (block-name)
  ;; (format t "parse body ~A ~A~%" block-header (third block-header))
  (ecase block-name
    (:streaminfo  0)
    (:padding     1)
    (:application 2)
    (:seektable   3)
    (:comment     4)
    (:cuesheet    5)
    (:picture     6)))

(defun -get-block- (flac block-name)
  "get metadata block from flac"
  (cdr (assoc (-block-name-num- (get-keyword block-name)) (metadata-blocks flac))))

(defun -get-block-body- (flac block-name)
  (block-body (-get-block- flac block-name)))

(defun -get-vorbis- (flac)
  "get block vorbis of flac"
  (-get-block-body- flac :comment))

(defun -get-vorbis-comments- (flac)
  "get block vorbis comment of flac"
  (comments (-get-vorbis- flac)))

(defun -parse-metadata-block- (flac-stream)
  "Make a flac header from current position in stream"
  ;; (format t "pos: ~A~%" (stream-seek flac-stream))
  (let ((block-header (-parse-block-header- flac-stream))
	(metadata-block (make-instance 'metadata-block)))
    (with-slots (lastp block-type body-len block-body) metadata-block
      (setf lastp (first block-header))
      (setf block-type (second block-header))
      (setf body-len (third block-header))
      (setf block-body (make-instance (-get-body-instance- block-type)));;make a instance using block-type and pass it to -parse-block-body-
      (-parse-block-body- block-body
			  flac-stream
			  body-len))
    metadata-block))

(defun -parse-metadata-blocks- (flac-stream)
  "-parse-flac-metadata-blocks-"
  (stream-seek flac-stream 4 :start)
  (let ((blocks))
    (labels ((parse-blocks ()
	       ((lambda (metadata-block)
		  (push (cons (block-type metadata-block) metadata-block) blocks)
		  (unless (= 1 (lastp metadata-block));;unless get to the least block, continue parse blocks.
		    (parse-blocks)))
		(-parse-metadata-block- flac-stream))))
      (parse-blocks))
    (nreverse blocks)))

(defmethod parse-audio-stream ((flac-obj flac) flac-stream)
  (setf (metadata-blocks flac-obj) (-parse-metadata-blocks- flac-stream))
  (setf (audio-frame-pos flac-obj) (stream-seek flac-stream))
  (setf (temp-vorbis flac-obj) (-get-vorbis-comments- flac-obj)))

(defmethod get-audio-tag ((flac-file flac) tag-key)
  (gethash tag-key (temp-vorbis flac-file)))

(defun show-hash (hash)
  (maphash (lambda (key value)
	     (format t "~A: ~A~%" key value))
   hash))

(defmethod show-tags ((flac-file flac))
  (show-hash (temp-vorbis flac-file)))

(defmethod set-audio-tag ((flac-file flac) tag-key tag-value)
  (if (listp tag-value)
      (setf (gethash tag-key (temp-vorbis flac-file)) tag-value)
      (setf (gethash tag-key (temp-vorbis flac-file)) (list tag-value))))

(defmethod append-audio-tag ((flac-file flac) tag-key tag-value)
  (setf (gethash tag-key (temp-vorbis flac-file))
	(append tag-value (gethash tag-key (temp-vorbis flac-file)))))

(defmethod set-audio-tags ((flac-file flac) audio-tag)
  (setf (temp-vorbis flac-file) audio-tag))


(defun -commit-tag- (tags)
  "gen new tags"
  (let ((comments NIL))
    (maphash (lambda (key value)
	       (dolist (v value)
		 (push (-gen-comment-string- key v) comments)))
	     tags)
    comments))

(defmethod commit-audio ((flac-file flac))
  (setf (comments (-get-vorbis- flac-file))
	(-commit-tag- (temp-vorbis flac-file)))
  (setf (vendor-string (-get-vorbis- flac-file))
	audio-tag:*vendor-string*)
  (setf (vendor-length (-get-vorbis- flac-file))
	(flex:char-length (vendor-string (-get-vorbis- flac-file))))
  (let ((len 0)
	(count 0))
    (dolist (comment (-get-vorbis-comments- flac-file))
      (setf len (+ len (car comment)))
      (setf count (1+ count)))
    (setf (comments-count (-get-vorbis- flac-file))
	  count)
    (setf (body-len (-get-block- flac-file :comment))
	  (+ len;;len of all comments
	     (vendor-length (-get-vorbis- flac-file));; len of vendor
	     8;;len of vendor-length and comments-count
	     (* 4 count);;len of len for each comment
	     )))
  (labels ((set-last (blocks)
	     (if (cdr blocks)
		 (progn (set-last (cdr blocks))
			(setf (lastp (cdr (car blocks))) 0))
		 (setf (lastp (cdr (car blocks))) 1))))
    (set-last (metadata-blocks flac-file))))

(defun -write-identifier- (out-stream)
  "write fLaC to out-stream"
  (stream-write-string +flac+ out-stream))

(defgeneric -write-block-body- (block-body flac-stream)
  (:documentation "write block body"))

(defmethod -write-block-body- ((stream-info block-streaminfo) outstream)
  (let ((temp-val 0))
    (with-slots (min-block-size max-block-size min-frame-size max-frame-size sample-rate num-channels bits-per-sample total-samples md5-sig) stream-info
      (stream-write-u2 min-block-size outstream)
      (stream-write-u2 max-block-size outstream)
      (stream-write-u3 min-frame-size outstream)
      (stream-write-u3 max-frame-size outstream)
      (dump-byte 20 44 sample-rate temp-val)
      (dump-byte 3 41 (1- num-channels) temp-val)
      (dump-byte 5 36 (1- bits-per-sample) temp-val)
      (dump-byte 36 0 total-samples temp-val)
      (stream-write-u8 temp-val outstream)
      (stream-write-u16 md5-sig outstream))))

(defun -gen-comment-string- (key value)
  (let ((string (concatenate 'string (symbol-name key) "=" value)))
    (cons (flexi-streams:octet-length (flexi-streams:string-to-octets string
								      :external-format :utf-8))
	  string)))

(defun -write-comment- (comment outstream)
  (stream-write-u4 (car comment) outstream :b)
  (stream-write-utf-8-string (cdr comment) outstream))

(defmethod -write-block-body- ((vorbis block-vorbis) outstream)
    (with-slots (vendor-length vendor-string comments-count comments) vorbis
      (stream-write-u4 vendor-length outstream :b)
      (stream-write-string vendor-string outstream)
      (stream-write-u4 comments-count outstream :b)
      (labels ((write-comment (comments)
		 (when comments
		   (-write-comment- (car comments) outstream)
		   (write-comment (cdr comments)))))
	(write-comment comments))))

(defmethod -write-block-body- ((padding block-padding) outstream)
  (stream-write-byte-sequence (padding padding) outstream))

;; (defgeneric body-len (block-body)
;;   (:documentation "calculate len of block body"))

;; (defmethod body-len ((streaminfo block-streaminfo))
;;   34)

;; (defmethod body-len ((vorbis block-vorbis))

;;   )

(defun -write-metadata-block- (metadata-block out-stream)
  (let ((block-header 0))
    ;; (format t "lastp: ~A~%block-type: ~A~%body-len: ~A~%" (lastp metadata-block) (block-type metadata-block) (body-len metadata-block))
    (dump-byte 1 31 (lastp metadata-block) block-header)
    (dump-byte 7 24 (block-type metadata-block) block-header)
    (dump-byte 24 0 (body-len metadata-block) block-header);;gen u4 for block headerx
    (stream-write-u4 block-header out-stream) ;;first we write block header
    )
    (-write-block-body- (block-body metadata-block) out-stream))

(defun -write-metadata-blocks- (metadata-blocks outstream)
  "-write -flac-metadata-blocks- to out-stream"
  (dolist (metadata-block metadata-blocks)
    (-write-metadata-block- (cdr metadata-block) outstream)))

(defmethod write-audio-file ((flac-file flac) out-stream)
  (-write-identifier- out-stream)
  (commit-audio flac-file)
  (-write-metadata-blocks- (metadata-blocks flac-file) out-stream)
  (stream-copy (format-abstract:file-path flac-file) (audio-frame-pos flac-file) out-stream))

;; (defun get-comment-len (flac-file)
;;   (dolist (body (metadata-blocks flac-file))
;;     (format t "~A: ~A~%" (block-type (cdr body)) (body-len (cdr body)))))

;; (defun get-stream-info (flac-file)
;;   (with-slots (min-block-size max-block-size min-frame-size max-frame-size
;; 	       sample-rate num-channels bits-per-sample total-samples md5-sig)
;;       (-get-block-body- flac-file "streaminfo")
;;       (format t "~{~A: ~}~%" (list min-block-size max-block-size min-frame-size
;; 				   max-frame-size sample-rate
;; 				   num-channels bits-per-sample total-samples
;; 				   md5-sig))))
