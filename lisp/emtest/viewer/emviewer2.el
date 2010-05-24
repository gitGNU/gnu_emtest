;;;_ emtest/viewer/emviewer2.el --- Plain, static viewer for emtest

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: lisp, maint, outlines

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;;_ , Commentary:

;; Borrowed from emviewer, only needs differentiate a few things.
;; They ought to share code.


;;;_ , Requires


(require 'emtest/common/testral-types)
(require 'emtest/viewer/emformat)
(require 'emtest/viewer/receive)
(require 'emtest/viewer/empathtree)
(require 'emtest/viewer/view-types)
(require 'viewers/loformat)
(require 'utility/pathtree)

;;;_. Body
;;;_ , emtv2:report-buffer-name
(defconst emtv2:report-buffer-name 
   "*Emtest Report (Plain viewer)*")
;;;_ , Vars
(defvar emtv2:report-buffer nil 
   "Buffer that we write reports in" )

(defvar emtv2:pathtree nil 
   "Pathtree object, generated by emtv2:receiver" )
(defvar emtv2:receiver 
   nil
   "Receiver object, of type `emtvr:data'" )
;;;_ , Glue functions
;;;_  . emtv2:receive-cb
;;Only different from `emtve:receive-cb' in that it knows a
;;different pathtree variable.
(defun emtv2:receive-cb (presentation-path cell)
   "Emviewer callback that `receive' gets.
It just tells a pathtree to add this node."
   (emtvp:add/replace-node
      ;;The pathtree root
      emtv2:pathtree 
      ;;The path
      presentation-path
      ;;The data
      (make-emt:view:suite-newstyle 
	 :list '()
	 :cell cell)))

;;;_  . emtv2:pathtree-cb
;;Different from `emtest:viewer:pathtree-cb' in that it does not try
;;to print objects, thus does not deal with `dirty' flag.
(defun emtv2:pathtree-cb (obj)
   "Callback to handle dirty flags, that `pathree' gets."
   (emtvp:util:handle-dirty obj
      (cond
	 (
	    (or
	       (member 'new dirty-flags)
	       (emtvp:util:member-as-car 
		  'replaced 
		  dirty-flags))
	    (undirty 'new)
	    (undirty-car 'replaced)
	    (new-dirty 'summary)
	    (let
	       ((parent (emtvp-node-parent obj)))
	       (when parent
		  ;;Parent's summary may be dirty now.
		  (new-dirty-node 'summary parent))))
	 
	 ((member 'summary dirty-flags)
	    ;;If any children have yet to be summarized, can't do
	    ;;anything yet.
	    (unless 
	       (some
		  #'(lambda (child)
		       (member 'summary 
			  (emtvp-node-dirty-flags child)))
		  (emtvp-node-children obj))
	       ;;Do summarization
	       (emtvr:sum-node-badnesses obj)
	       (undirty 'summary)
	       ;;Parent (if any) now needs to be resummarized.
	       (let
		  ((parent (emtvp-node-parent obj)))
		  (when parent
		     (new-dirty-node 'summary parent))))))))

;;;_  . emtv2:setup-if-needed
(defun emtv2:setup-if-needed ()
   ""
   (unless emtv2:pathtree
      (setq emtv2:pathtree
	 (emtvp:make-empty-tree-newstyle
	    #'emtv2:pathtree-cb
	    ;;Default makes the base type.
	    #'(lambda ()
		 (make-emt:view:presentable
		    :list '()))
	    'emt:view:suite-newstyle)))

   (unless (buffer-live-p emtv2:report-buffer)
      (setq 
	 emtv2:report-buffer 
	 (generate-new-buffer
	    emtv2:report-buffer-name)))
   (unless 
      emtv2:receiver
      (setq emtv2:receiver
	 (make-emtvr:data
	    :alist ()
	    :tree-insert-cb #'emtv2:receive-cb
	    ;;:tree-remove-cb Not yet
	    ))))

;;;_ , Static printing functions
;;;_  . emtv2:insert-dynamic
(defun emtv2:insert-dynamic (recurse-f obj loal func)
   "Insert (statically) the result of a dynamic spec"
   (let*
      ((fmt-list (funcall func obj loal)))
      (funcall recurse-f fmt-list)))

;;;_  . emtv2:print-all
(defun emtv2:print-all (top-node)
   ""

   (let*
      ((tree (emtvf:top top-node '())))
      (with-current-buffer emtv2:report-buffer
	 (erase-buffer)
	 (loformat:insert
	    tree
	    (append
	       '((dynamic emtv2:insert-dynamic))
	       loformat:default-alist))

	 (outline-mode))))

;;;_ , Overall callback
;;;_  . emtv2:tester-cb


(defun emtv2:tester-cb (report)
   ""
   (check-type report emt:testral:report)
   (emtv2:setup-if-needed)
   (emtvr:newstyle emtv2:receiver report)
   (emtvp:freshen emtv2:pathtree)
   (when
      (emt:testral:report-run-done-p report)
      (emtv2:print-all (emtvp-root emtv2:pathtree))
      (pop-to-buffer emtv2:report-buffer)))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/viewer/emviewer2)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/viewer/emviewer2.el ends here
