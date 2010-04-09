;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- FFI wrappers.
;;;

(in-package :iolib.syscalls)

(c "#if defined(__linux__)")
(c "#undef _GNU_SOURCE")
(define "_XOPEN_SOURCE" 600)
(define "_LARGEFILE_SOURCE")
(define "_LARGEFILE64_SOURCE")
(define "_FILE_OFFSET_BITS" 64)
(c "#endif")


;;;-------------------------------------------------------------------------
;;; ERRNO-related functions
;;;-------------------------------------------------------------------------

(include "errno.h")

(declaim (inline errno))
(defwrapper* ("iolib_get_errno" errno) :int
  ()
  "return errno;")

(declaim (inline %set-errno))
(defwrapper* ("iolib_set_errno" %set-errno) :int
  ((value :int))
  "errno = value;"
  "return errno;")


;;;-------------------------------------------------------------------------
;;; Socket message readers
;;;-------------------------------------------------------------------------

(include "stdlib.h") ; needed on FreeBSD to define NULL
(include "sys/socket.h")

(declaim (inline cmsg.space))
(defwrapper ("CMSG_SPACE" cmsg.space) :unsigned-int
  (data-size :unsigned-int))

(declaim (inline cmsg.len))
(defwrapper ("CMSG_LEN" cmsg.len) :unsigned-int
  (data-size :unsigned-int))

(declaim (inline cmsg.firsthdr))
(defwrapper ("CMSG_FIRSTHDR" cmsg.firsthdr) :pointer
  (msg ("struct msghdr*" :pointer)))

(declaim (inline cmsg.data))
(defwrapper ("CMSG_DATA" cmsg.data) :pointer
  (cmsg ("struct cmsghdr*" :pointer)))


;;;-------------------------------------------------------------------------
;;; Directory listing
;;;-------------------------------------------------------------------------

(include "sys/types.h" "dirent.h")

(declaim (inline dirfd))
(defwrapper (dirfd "dirfd") :int
  (dirp ("DIR*" :pointer)))
