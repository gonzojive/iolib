;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-

(defsystem :iolib
  :description "I/O library."
  :author "Stelian Ionescu <sionescu@cddr.org>"
  :maintainer "Stelian Ionescu <sionescu@cddr.org>"
  :version "0.6.0-dev"
  :licence "MIT"
  :depends-on (:iolib.base :iolib.multiplex :iolib.streams :iolib.sockets)
  :pathname (merge-pathnames #p"iolib/" *load-truename*)
  :components ((:file "pkgdcl")))

(defmethod perform ((o test-op) (c (eql (find-system :iolib))))
  (oos 'test-op :iolib-tests))

(defmethod operation-done-p ((o test-op) (c (eql (find-system :iolib))))
  nil)
