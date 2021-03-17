(defsystem "audio-tag"
  :version "0.0.1"
  :author "I-Entropy"
  :license "BSD-2-Clause License"
  :depends-on ("flexi-streams" "osicat")
  :components ((:module "src"
                :components
                ((:file "utils")
		 (:file "vendor")
		 (:file "stream")
		 (:module "binary" :depends-on ("utils" "stream")
		  :components ((:file "package")
			       (:file "binary" :depends-on ("package"))))
		 (:module "audio-format" :depends-on ("utils" "stream" "binary" "vendor")
		  :components ((:file "package")
			       (:file "flac" :depends-on ("package"))
			       (:file "mp3" :depends-on ("package"))
			       (:file "format-abstract" :depends-on ("flac" "mp3" "package"))))
		 (:file "package" :depends-on ("audio-format" "stream" "utils" "vendor"))
		 (:file "audio-tag" :depends-on ("package")))))
  :description "tool to deal with audio tags. read, view and write"
  :in-order-to ((test-op (test-op "audio-tag/tests"))))

(defsystem "audio-tag/tests"
  :author "I-Entropy"
  :license "BSD-2-Clause License"
  :depends-on ("audio-tag"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "audio-tag"))))
  :description "Test system for audio-tag"
  :perform (test-op (op c) (symbol-call :rove :run c)))
