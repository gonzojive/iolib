;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- Package definition.
;;;

(in-package :common-lisp-user)

(defpackage :iolib.streams
  (:use :iolib.base :cffi)
  (:export
   ;; Classes
   #:dual-channel-fd-mixin
   #:dual-channel-gray-stream
   #:dual-channel-single-fd-mixin
   #:dual-channel-single-fd-gray-stream

   ;; Conditions
   #:hangup
   #:no-characters-to-unread

   ;; Accessors
   #:external-format-of
   #:fd-non-blocking
   #:fd-of
   #:input-fd-non-blocking
   #:input-fd-of
   #:output-fd-non-blocking
   #:output-fd-of
   #:read-buffer-size
   #:read-buffer-empty-p
   #:write-buffer-size
   #:write-buffer-empty-p

   #:read-sequence*
   #:write-sequence*
   #:drain-input-buffer
   ))
