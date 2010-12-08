;;;_ emtest/runner/testral.el --- Testral functions for emtest

;;;_. Headers
;;;_ , License
;; Copyright (C) 2009  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@localhost.localdomain>
;; Keywords: lisp, maint

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

;; 


;;;_ , Requires



;;;_. Body
;;;_ , Declarations
(declare (special emt:testral:*events-seen*))
(declare (special emt:testral:*path-prefix*))
(declare (special emt:testral:*id-counter*))

;;;_ , TESTRAL functions
;;;_  . emtt:testral:with
(defmacro emtt:testral:with (&rest body)
   ""
   
   `(let
      (
	 ;;Counter to make unique IDs.  Although UUIDs are appealing,
	 ;;they are slower to make.
	 (emt:testral:*id-counter* (emtt:testral:create-counter))
	 (emt:testral:*events-seen* (emtt:testral:create))
	 (emt:testral:*path-prefix* ()))
       ,@body))

;;;_  . Continued note-collecting
;;;_   , emtt:testral:make-continuing
(defun emtt:testral:make-continuing ()
   ""
   
   (list (emtt:testral:create-counter) (emtt:testral:create)))


;;;_   , emtt:testral:continued-with
(defmacro emtt:testral:continued-with (obj &rest body)
   ""
   (let
      ((obj-sym (make-symbol "obj")))
      `(let*
	  (
	     (,obj-sym ,obj)
	     (emt:testral:*id-counter*  (first ,obj-sym))
	     (emt:testral:*events-seen* (second ,obj-sym))
	     (emt:testral:*path-prefix* ()))
	  ,@body)))

;;;_ , Support
;;;_  . emtt:testral:create-counter
(defsubst emtt:testral:create-counter ()
   "Create a TESTRAL counter - A list of 1 element"
   (list 1))

;;;_  . emtt:testral:create
;;
(defsubst emtt:testral:create ()
   "Create a TESTRAL receiver - A list of 1 element"
   (list '()))

;;;_  . emtt:testral:add-note
;;Must "note" be a `emt:testral:base'?
(defun emtt:testral:add-note (note &optional name tags arglist)
   "Add NOTE as a TESTRAL note
NOTE must be a type derived from `emt:testral:base'
NAME is a list of strings.
TAGS is not used yet, it controls what notes to add (For now, any note)."
   (when
      (boundp 'emt:testral:*events-seen*)
      (push
	 (if 
	    (typep note 'emt:testral:base)
	    (progn
	       ;;Later, tags will inform a report-manager, which also checks
	       ;;whether to add notes.

	       ;;Set the note's presentation path to w/e plus
	       ;;`emt:testral:*parent-path*'.  Possibly by a count.
	       ;;Name could be nil or a list, or be derived from
	       ;;`emt:testral:*id-counter*'.  It can't be a bare
	       ;;string (yet, for ease of trying this out)
	 
	       (setf (emt:testral:base->prestn-path note)
		  (append emt:testral:*path-prefix* name))
	 

	       ;;Later, for "call" tags, arglist will be processed wrt objects
	       ;;whose origin is known.  This used to relate to the
	       ;;`emt:result:diag:call' type, but the design has changed.
	       note)
	 
	    ;;Give an error note instead.
	    (emt:testral:make-error-raised
	       :err 
	       '(error 
		   "A non-TESTRAL object was tried to be used as note")
	       :badnesses 
	       '((ungraded 'error 
		    "A non-TESTRAL object was tried to be used as note"))))
	 (cdr emt:testral:*events-seen*))))

;;;_  . emtt:testral:report-false
;;Higher level, may belong elsewhere.
(defun emtt:testral:report-false (prestn-prefix str)
   "Report that a compare leaf was false"
   ;;For now, we just use a `doc' note.
   (emtt:testral:add-note
      (emt:testral:make-doc :str str)
      prestn-prefix))


;;;_  . emtt:testral:note-list
(defun emtt:testral:note-list ()
   ""
   (emt:testral:make-note-list
      :notes
      ;;Reverse the note list so it's in the order that it
      ;;was received in.
      (nreverse (cdr emt:testral:*events-seen*))))

;;;_  . emtt:testral:set-object-origin
(defun emtt:testral:set-object-origin (object origin)
   ""

   ;;Punt for now.  Later, store its identity on some sort of alist.
   (let*
      ()
      
      ))


;;;_. Footers
;;;_ , Provides

(provide 'emtest/runner/testral)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/runner/testral.el ends here
