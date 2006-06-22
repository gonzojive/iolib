;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Copyright (C) 2006 by Stelian Ionescu                                 ;
;                                                                         ;
;   This program is free software; you can redistribute it and/or modify  ;
;   it under the terms of the GNU General Public License as published by  ;
;   the Free Software Foundation; either version 2 of the License, or     ;
;   (at your option) any later version.                                   ;
;                                                                         ;
;   This program is distributed in the hope that it will be useful,       ;
;   but WITHOUT ANY WARRANTY; without even the implied warranty of        ;
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         ;
;   GNU General Public License for more details.                          ;
;                                                                         ;
;   You should have received a copy of the GNU General Public License     ;
;   along with this program; if not, write to the                         ;
;   Free Software Foundation, Inc.,                                       ;
;   51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (declaim (optimize (speed 0) (safety 3) (space 0) (debug 2)))
(declaim (optimize (speed 1) (safety 2) (space 0) (debug 2)))

(in-package #:net.sockets)

;;;
;;; Byte-swap functions
;;;

(declaim (inline htons))
(defun htons (short)
  (declare (integer short))
#+little-endian
  (let ((newshort 0))
    (declare (type ub16 newshort)
             (type ub16 short))
    (setf (ldb (byte 8 0) newshort) (ldb (byte 8 8) short))
    (setf (ldb (byte 8 8) newshort) (ldb (byte 8 0) short))
    newshort)
#+big-endian short)

(declaim (inline ntohs))
(defun ntohs (short)
  (htons short))

(declaim (inline htonl))
(defun htonl (long)
  (declare (integer long))
#+little-endian
  (let ((newlong 0))
    (declare (type ub32 newlong)
             (type ub32 long))
    (setf (ldb (byte 8  0) newlong) (ldb (byte 8 24) long))
    (setf (ldb (byte 8 24) newlong) (ldb (byte 8  0) long))
    (setf (ldb (byte 8  8) newlong) (ldb (byte 8 16) long))
    (setf (ldb (byte 8 16) newlong) (ldb (byte 8  8) long))
    newlong)
#+big-endian long)

(declaim (inline ntohl))
(defun ntohl (long)
  (htonl long))


;;;
;;; Conversion functions
;;;

;; From CLOCC's PORT library
(declaim (inline vector-to-ipaddr))
(defun vector-to-ipaddr (vector)
  (declare (type (simple-array ub8 (*)) vector))
  (+ (ash (aref vector 0) 24)
     (ash (aref vector 1) 16)
     (ash (aref vector 2) 8)
     (aref vector 3)))

;; From CLOCC's PORT library
(declaim (inline ipaddr-to-vector))
(defun ipaddr-to-vector (ipaddr)
  (declare (type ub32 ipaddr))
  (vector (ldb (byte 8 24) ipaddr)
          (ldb (byte 8 16) ipaddr)
          (ldb (byte 8 8)  ipaddr)
          (ldb (byte 8 0)  ipaddr)))

(declaim (inline ipaddr-to-dotted))
(defun ipaddr-to-dotted (ipaddr)
  (declare (type ub32 ipaddr))
  (format nil "~a.~a.~a.~a"
          (ldb (byte 8 24) ipaddr)
          (ldb (byte 8 16) ipaddr)
          (ldb (byte 8 8)  ipaddr)
          (ldb (byte 8 0)  ipaddr)))

(declaim (inline dotted-to-ipaddr))
(defun dotted-to-ipaddr (string)
  (vector-to-ipaddr (dotted-to-vector string)))

(declaim (inline make-vector-u8-4-from-in-addr))
(defun make-vector-u8-4-from-in-addr (in-addr)
  (declare (type ub32 in-addr))
  (let ((vector (make-array 4 :element-type 'ub8)))
    (setf in-addr (ntohl in-addr))
    (setf (aref vector 0) (ldb (byte 8 24) in-addr))
    (setf (aref vector 1) (ldb (byte 8 16) in-addr))
    (setf (aref vector 2) (ldb (byte 8  8) in-addr))
    (setf (aref vector 3) (ldb (byte 8  0) in-addr))

    vector))

(defun dotted-to-vector (string &key (error-p t))
  (handler-case
      (setf string (coerce string '(vector base-char)))
    (type-error (err)
      (declare (ignore err))
      (if error-p
          (error 'invalid-argument :argument string
                 :message (format nil "The vector: ~a is not a string or contains non-ASCII characters." string))
          (return-from dotted-to-vector nil))))

  (with-alien ((in-addr et::in-addr-t))
    (sb-sys:with-pinned-objects (in-addr string)
      (setf in-addr 0)
      (let ((retval
             (et::inet-pton et::af-inet       ; address family
                            string            ; name
                            (addr in-addr)))) ; pointer to struct in6_addr
        (unless (or error-p (plusp retval))
          (return-from dotted-to-vector nil))
        (cond
          ((minusp retval) (error 'possible-bug
                                  :data 'et::af-inet
                                  :message "inet_pton says the address family is not supported."))
          ((zerop retval) (error 'invalid-address
                                 :address string
                                 :type :ipv4)))))
    (return-from dotted-to-vector (make-vector-u8-4-from-in-addr in-addr))))

(declaim (inline vector-to-dotted))
(defun vector-to-dotted (vector)
  (declare (type (simple-array ub8 (*)) vector))
  (format nil "~a.~a.~a.~a"
          (aref vector 0)
          (aref vector 1)
          (aref vector 2)
          (aref vector 3)))

(declaim (inline make-vector-u16-8-from-in6-addr))
(defun make-vector-u16-8-from-in6-addr (in6-addr)
  (declare (type (alien (* (struct et::in6-addr))) in6-addr))
  (let ((newvector (make-array 8 :element-type 'ub16))
        (u16-vector (slot (slot in6-addr 'et::in6-u)
                          'et::addr16)))
    (dotimes (i 8)
      (setf (aref newvector i) (ntohs (deref u16-vector i))))

    newvector))

(defun colon-separated-to-vector (string &key (error-p t))
  (handler-case
      (setf string (coerce string '(simple-array base-char (*))))
    (type-error (err)
      (declare (ignore err))
      (if error-p
          (error 'invalid-argument :argument string
                 :message (format nil "The vector: ~a is not a string or contains non-ASCII characters." string))
          (return-from colon-separated-to-vector nil))))

  (with-alien ((in6-addr (struct et::in6-addr)))
    (sb-sys:with-pinned-objects (in6-addr string)
      (et::memset (addr in6-addr) 0 et::size-of-in6-addr)
      (let ((retval
             (et::inet-pton et::af-inet6       ; address family
                            string             ; name
                            (addr in6-addr)))) ; pointer to struct in6_addr
        (unless (or error-p (plusp retval))
          (return-from colon-separated-to-vector nil))
        (cond
          ((minusp retval) (error 'possible-bug
                                  :data 'et::af-inet6
                                  :message "inet_pton says the address family is not supported."))
          ((zerop retval) (error 'invalid-address
                                 :address string
                                 :type :ipv6)))))
    (let ()
      
      (return-from colon-separated-to-vector (make-vector-u16-8-from-in6-addr (addr in6-addr))))))

(defun vector-to-colon-separated (vector &key (case :downcase) (error-p t))
  (handler-case
      (setf vector (coerce vector '(simple-array ub16 (8))))
    (type-error (err)
      (declare (ignore err))
      (if error-p
          (error 'invalid-argument :argument vector
                 :message (format nil "The vector: ~a does not contain only 16-bit positive integers or has not length 8." vector))
          (return-from vector-to-colon-separated nil))))

  (with-alien ((sin6 (struct et::sockaddr-in6))
               (namebuff (array (unsigned 8) #.et::inet6-addrstrlen)))
    (sb-sys:with-pinned-objects (sin6 namebuff)
      (et::memset (addr sin6) 0 et::size-of-sockaddr-in6)
      (let ((u16-vector (slot (slot (slot sin6 'et::addr)
                                    'et::in6-u)
                              'et::addr16)))
        (dotimes (i 8)
          (setf (deref u16-vector i) (htons (aref vector i))))
        (et::inet-ntop et::af-inet6                 ; address family
                       (addr (slot sin6 'et::addr)) ; pointer to struct in6_addr
                       (alien-sap namebuff)         ; destination buffer
                       et::inet6-addrstrlen))       ; INET6_ADDRSTRLEN
      (return-from vector-to-colon-separated
        (let ((str (cast namebuff c-string)))
          (ecase case
            (:downcase str)
            (:upcase (nstring-upcase str))))))))


;;;
;;; Class definitions
;;;

(defclass netaddr ()
  ((name :initarg :name :reader name :type vector))
  (:documentation "Base class for the internet addresses."))

(defclass ipv4addr (netaddr) ()
  (:documentation "IPv4 address."))

(defclass ipv6addr (netaddr) ()
  (:documentation "IPv6 address."))

(defclass unixaddr (netaddr)
  ((abstract :initarg :abstract :reader abstract-p :type boolean))
  (:documentation "UNIX socket address."))


;;;
;;; Print methods
;;;

(defmethod print-object ((address ipv4addr) stream)
  (print-unreadable-object (address stream :type nil :identity nil)
    (with-slots (name) address
      (format stream "IPv4 address: ~a" (vector-to-dotted name)))))

(defmethod print-object ((address ipv6addr) stream)
  (print-unreadable-object (address stream :type nil :identity nil)
    (with-slots (name) address
      (format stream "IPv6 address: ~a" (vector-to-colon-separated name)))))

(defmethod print-object ((address unixaddr) stream)
  (print-unreadable-object (address stream :type nil :identity nil)
    (with-slots (name abstract) address
      (format stream "Unix socket address: ~a. Abstract: ~:[no~;yes~]" name abstract))))

(defmethod netaddr->presentation ((addr ipv4addr))
  (vector-to-dotted (name addr)))

(defmethod netaddr->presentation ((addr ipv6addr))
  (vector-to-colon-separated (name addr)))


;;;
;;; Equality methods
;;;

(defmethod netaddr= ((addr1 ipv4addr) (addr2 ipv4addr))
  (equalp (name addr1) (name addr2)))

(defmethod netaddr= ((addr1 ipv6addr) (addr2 ipv6addr))
  (equalp (name addr1) (name addr2)))

(defmethod netaddr= ((addr1 unixaddr) (addr2 unixaddr))
  (equal (name addr1) (name addr2)))


;;;
;;; Copy methods
;;;

(defmethod copy-netaddr ((addr ipv4addr))
  (make-instance 'ipv4addr
                 :name (copy-seq (name addr))))

(defmethod copy-netaddr ((addr ipv6addr))
  (make-instance 'ipv6addr
                 :name (copy-seq (name addr))))

(defmethod copy-netaddr ((addr unixaddr))
  (make-instance 'unixaddr
                 :name (copy-seq (name addr))
                 :abstract (abstract-p addr)))


;;; Constructor
(defun make-address (type name &key abstract)
  (check-type abstract boolean "boolean value")
  (ecase type
    (:ipv4 (make-instance 'ipv4addr
                          :name name))
    (:ipv6 (make-instance 'ipv6addr
                          :name name))
    (:unix (make-instance 'unixaddr
                          :name name
                          :abstract abstract))))


;;;
;;; Well-known addresses
;;;

(defparameter +ipv4-unspecified+
  (make-address :ipv4 #(0 0 0 0)))

(defparameter +ipv4-loopback+
  (make-address :ipv4 #(127 0 0 1)))

(defparameter +ipv6-unspecified+
  (make-address :ipv6 #(0 0 0 0 0 0 0 0)))

(defparameter +ipv6-loopback+
  (make-address :ipv6 #(0 0 0 0 0 0 0 1)))

;; Multicast addresses replacing IPv4 broadcast addresses
(defparameter +ipv6-interface-local-all-nodes+
  (make-address :ipv6 #(#xFF01 0 0 0 0 0 0 1)))

(defparameter +ipv6-link-local-all-nodes+
  (make-address :ipv6 #(#xFF02 0 0 0 0 0 0 1)))

(defparameter +ipv6-interface-local-all-routers+
  (make-address :ipv6 #(#xFF01 0 0 0 0 0 0 2)))

(defparameter +ipv6-link-local-all-routers+
  (make-address :ipv6 #(#xFF02 0 0 0 0 0 0 2)))

(defparameter +ipv6-site-local-all-routers+
  (make-address :ipv6 #(#xFF05 0 0 0 0 0 0 2)))


;;;
;;; Predicates
;;;

;; General predicates
(defmethod ipv4-address-p ((addr ipv4addr))
  t)

(defmethod ipv4-address-p ((addr netaddr))
  nil)

(defmethod ipv6-address-p ((addr ipv6addr))
  t)

(defmethod ipv6-address-p ((addr netaddr))
  nil)

(defmethod unix-address-p ((addr unixaddr))
  t)

(defmethod unix-address-p ((addr netaddr))
  nil)

;; IPv4 predicates

(defmethod netaddr-unspecified-p ((addr ipv4addr))
  (netaddr= addr +ipv4-unspecified+))

(defmethod netaddr-loopback-p ((addr ipv4addr))
  (netaddr= addr +ipv4-loopback+))

(defmethod netaddr-multicast-p ((addr ipv4addr))
  (eql (logand (aref (name addr) 0)
               #xE0)
       #xE0))

(defmethod netaddr-unicast-p ((addr ipv4addr))
  (and (not (netaddr-unspecified-p addr))
       (not (netaddr-loopback-p addr))
       (not (netaddr-multicast-p addr))))

;; IPv6 predicates
;; definitions taken from RFC 2460

(defmethod netaddr-unspecified-p ((addr ipv6addr))
  (netaddr= addr +ipv6-unspecified+))

(defmethod netaddr-loopback-p ((addr ipv6addr))
  (netaddr= addr +ipv6-loopback+))

(defmethod ipv6-ipv4-mapped-p ((addr ipv6addr))
  (with-slots (name) addr
    (and (zerop (aref name 0))
         (zerop (aref name 1))
         (zerop (aref name 2))
         (zerop (aref name 3))
         (zerop (aref name 4))
         (eql (aref name 5) #xFFFF)
         (< (ldb (byte 8 0) (aref name 6))
            255)
         (< (ldb (byte 8 8) (aref name 6))
            255)
         (< (ldb (byte 8 0) (aref name 7))
            255)
         (< (ldb (byte 8 8) (aref name 7))
            255))))

(defmethod netaddr-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF00)
       #xFF00))

(defmethod ipv6-interface-local-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF0F)
       #xFF01))

(defmethod ipv6-link-local-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF0F)
       #xFF02))

(defmethod ipv6-admin-local-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF0F)
       #xFF04))

(defmethod ipv6-site-local-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF0F)
       #xFF05))

(defmethod ipv6-organization-local-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF0F)
       #xFF08))

(defmethod ipv6-global-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF0F)
       #xFF0E))

(defmethod ipv6-reserved-multicast-p ((addr ipv6addr))
  (member (logand (aref (name addr) 0)
                  #xFF0F)
          '(#xFF00 #xFF03 #xFF0F)))

(defmethod ipv6-unassigned-multicast-p ((addr ipv6addr))
  (member (logand (aref (name addr) 0)
                  #xFF0F)
          '(#xFF06 #xFF07 #xFF09 #xFF0A #xFF0B #xFF0C #xFF0D)))

(defmethod ipv6-transient-multicast-p ((addr ipv6addr))
  (eql (logand (aref (name addr) 0)
               #xFF10)
       #xFF10))

(defmethod ipv6-solicited-node-multicast-p ((addr ipv6addr))
  (let ((vec (name addr)))
    (and (eql (aref vec 0) #xFF02) ; link-local permanent multicast
         (eql (aref vec 5) 1)
         (eql (logand (aref vec 6)
                      #xFF00)
              #xFF00))))

(defmethod ipv6-link-local-unicast-p ((addr ipv6addr))
  (eql (aref (name addr) 0) #xFE80))

(defmethod ipv6-site-local-unicast-p ((addr ipv6addr))
  (eql (aref (name addr) 0) #xFEC0))

(defmethod ipv6-global-unicast-p ((addr ipv6addr))
  (and (not (netaddr-unspecified-p addr))
       (not (netaddr-loopback-p addr))
       (not (netaddr-multicast-p addr))
       (not (ipv6-link-local-unicast-p addr))))

(defmethod netaddr-unicast-p ((addr ipv6addr))
  (or (ipv6-link-local-unicast-p addr)
      (and (not (netaddr-unspecified-p addr))
           (not (netaddr-loopback-p addr))
           (not (netaddr-multicast-p addr)))))

(defmethod ipv6-multicast-type ((addr ipv6addr))
  (cond
    ((ipv6-interface-local-multicast-p addr)    :interface-local)
    ((ipv6-link-local-multicast-p addr)         :link-local)
    ((ipv6-admin-local-multicast-p addr)        :admin-local)
    ((ipv6-site-local-multicast-p addr)         :site-local)
    ((ipv6-organization-local-multicast-p addr) :organization-local)
    ((ipv6-global-multicast-p addr)             :global)
    ((ipv6-reserved-multicast-p addr)           :reserved)
    ((ipv6-unassigned-multicast-p addr)         :unassigned)))

(defmethod netaddr-type ((addr ipv6addr))
  (cond
    ((netaddr-unspecified-p addr)        (values :ipv6 :unspecified))
    ((netaddr-loopback-p addr)           (values :ipv6 :loopback))
    ((netaddr-multicast-p addr)          (values :ipv6 :multicast (ipv6-multicast-type addr)))
    ((ipv6-link-local-unicast-p addr)    (values :ipv6 :unicast :link-local))
    (t                                   (values :ipv6 :unicast :global))))

(defmethod netaddr-type ((addr ipv4addr))
  (cond
    ((netaddr-unspecified-p addr)        (values :ipv4 :unspecified))
    ((netaddr-loopback-p addr)           (values :ipv4 :loopback))
    ((netaddr-multicast-p addr)          (values :ipv4 :multicast))
    ((netaddr-unicast-p addr)            (values :ipv4 :unicast))))