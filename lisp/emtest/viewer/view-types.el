;;;_ emtest/viewer/view-types.el --- Viewable object types for Emtest

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: lisp, internal

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
(require 'emtest/types/run-types)
(require 'utility/pathtree)
(eval-when-compile
   (require 'cl))
;;;_. Body
;;;_ , emt:view:suite-id
(deftype emt:view:suite-id ()
   "The ID of a reported suite.  In fact a how-to-run object"
   'emt:run:how)

;;;_ , Grade summary

(defstruct (emt:view:grade-summary
	      (:constructor emt:view:make-grade-summary)
	      (:copier nil)
	      (:conc-name emt:view:grade-summary->))
   "Class for summarized grades"
   (worst      nil :type symbol
      :doc "The symbol of the worst result-type in the grades.  
If there were no failures etc, `ok'.
But if there were no cases, assertions, etc, `nil'."
      )
   (alert      nil :type boolean
      :doc "Non-nil if user probably wants to see this")
   
   (grades     ()  
      :type
      (repeat (cons symbol integer))))

;;;_ , Presentables
;;;_  . Base viewable

(defstruct (emt:view:presentable
	      (:constructor emt:view:make-presentable)
	      (:conc-name emt:view:presentable->)
	      (:include pathtree:node
		 (sort-children #'pathtree:name-lessp)))
   "The base viewable type.  We use this as the content element in
pathtree nodes."
   (sum-grades () :type emt:view:grade-summary
      :doc
      "Summarized grades from all subtrees.  They are summarized
treewise, including any grades from this node."
      )
   ;;This relates to a display and is nearly obsolete.
   (list ()))

;;;_  . Suite in tree (as by emviewer)
(defstruct (emt:view:suite
	      (:constructor emt:view:make-suite)
	      (:conc-name emt:view:suite->)
	      (:include emt:view:presentable))
   ""
   ;;Just for suite nodes.
   (id () :type emt:view:suite-id
      :doc "The normative id, often the same as explorable:how-to-run.")


   (explorable ():type emt:run:explorable
      :doc "How to run this as a test.")

   ;;So that we can put new results in the same place.
   (presentation-path ()   
      :type emt:testral:suite-id
      :doc "The path to the corresponding node in the pathtree.")

   (testrun-id ()
      :type emt:testral:testrun-id
      :doc "The ID of the testrun that created this result.")
   (result ()     
      :type (or null 
	       emt:testral:suite )
      :doc "The result data itself")
   (mark () :type bool))


;;;_  . An explorable in viewable form.
(defstruct (emt:view:explorable
	      (:constructor emt:view:make-explorable)
	      (:conc-name emt:view:explorable->)
	      (:include emt:view:presentable))
   "An explorable as it occurs in a suite's contents (not within
   the suite itself, which is just displayed inside a suite
   form)"
   (contents () :type emt:run:explorable))

;;;_  . Notes in viewable form.
(defstruct (emt:view:note
	      (:constructor emt:view:make-note)
	      (:conc-name emt:view:note->)
	      (:include emt:view:presentable))
   ""
   (contents () :type emt:testral:note))

;;;_  . Note placeholder
(defstruct (emt:view:note-placeholder
	      (:constructor emt:view:make-note-placeholder)
	      (:conc-name emt:view:note-placeholder->)
	      (:include emt:view:presentable))
   "A blank note-like placeholder, not associated with a TESTRAL note")

;;;_. Footers
;;;_ , Provides

(provide 'emtest/viewer/view-types)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/viewer/view-types.el ends here
