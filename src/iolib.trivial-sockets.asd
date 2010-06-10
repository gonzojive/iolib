;;;; -*- Mode: Lisp; indent-tabs-mode: nil -*-

(eval-when (:compile-toplevel :load-toplevel :execute)
  (oos 'load-op :iolib.base))

(defsystem :iolib.trivial-sockets
  :description "Trivial-Sockets compatibility layer."
  :author "Dan Barlow <dan@telent.net>"
  :maintainer "Stelian Ionescu <sionescu@cddr.org>"
  :licence "MIT"
  :depends-on (:iolib.base :iolib.sockets)
  :default-component-class iolib.base:cl-source-file
  :pathname #-asdf2 (merge-pathnames "sockets/" *load-truename*)
            #+asdf2 "sockets/"
  :components
  ((:file "trivial-sockets")))
