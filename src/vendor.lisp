(defpackage #:vendor
  (:use #:cl)
  (:export #:*vendor-string*))

(defparameter *vendor-string* "Audio-tag 0.0.1"
  "string represent package name and version")
