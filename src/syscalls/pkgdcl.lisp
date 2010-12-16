;;;; -*- Mode: Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- Package definition.
;;;

(in-package :common-lisp-user)

(defpackage :iolib.syscalls
  (:nicknames #:isys)
  (:use :iolib.base :cffi)
  (:shadow #:open #:close #:read #:write #:listen
           #:truncate #:ftruncate #:time)
  (:import-from
   :libfixposix

   ;;;----------------------------------------------------------------------
   ;;; C Types
   ;;;----------------------------------------------------------------------

   ;; Primitive type sizes
   #:size-of-char
   #:size-of-short
   #:size-of-int
   #:size-of-long
   #:size-of-long-long
   #:size-of-pointer

   ;; POSIX Types
   #:bool #:size-of-bool
   #:size-t #:size-of-size-t
   #:ssize-t #:size-of-ssize-t
   #:off-t #:size-of-off-t
   #:time-t #:size-of-time-t
   #:suseconds-t #:size-of-suseconds-t

   ;; LibFixPOSIX types

   ;;;----------------------------------------------------------------------
   ;;; Struct definitions, slots and accessors
   ;;;----------------------------------------------------------------------

   ;; timeval
   #:timeval #:size-of-timeval
   #:sec #:usec

   ;; fd-set
   #:fd-set #:size-of-fd-set


   ;;;----------------------------------------------------------------------
   ;;; C Constants
   ;;;----------------------------------------------------------------------

   ;; Syscall error codes
   #:errno-values
   #:e2big #:eacces #:eaddrinuse #:eaddrnotavail
   #:eafnosupport #:ealready #:ebadf #:ebadmsg #:ebusy #:ecanceled
   #:echild #:econnaborted #:econnrefused #:econnreset #:edeadlk
   #:edestaddrreq #:edom #:edquot #:eexist #:efault #:efbig #:ehostdown
   #:ehostunreach #:eidrm #:eilseq #:einprogress #:eintr #:einval #:eio
   #:eisconn #:eisdir #:eloop #:emfile #:emlink #:emsgsize #:emultihop
   #:enametoolong #:enetdown #:enetreset #:enetunreach #:enfile
   #:enobufs #:enodata #:enodev #:enoent #:enoexec #:enolck #:enolink
   #:enomem #:enomsg #:enonet #:enoprotoopt #:enospc #:enosr #:enostr
   #:enosys #:enotconn #:enotdir #:enotempty #:enotsock #:enotsup #:enotty
   #:enxio #:eopnotsupp #:eoverflow #:eperm #:epipe #:eproto
   #:eprotonosupport #:eprototype #:erange #:erofs #:eshutdown #:espipe
   #:esrch #:estale #:etime #:etimedout #:etxtbsy #:ewouldblock #:exdev
   #:ebug

   ;; Select()
   #:fd-setsize

   ;; Waitpid()
   #:wnohang
   #:wuntraced
   #:wcontinued


   ;;;----------------------------------------------------------------------
   ;;; Syscalls
   ;;;----------------------------------------------------------------------

   ;; Errno-related functions
   ;; Shadowed: strerror
   #:errno

   ;; Memory manipulation functions
   #:memset
   #:bzero
   #:memcpy
   #:memmove

   ;; I/O Polling
   ;; Shadowed: select, fd-isset
   #:copy-fd-set
   #:fd-clr
   #:fd-set
   #:fd-zero

   ;; Signals
   #:wifexited
   #:wexitstatus
   #:wifsignaled
   #:wtermsig
   #:wcoredump
   #:wifstopped
   #:wstopsig
   #:wifcontinued

   ;; CMSG readers
   #:cmsg.firsthdr
   #:cmsg.nxthdr
   #:cmsg.align
   #:cmsg.space
   #:cmsg.len
   #:cmsg.data
   )

  (:export

   ;;;----------------------------------------------------------------------
   ;;; C Types
   ;;;----------------------------------------------------------------------

   ;; Primitive type sizes
   #:size-of-char
   #:size-of-short
   #:size-of-int
   #:size-of-long
   #:size-of-long-long
   #:size-of-pointer

   ;; POSIX Types
   #:size-t #:size-of-size-t
   #:ssize-t #:size-of-ssize-t
   #:pid-t #:size-of-pid-t
   #:gid-t #:size-of-gid-t
   #:uid-t #:size-of-uid-t
   #:off-t #:size-of-off-t
   #:mode-t #:size-of-mode-t
   #:time-t #:size-of-time-t
   #:useconds-t #:size-of-useconds-t
   #:suseconds-t #:size-of-suseconds-t
   #:dev-t #:size-of-dev-t
   #:ino-t #:size-of-ino-t
   #:nlink-t #:size-of-nlink-t
   #:blksize-t #:size-of-blksize-t
   #:blkcnt-t #:size-of-blkcnt-t
   #:nfds-t #:size-of-nfds-t


   ;;;----------------------------------------------------------------------
   ;;; C Constants
   ;;;----------------------------------------------------------------------

   ;; Open()
   #:o-rdonly
   #:o-wronly
   #:o-rdwr
   #:o-creat
   #:o-excl
   #:o-trunc
   #:o-append
   #:o-noctty
   #:o-nonblock
   #:o-ndelay
   #:o-sync
   #:o-nofollow
   #:o-async
   #+linux #:o-cloexec

   ;; Lseek()
   #:seek-set
   #:seek-cur
   #:seek-end

   ;; Access()
   #:r-ok
   #:w-ok
   #:x-ok
   #:f-ok

   ;; Stat()
   #:s-irwxu
   #:s-irusr
   #:s-iwusr
   #:s-ixusr
   #:s-ifmt
   #:s-ififo
   #:s-ifchr
   #:s-ifdir
   #:s-ifblk
   #:s-ifreg
   #:s-ifwht
   #:s-iread
   #:s-iwrite
   #:s-iexec
   #:s-irwxg
   #:s-irgrp
   #:s-iwgrp
   #:s-ixgrp
   #:s-irwxo
   #:s-iroth
   #:s-iwoth
   #:s-ixoth
   #:s-isuid
   #:s-isgid
   #:s-isvtx
   #:s-iflnk
   #:s-ifsock
   #:path-max

   ;; Readdir()
   #:dt-unknown
   #:dt-fifo
   #:dt-chr
   #:dt-dir
   #:dt-blk
   #:dt-reg
   #:dt-lnk
   #:dt-sock
   #:dt-wht

   ;; Kill()
   #:sighup
   #:sigquit
   #:sigtrap
   #-linux #:sigemt
   #:sigkill
   #:sigbus
   #:sigsys
   #:sigpipe
   #:sigalrm
   #:sigurg
   #:sigstop
   #:sigtstp
   #:sigcont
   #:sigchld
   #:sigcld
   #:sigttin
   #:sigttou
   #:sigio
   #:sigxcpu
   #:sigxfsz
   #:sigvtalrm
   #:sigprof
   #:sigwinch
   #-linux #:siginfo
   #:sigusr1
   #:sigusr2
   #+linux #:sigrtmin
   #+linux #:sigrtmax

   ;; Waitpid()
   #:wnohang
   #:wuntraced
   #:wcontinued

   ;; Sigaction()
   #:sig-ign
   #:sig-dfl
   #:sa-nocldstop
   #:sa-nocldwait
   #:sa-nodefer
   #:sa-onstack
   #:sa-resethand
   #:sa-restart
   #:sa-siginfo

   ;; Fcntl()
   #:f-dupfd
   #:f-getfd
   #:f-setfd
   #:f-getfl
   #:f-setfl
   #:f-getlk
   #:f-setlk
   #:f-setlkw
   #:f-getown
   #:f-setown
   #:f-rdlck
   #:f-wrlck
   #:f-unlck
   #+linux #:f-getsig
   #+linux #:f-setsig
   #+linux #:f-setlease
   #+linux #:f-getlease

   ;; Mmap()
   #:prot-none
   #:prot-read
   #:prot-write
   #:prot-exec
   #:map-shared
   #:map-private
   #:map-fixed
   #:map-failed

   ;; Select()
   #:fd-setsize

   ;; Poll()
   #:pollin
   #:pollrdnorm
   #:pollrdband
   #:pollpri
   #:pollout
   #:pollwrnorm
   #:pollwrband
   #:pollerr
   #:pollrdhup
   #:pollhup
   #:pollnval

   ;; Epoll
   #+linux #:epoll-ctl-add
   #+linux #:epoll-ctl-del
   #+linux #:epoll-ctl-mod
   #+linux #:epollin
   #+linux #:epollrdnorm
   #+linux #:epollrdband
   #+linux #:epollpri
   #+linux #:epollout
   #+linux #:epollwrnorm
   #+linux #:epollwrband
   #+linux #:epollerr
   #+linux #:epollhup
   #+linux #:epollmsg
   #+linux #:epolloneshot
   #+linux #:epollet

   ;; Kevent
   #+bsd #:ev-add
   #+bsd #:ev-enable
   #+bsd #:ev-disable
   #+bsd #:ev-delete
   #+bsd #:ev-oneshot
   #+bsd #:ev-clear
   #+bsd #:ev-eof
   #+bsd #:ev-error
   #+bsd #:evfilt-read
   #+bsd #:evfilt-write
   #+bsd #:evfilt-aio
   #+bsd #:evfilt-vnode
   #+bsd #:evfilt-proc
   #+bsd #:evfilt-signal
   #+bsd #:evfilt-timer
   #+(and bsd (not darwin)) #:evfilt-netdev
   #+bsd #:note-delete
   #+bsd #:note-write
   #+bsd #:note-extend
   #+bsd #:note-attrib
   #+bsd #:note-link
   #+bsd #:note-rename
   #+bsd #:note-revoke
   #+bsd #:note-exit
   #+bsd #:note-fork
   #+bsd #:note-exec
   #+bsd #:note-track
   #+bsd #:note-trackerr
   #+(and bsd (not darwin)) #:note-linkup
   #+(and bsd (not darwin)) #:note-linkdown
   #+(and bsd (not darwin)) #:note-linkinv

   ;; Ioctl()
   #:fionbio
   #:fionread

   ;; Getrlimit()
   #:prio-process
   #:prio-pgrp
   #:prio-user
   #:rlim-infinity
   #:rusage-self
   #:rusage-children
   #:rlimit-as
   #:rlimit-core
   #:rlimit-cpu
   #:rlimit-data
   #:rlimit-fsize
   #:rlimit-memlock
   #:rlimit-nofile
   #:rlimit-nproc
   #:rlimit-rss
   #:rlimit-stack
   #+linux #:rlim-saved-max
   #+linux #:rlim-saved-cur
   #+linux #:rlimit-locks
   #+linux #:rlimit-msgqueue
   #+linux #:rlimit-nlimits
   #+linux #:rlimit-nice
   #+linux #:rlimit-rtprio
   #+linux #:rlimit-sigpending
   #+bsd #:rlimit-sbsize

   ;; Syscall error codes
   #:errno-values
   #:e2big #:eacces #:eaddrinuse #:eaddrnotavail
   #:eafnosupport #:ealready #:ebadf #:ebadmsg #:ebusy #:ecanceled
   #:echild #:econnaborted #:econnrefused #:econnreset #:edeadlk
   #:edestaddrreq #:edom #:edquot #:eexist #:efault #:efbig #:ehostdown
   #:ehostunreach #:eidrm #:eilseq #:einprogress #:eintr #:einval #:eio
   #:eisconn #:eisdir #:eloop #:emfile #:emlink #:emsgsize #:emultihop
   #:enametoolong #:enetdown #:enetreset #:enetunreach #:enfile
   #:enobufs #:enodata #:enodev #:enoent #:enoexec #:enolck #:enolink
   #:enomem #:enomsg #:enonet #:enoprotoopt #:enospc #:enosr #:enostr
   #:enosys #:enotconn #:enotdir #:enotempty #:enotsock #:enotsup #:enotty
   #:enxio #:eopnotsupp #:eoverflow #:eperm #:epipe #:eproto
   #:eprotonosupport #:eprototype #:erange #:erofs #:eshutdown #:espipe
   #:esrch #:estale #:etime #:etimedout #:etxtbsy #:ewouldblock #:exdev
   #:ebug


   ;;;----------------------------------------------------------------------
   ;;; Syscalls
   ;;;----------------------------------------------------------------------

   ;; Specials
   #:*default-open-mode*
   #:*environ*

   ;; Errno-related functions
   #:errno
   #:strerror

   ;; Memory manipulation functions
   #:memset
   #:bzero
   #:memcpy
   #:memmove

   ;; Files
   #:read
   #:write
   #:readv
   #:writev
   #:pread
   #:pwrite
   #:open
   #:creat
   #:pipe
   #:mkfifo
   #:umask
   #:lseek
   #:access
   #:truncate
   #:ftruncate
   #:rename
   #:link
   #:symlink
   #:readlink
   #:realpath
   #:unlink
   #:chown
   #:fchown
   #:lchown
   #:chmod
   #:fchmod
   #:stat
   #:fstat
   #:lstat
   #:sync
   #:fsync
   #:mkstemp

   ;; Directories
   #:mkdir
   #:rmdir
   #:chdir
   #:fchdir
   #:getcwd
   #:mkdtemp

   ;; File descriptors
   #:close
   #:dup
   #:dup2
   #:fcntl
   #:fd-nonblock
   #:ioctl
   #:fd-open-p

   ;; TTYs
   #:posix-openpt
   #:grantpt
   #:unlockpt
   #:ptsname

   ;; I/O Polling
   #:select
   #:fd-zero
   #:copy-fd-set
   #:fd-isset
   #:fd-clr
   #:fd-set
   #:poll
   #+linux #:epoll-create
   #+linux #:epoll-ctl
   #+linux #:epoll-wait
   #+bsd #:kqueue
   #+bsd #:kevent
   #+bsd #:ev-set

   ;; Directory walking
   #:opendir
   #:closedir
   #:readdir
   #:rewinddir
   #:seekdir
   #:telldir

   ;; Memory mapping
   #:mmap
   #:munmap

   ;; Process creation and info
   #:fork
   #:execv
   #:execvp
   #:waitpid
   #:getpid
   #:getppid
   #:gettid
   #:getuid
   #:setuid
   #:geteuid
   #:seteuid
   #:getgid
   #:setgid
   #:getegid
   #:setegid
   #:setreuid
   #:setregid
   #:getpgid
   #:setpgid
   #:getpgrp
   #:setpgrp
   #:setsid
   #:getrlimit
   #:setrlimit
   #:getrusage
   #:getpriority
   #:setpriority
   #:nice

   ;; Signals
   #:kill
   #:sigaction
   #:wifexited
   #:wexitstatus
   #:wifsignaled
   #:wtermsig
   #:wcoredump
   #:wifstopped
   #:wstopsig
   #:wifcontinued

   ;; Time
   #:usleep
   #:time
   #:gettimeofday
   #:get-monotonic-time

   ;; Environment
   #:getenv
   #:setenv
   #:unsetenv
   #:clearenv

   ;; Local info
   #:gethostname
   #:getdomainname
   #:uname

   ;; User info
   #:getpwnam
   #:getpwuid

   ;; Group info
   #:getgrnam
   #:getgrgid

   ;; CMSG readers
   #:cmsg.firsthdr
   #:cmsg.nxthdr
   #:cmsg.align
   #:cmsg.space
   #:cmsg.len
   #:cmsg.data


   ;;;----------------------------------------------------------------------
   ;;; Error conditions, wrappers and definers
   ;;;----------------------------------------------------------------------

   #:iolib-condition #:iolib-error #:syscall-error
   #:code-of #:identifier-of #:message-of #:handle-of #:handle2-of
   #:make-syscall-error #:syscall-error-p #:get-syscall-error-condition
   #:signal-syscall-error #:signal-syscall-error/restart
   #:poll-error #:event-type-of #:poll-timeout

   ;; Syscall return wrapper
   #:syscall-wrapper
   #:error-predicate-of
   #:error-location-of
   #:return-filter-of
   #:error-generator-of
   #:syscall-restart-p
   #:base-type-of
   #:never-fails
   #:signal-syscall-error
   #:signal-syscall-error-kw
   #:signal-syscall-error/restart

   ;; Syscall definers
   #:defentrypoint
   #:defcfun*
   #:defsyscall

   ;; CFFI Type Designators
   #:pointer-or-nil
   #:pointer-or-nil-designator
   #:bool
   #:bool-designator

   ;; SSTRING <-> CSTRING
   #:+cstring-path-max+
   #:cstring-to-sstring
   #:sstring-to-cstring
   #:with-cstring-to-sstring
   #:with-sstring-to-cstring

   ;; Misc
   #:repeat-upon-condition
   #:repeat-upon-eintr
   #:repeat-decreasing-timeout
   #:repeat-upon-condition-decreasing-timeout


   ;;;----------------------------------------------------------------------
   ;;; Struct definitions, slots and accessors
   ;;;----------------------------------------------------------------------

   ;; timespec
   #:timespec #:size-of-timespec
   #:sec
   #:nsec

   ;; timeval
   #:timeval #:size-of-timeval
   #:sec
   #:usec

   ;; sigaction
   #:sigaction #:size-of-sigaction
   #:handler

   ;; stat
   #:stat #:size-of-stat
   #:dev #:stat-dev
   #:ino #:stat-ino
   #:mode #:stat-mode
   #:nlink #:stat-nlink
   #:uid #:stat-uid
   #:gid #:stat-gid
   #:rdev #:stat-rdev
   #:size #:stat-size
   #:blksize #:stat-blksize
   #:blocks #:stat-blocks
   #:atime #:stat-atime
   #:mtime #:stat-mtime
   #:ctime #:stat-ctime

   ;; fd_set
   #:fd-set #:size-of-fd-set

   ;; pollfd
   #:pollfd #:size-of-pollfd
   #:fd
   #:events
   #:revents

   ;; epoll_data
   #+linux #:epoll-data #+linux #:size-of-epoll-data
   #+linux #:ptr
   #+linux #:fd
   #+linux #:u32
   #+linux #:u64

   ;; epoll_event
   #+linux #:epoll-event #+linux #:size-of-epoll-event
   #+linux #:events
   #+linux #:data

   ;; kevent
   #+bsd #:kevent #+bsd #:size-of-kevent
   #+bsd #:ident
   #+bsd #:filter
   #+bsd #:flags
   #+bsd #:fflags
   #+bsd #:data
   #+bsd #:udata
   ))
