(defsystem "audio-tag"
  :version "0.1.0"
  :author "I-Entropy"
  :license ""
  :depends-on ("flexi-streams" "osicat")
  :components ((:file "packages")
	       (:module "src" :depends-on ("packages")
                :components
                ((:file "utils")
		 (:file "stream")
		 (:module "audio-format" :depends-on ("utils" "stream")
		  :components ((:file "flac")
			       (:file "format-abstract" :depends-on ("flac"))))
		 (:file "audio-tag" :depends-on ("utils")))))
  ;; ((:file "packages")
	      ;;  (:module "src" :depends-on ("packages")
              ;;   :components
	      ;; 	((:module "audio-format"
	      ;; 	  :components
	      ;; 	  ((:file "flac")
	      ;; 	   (:file "format-abstract"  :depends-on ("flac"))))
	      ;; 	 (:file "audio-tag" :depends-on ("format-abstract")))))
  :description "tool to deal with audio tags. read and write"
  :in-order-to ((test-op (test-op "audio-tag/tests"))))

(defsystem "audio-tag/tests"
  :author "I-Entropy"
  :license ""
  :depends-on ("audio-tag"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "audio-tag"))))
  :description "Test system for audio-tag"
  :perform (test-op (op c) (symbol-call :rove :run c)))
