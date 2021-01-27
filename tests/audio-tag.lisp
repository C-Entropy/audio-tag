(defpackage audio-tag/tests/audio-tag
  (:use :cl
        :audio-tag
        :rove))
(in-package :audio-tag/tests/audio-tag)

;; NOTE: To run this test file, execute `(asdf:test-system :audio-tag)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
