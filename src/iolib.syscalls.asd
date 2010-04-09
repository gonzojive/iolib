;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-

(eval-when (:compile-toplevel :load-toplevel :execute)
  (oos 'load-op :cffi-grovel))

(defsystem :iolib.syscalls
  :description "Syscalls and foreign types."
  :maintainer "Stelian Ionescu <sionescu@cddr.org>"
  :licence "MIT"
  :depends-on (:trivial-features :cffi :cffi-grovel :iolib.base)
  :pathname (merge-pathnames "syscalls/" *load-truename*)
  :serial t
  :components
  ((:file "pkgdcl")
   #+unix
   (:file "syscall-path-strings" :pathname "unix-syscall-path-strings")
   ;; Platform-specific files
   (cffi-grovel:grovel-file "ffi-types" :pathname #+unix "ffi-types-unix")
   (:file "conditions")
   (:file "os-conditions" :pathname #+unix "os-conditions-unix")
   (:file "designators")
   (:file "early")
   (cffi-grovel:wrapper-file "ffi-wrappers" :pathname #+unix "ffi-wrappers-unix"
     :soname "libiolib-syscalls")
   (:file "ffi-functions" :pathname #+unix "ffi-functions-unix")))
