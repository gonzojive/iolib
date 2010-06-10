;;;; -*- Mode: Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- Package definition.
;;;

(in-package :common-lisp-user)

(defpackage :iolib.multiplex
  (:nicknames #:iomux)
  (:use :iolib.base :cffi)
  (:export
   ;; Classes and Types
   #:timer
   #:event-base
   #:multiplexer
   #:select-multiplexer
   #:poll-multiplexer
   #+bsd #:kqueue-multiplexer
   #+linux #:epoll-multiplexer

   ;; Event-base Operations
   #:*available-multiplexers*
   #:*default-multiplexer*
   #:*default-event-loop-timeout*
   #:add-timer
   #:close-event-base
   #:event-base-empty-p
   #:event-dispatch
   #:exit-event-loop
   #:remove-timer
   #:remove-fd-handlers
   #:set-error-handler
   #:set-io-handler
   #:with-event-base

   ;; Operations on FDs
   #:fd-readablep
   #:fd-ready-p
   #:fd-writablep
   #:poll-error
   #:poll-error-fd
   #:poll-error-identifier
   #:wait-until-fd-ready
   #:poll-timeout
   #:poll-timeout-fd
   #:poll-timeout-event-type
   ))
