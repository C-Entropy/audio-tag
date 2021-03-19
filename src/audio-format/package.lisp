(defpackage #:format-abstract
  (:use #:cl
	#:utils
	#:vendor
	#:stream
	#:osicat)
  (:export #:append-audio-tag
	   ;; #:commit-audio
	   ;; #:commit-tag
	   ;; #:get-fun
	   #:get-tags
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
