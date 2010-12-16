;;;; -*- Mode: Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- Package definition.
;;;

(in-package :iolib.common-lisp-user)

(defpackage :iolib.base
  (:extend/excluding :iolib.common-lisp
                     #:defun #:defmethod #:defmacro #:define-compiler-macro)
  (:extend :alexandria)
  (:export
   ;; Conditions
   #:bug #:iolib-bug
   #:subtype-error #:subtype-error-datum #:subtype-error-expected-supertype
   ;; Debugging
   #:*safety-checks*
   #:debug-only #:debug-only*
   #:production-only #:production-only*
   ;; Types
   #:function-designator
   #:character-designator
   #:sb8 #:sb16 #:sb32 #:sb64
   #:ub8 #:ub16 #:ub32 #:ub64
   #:ub8-sarray #:ub16-sarray #:ub32-sarray #:ub64-sarray
   #:ub8-vector #:ub16-vector #:ub32-vector #:ub64-vector
   ;; RETURN*
   #:return* #:lambda* #:defun #:defmethod
   #:defmacro #:define-compiler-macro
   ;; DEFOBSOLETE
   #:defobsolete
   #:signal-obsolete
   #:deprecation-warning
   #:deprecation-warning-function-name
   #:deprecation-warning-type
   #:deprecation-warning-reason
   ;; Reader utils
   #:define-syntax
   #:enable-reader-macro #:enable-reader-macro*
   #:disable-reader-macro #:disable-reader-macro*
   #:define-literal-reader
   #:unknown-literal-syntax #:unknown-literal-syntax-name
   ;; SPLIT-SEQUENCE
   #:split-sequence #:split-sequence-if #:split-sequence-if-not
   ;; Misc
   #:function-name #:function-name-p
   #:check-bounds #:join #:join* #:shrink-vector #:full-string
   ;; Matching
   #:multiple-value-case #:flags-case
   ;; Time
   #:timeout-designator #:positive-timeout-designator
   #:decode-timeout #:normalize-timeout #:clamp-timeout
   ))
