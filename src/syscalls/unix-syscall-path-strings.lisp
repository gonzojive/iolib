;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- Strings used for decoding Unix pathnames: invalid UTF8 octets
;;;     are #\Null-escaped.
;;;
;;; TODO: add 8bit-chars versions of SSTRING-TO-CSTRING,
;;;       COUNT-SSTRING-OCTETS and CSTRING-TO-SSTRING

(in-package :iolib.syscalls)

(eval-when (:compile-toplevel :load-toplevel)
  #+#.(cl:if (cl:<= cl:char-code-limit #xFF) '(:and) '(:or))
  (pushnew :8bit-chars *features*)
  #+#.(cl:if (cl:> #xFF cl:char-code-limit #x10000) '(:and) '(:or))
  (pushnew :16bit-chars *features*)
  #+#.(cl:if (cl:> cl:char-code-limit #xFFFF) '(:and) '(:or))
  (pushnew :21bit-chars *features*))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defconstant +cstring-path-max+ 65535))

(defun sstring-to-cstring (sstring c-ptr)
  (let ((index 0))
    (flet ((output-octet (octet)
             (setf (cffi:mem-aref c-ptr :unsigned-char index) octet)
             (incf index)))
      (declare (inline output-octet))
      (loop :with len := (length sstring)
            :with end-offset := (1- len)
            :for i :below len
            :for code := (char-code (char sstring i)) :do
            (cond
              ((zerop code)
               (if (= i end-offset)
                   (output-octet 0)
                   (output-octet (char-code (char sstring (incf i))))))
              ((< code #x80)
               (output-octet code))
              ((< code #x800)
               (output-octet (logior #xC0 (ldb (byte 5 6) code)))
               (output-octet (logior #x80 (ldb (byte 6 0) code))))
              ((< code #x10000)
               (output-octet (logior #xE0 (ldb (byte 4 12) code)))
               (output-octet (logior #x80 (ldb (byte 6 6) code)))
               (output-octet (logior #x80 (ldb (byte 6 0) code))))
              ((< code #x110000)
               (output-octet (logior #xF0 (ldb (byte 3 18) code)))
               (output-octet (logior #x80 (ldb (byte 6 12) code)))
               (output-octet (logior #x80 (ldb (byte 6 6) code)))
               (output-octet (logior #x80 (ldb (byte 6 0) code))))
              (t (bug "Code points should not be larger than ~S" #x10FFFF)))
            :finally (output-octet 0))
      (values c-ptr index))))

(defun count-sstring-octets (sstring)
  (loop :with len := (length sstring)
        :with end-offset := (1- len)
        :for i :below len
        :for code := (char-code (char sstring i))
        :sum (cond
               ((zerop code)
                (when (< i end-offset) (incf i))
                1)
               ((<  code #x80)     1)
               ((<  code #x800)    2)
               ((<  code #x10000)  3)
               ((<  code #x110000) 4)
               (t (bug "Code points should not be larger than ~S" #x10FFFF)))))

(defun cstring-alloc (sstring)
  "Allocate a null-terminated foreign buffer containing SSTRING."
  (let* ((length (count-sstring-octets Sstring))
         (ptr (foreign-alloc :char :count (1+ length))))
    (sstring-to-cstring sstring ptr)))

(defmacro with-sstring-to-cstring ((var sstring &optional size-var) &body body)
  `(multiple-value-bind (,var ,@(when size-var (list size-var)))
       (cstring-alloc ,sstring)
     (unwind-protect
          (progn ,@body)
       (foreign-free ,var))))

(deftype cstr-offset ()
  `(integer 0 ,(1+ +cstring-path-max+)))

(defun utf8-extra-bytes (code)
  (declare (type (unsigned-byte 8) code)
           (optimize (speed 3) (safety 0) (debug 0)))
  (let ((vec (load-time-value
              (coerce
               ;; 16-bit chars
               #+16bit-chars
               #(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
                 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
               ;; 21-bit chars
               #+21bit-chars
               #(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
                 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2  3 3 3 3 3 0 0 0 0 0 0 0 0 0 0 0)
               '(simple-array (unsigned-byte 8) (256))))))
    (aref (the (simple-array (unsigned-byte 8) (256)) vec) code)))

(defun offsets-from-utf8 (extra-bytes)
  (declare (type (mod 4) extra-bytes)
           (optimize (speed 3) (safety 0) (debug 0)))
  (let ((vec (load-time-value
              (coerce #(#x00000000 #x00003080 #x000E2080 #x03C82080)
                      '(simple-array (unsigned-byte 26) (4))))))
    (aref (the (simple-array (unsigned-byte 26) (4)) vec) extra-bytes)))

(defun legal-utf8-cstring (ptr start len)
  (declare (type cstr-offset start len)
           (optimize (speed 3) (safety 0) (debug 0)))
  (let ((end (+ start len))
        (srchr (mem-aref ptr :unsigned-char start))
        c)
    #+16bit-chars
    (when (>= srchr #xF4) (return* nil))
    (flet ((getch ()
             (mem-aref ptr :unsigned-char (decf (the (unsigned-byte 17) end)))))
      (declare (inline getch))
      (when (=  len 4) (setf c (getch)) (unless (<= #x80 c #xBF) (return* nil)))
      (when (>= len 3) (setf c (getch)) (unless (<= #x80 c #xBF) (return* nil)))
      (when (>= len 2) (setf c (getch)) (unless (<= #x00 c #xBF) (return* nil))
        (case srchr
          (#xE0 (when (< c #xA0) (return* nil)))
          (#xED (when (> c #x9F) (return* nil)))
          (#xF0 (when (< c #x90) (return* nil)))
          (#xF4 (when (> c #x8F) (return* nil)))
          (t    (when (< c #x80) (return* nil)))))
      (when (>= len 1) (when (<= #x80 srchr #xC1) (return* nil)))
      (when (> srchr #xF4) (return* nil))
      t)))

(defun cstring-to-sstring (c-ptr &optional (c-len (1+ +cstring-path-max+)))
  (declare (type cstr-offset c-len)
           (optimize (speed 3) (safety 0) (debug 0)))
  (let ((index 0) (sindex 0)
        (sstring (make-string (* 2 c-len))))
    (declare (type cstr-offset index sindex))
    (flet ((input-char ()
             (prog1 (mem-aref c-ptr :unsigned-char index)
               (incf index)))
           (output-char (char)
             (setf (char sstring sindex) char)
             (incf sindex))
           (output-code (code)
             (setf (char sstring sindex) (code-char code))
             (incf sindex)))
      (declare (inline input-char output-char output-code))
      (loop :for byte0 := (mem-aref c-ptr :unsigned-char index)
            :until (or (>= index c-len) (zerop byte0)) :do
            (block decode-one-char
              (let* ((code 0)
                     (extra-bytes (min (utf8-extra-bytes byte0)))
                     (legalp (and (legal-utf8-cstring c-ptr index (1+ extra-bytes))
                                  (< extra-bytes (- c-len index)))))
                (declare (type (mod 4) extra-bytes)
                         (type (unsigned-byte 27) code))
                (labels ((finish-seq (extra-bytes)
                           (cond
                             (legalp
                              (decf code (the (unsigned-byte 26) (offsets-from-utf8 extra-bytes)))
                              (output-code code))
                             (t
                              (output-char #\Null) (output-code code))))
                         (legalchk ()
                           (unless legalp (finish-seq 0) (return-from decode-one-char))))
                  (when (>= extra-bytes 3) (setf code (ash (+ code (input-char)) 6)) (legalchk))
                  (when (>= extra-bytes 2) (setf code (ash (+ code (input-char)) 6)) (legalchk))
                  (when (>= extra-bytes 1) (setf code (ash (+ code (input-char)) 6)) (legalchk))
                  (when (>= extra-bytes 0) (setf code (ash (+ code (input-char)) 0)) (legalchk))
                  (finish-seq extra-bytes))))))
    (shrink-vector sstring sindex)))

(defmacro with-cstring-to-sstring ((var size &optional size-var) &body body)
  `(with-foreign-pointer (,var ,size ,size-var)
     (progn ,@body
       (cstring-to-sstring ,var ,size-var))))


;;; Automatic Conversion of Foreign Strings to Sstrings
;;; Initially copied from cffi/src/string.lisp

(define-foreign-type cstring-type ()
  (;; Should we free after translating from foreign?
   (free-from-foreign :initarg :free-from-foreign
                      :reader cstring-free-from-foreign-p
                      :initform nil :type boolean)
   ;; Should we free after translating to foreign?
   (free-to-foreign :initarg :free-to-foreign
                    :reader cstring-free-to-foreign-p
                    :initform t :type boolean))
  (:actual-type :pointer)
  (:simple-parser sstring))

;; TODO: use EXPAND-TO-FOREIGN
(defmethod translate-to-foreign (s (type cstring-type))
  (check-type s string)
  (values (cstring-alloc s)
          (cstring-free-to-foreign-p type)))

(defmethod translate-from-foreign (ptr (type cstring-type))
  (unwind-protect
       (if (null-pointer-p ptr)
           nil
           (cstring-to-sstring ptr))
    (when (and (cstring-free-from-foreign-p type)
               (not (null-pointer-p ptr)))
      (foreign-free ptr))))

(defmethod free-translated-object (ptr (type cstring-type) free-p)
  (when free-p
    (foreign-free ptr)))
