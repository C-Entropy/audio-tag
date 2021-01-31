(defpackage #:utils
  (:use #:cl)
  (:export #:defclass-easy
	   #:find-function
	   #:get-keyword
	   #:parse
	   #:push-pair-hash
	   #:testf))

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
	   #:stream-write-u2
	   #:stream-write-u3
	   #:stream-write-u4
	   #:stream-write-u8
	   #:stream-write-u16
	   #:stream-write-u34
	   #:stream-write-utf-8-string
	   #:stream-write-string
	   #:with-audio-stream))

(defpackage #:format-abstract
  (:use #:cl
	#:utils
	#:stream
	#:osicat)
  (:export #:append-audio-tag
	   ;; #:commit-audio
	   ;; #:commit-tag
	   ;; #:get-fun
	   #:get-audio-tag
	   #:determine-audio-type
	   #:file-name
	   #:file-path
	   #:file-type
	   #:flac-file
	   #:parse-audio-stream
	   #:set-audio-tag
	   #:set-audio-tags
	   #:show-tags
	   #:write-audio-file))

(defpackage #:audio-tag
  (:use #:cl
	#:format-abstract
	#:stream
	#:utils)
  (:export #:*vendor-string*
	   #:make-audio
	   #:save-audio))
