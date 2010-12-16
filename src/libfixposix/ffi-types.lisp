;;;; -*- Mode: Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- Foreign type definitions.
;;;

(in-package :libfixposix)

(include "libfixposix.h")



;;;-------------------------------------------------------------------------
;;; Simple POSIX types
;;;-------------------------------------------------------------------------

(ctype bool "bool")
(ctype size-t "size_t")
(ctype ssize-t "ssize_t")
(ctype off-t "off_t")
(ctype time-t "time_t")
(ctype suseconds-t "suseconds_t")

;;;-------------------------------------------------------------------------
;;; LibFixPOSIX types
;;;-------------------------------------------------------------------------



;;;-------------------------------------------------------------------------
;;; errno.h
;;;-------------------------------------------------------------------------

(constantenum (errno-values :define-constants t)
 (:e2big "E2BIG")
 (:eacces "EACCES")
 (:eaddrinuse "EADDRINUSE")
 (:eaddrnotavail "EADDRNOTAVAIL")
 (:eafnosupport "EAFNOSUPPORT")
 (:ealready "EALREADY")
 (:ebadf "EBADF")
 (:ebadmsg "EBADMSG")
 (:ebusy "EBUSY")
 (:ecanceled "ECANCELED")
 (:echild "ECHILD")
 (:econnaborted "ECONNABORTED")
 (:econnrefused "ECONNREFUSED")
 (:econnreset "ECONNRESET")
 (:edeadlk "EDEADLK")
 (:edestaddrreq "EDESTADDRREQ")
 (:edom "EDOM")
 (:edquot "EDQUOT")
 (:eexist "EEXIST")
 (:efault "EFAULT")
 (:efbig "EFBIG")
 (:ehostdown "EHOSTDOWN")
 (:ehostunreach "EHOSTUNREACH")
 (:eidrm "EIDRM")
 (:eilseq "EILSEQ")
 (:einprogress "EINPROGRESS")
 (:eintr "EINTR")
 (:einval "EINVAL")
 (:eio "EIO")
 (:eisconn "EISCONN")
 (:eisdir "EISDIR")
 (:eloop "ELOOP")
 (:emfile "EMFILE")
 (:emlink "EMLINK")
 (:emsgsize "EMSGSIZE")
 (:emultihop "EMULTIHOP")
 (:enametoolong "ENAMETOOLONG")
 (:enetdown "ENETDOWN")
 (:enetreset "ENETRESET")
 (:enetunreach "ENETUNREACH")
 (:enfile "ENFILE")
 (:enobufs "ENOBUFS")
 (:enodata "ENODATA")
 (:enodev "ENODEV")
 (:enoent "ENOENT")
 (:enoexec "ENOEXEC")
 (:enolck "ENOLCK")
 (:enolink "ENOLINK")
 (:enomem "ENOMEM")
 (:enomsg "ENOMSG")
 (:enonet "ENONET" :optional t)
 (:enoprotoopt "ENOPROTOOPT")
 (:enospc "ENOSPC")
 (:enosr "ENOSR")
 (:enostr "ENOSTR")
 (:enosys "ENOSYS")
 (:enotconn "ENOTCONN")
 (:enotdir "ENOTDIR")
 (:enotempty "ENOTEMPTY")
 (:enotsock "ENOTSOCK")
 (:enotsup "ENOTSUP")
 (:enotty "ENOTTY")
 (:enxio "ENXIO")
 (:eopnotsupp "EOPNOTSUPP")
 (:eoverflow "EOVERFLOW")
 (:eperm "EPERM")
 (:epipe "EPIPE")
 (:eproto "EPROTO")
 (:eprotonosupport "EPROTONOSUPPORT")
 (:eprototype "EPROTOTYPE")
 (:erange "ERANGE")
 (:erofs "EROFS")
 (:eshutdown "ESHUTDOWN")
 (:espipe "ESPIPE")
 (:esrch "ESRCH")
 (:estale "ESTALE")
 (:etime "ETIME")
 (:etimedout "ETIMEDOUT")
 (:etxtbsy "ETXTBSY")
 (:ewouldblock "EWOULDBLOCK")
 (:exdev "EXDEV")
 (:ebug "EBUG"))


;;;-------------------------------------------------------------------------
;;; sys/select.h
;;;-------------------------------------------------------------------------

(cstruct timeval "struct timeval"
  "UNIX time specification in seconds and microseconds."
  (sec  "tv_sec"  :type time-t)
  (usec "tv_usec" :type suseconds-t))

(constant (fd-setsize "FD_SETSIZE"))

(cstruct fd-set "fd_set")


;;;-------------------------------------------------------------------------
;;; sys/wait.h
;;;-------------------------------------------------------------------------

(constant (wnohang "WNOHANG"))
(constant (wuntraced "WUNTRACED"))
(constant (wcontinued "WCONTINUED"))
