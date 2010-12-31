;;;_ emtest/viewer/emformat.el --- Formatting functions specific to Emtest

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

(require 'formatter/hiformat)
(require 'formatter/loformat)
(require 'formatter/outline)
(require 'emtest/viewer/view-types)
(require 'emtest/types/grade-types)
(require 'custom)
(require 'emtest/viewer/all-note-formatters)

;;;_. Body
;;;_ , Data
;;;_  . Faces
;;;_   , Grades
(defface emtvf:face:ok 
   '((default :foreground "green3" :weight bold))
   "Face for reporting passed tests"
   :group 'emtest)

(defface emtvf:face:failed 
   '((default :foreground "red" :weight bold))
   "Face for reporting failed tests"
   :group 'emtest)

(defface emtvf:face:ungraded
   '((default :foreground "red" :strike-through t))
   "Face for reporting ungraded tests"
   :group 'emtest)

(defface emtvf:face:blowout 
   '((default :foreground "black" :background "red" :weight bold))
   "Face for reporting blown-out tests"
   :group 'emtest)

(defface emtvf:face:dormant
   '((default :foreground "black"))
   "Face for reporting dormant tests"
   :group 'emtest)

;;;_   , Comparisons
(defface emtvf:face:mismatch
   '((default :foreground "pink" :weight bold))
   "Face for reporting mismatches.
NB, this is not a grade.  It indicates failure of a comparison,
which may not imply failure of an assertion."
   :group 'emtest)

(defface emtvf:face:ok-match
   '((default :foreground "green4" :weight bold))
   "Face for reporting correct matches.
NB, this is not a grade.  It indicates a successful comparison,
which may not imply success of an assertion."
   :group 'emtest)

;;;_   , Pieces
(defface emtvf:face:title
   '((default 
	:height 1.8
	:foreground "black"))
   
   "Face for displaying Emtest banner"
   :group 'emtest)
(defface emtvf:face:suitename
   '((default 
	:foreground "blue1"))
   
   "Face for displaying test names"
   :group 'emtest)

;;;_ , Lower format functions
;;;_ , Helper functions
;;;_  . Singles-Path
;;;_   , Special variables
(declare (special emtvf:*hdln-path*))
(eval-after-load 'utility/dynvars
   '(progn
      (utidyv:register-var 'emtvf:*hdln-path* '())))
;;;_   , emtvf:with-blank-singles-path
(defmacro emtvf:with-blank-singles-path (&rest body)
   "Eval BODY in a blank singles-path."
   
   `(let ((emtvf:*hdln-path* '()))
       ,@body))
;;;_   , emtvf:with-more-singles-path
(defmacro emtvf:with-more-singles-path (name &rest body)
   ""
   
   `(let ((emtvf:*hdln-path* (cons name emtvf:*hdln-path*)))
       ,@body))

;;;_   , emtvf:singles-path
(defun emtvf:singles-path ()
   ""
   (apply #'nconc
      (mapcar
	 #'(lambda (x)
	      (list x " "))
	 (nreverse (remq nil emtvf:*hdln-path*)))))
;;;_  . Buttons
;;;_   , emtvf:button-to-explore
(defun emtvf:button-to-explore (explorable text)
   "Make a button to explore EXPLORABLE.
Hack: We add a space after the button."
   (when explorable
      (let
	 ((func
	     `(lambda (button)
		 (interactive)
		 (emtl:dispatch-normal
		    ',(emtt:explorable->how-to-run 
			 explorable)
		    ',(emtt:explorable->prestn-path 
			 explorable)))))
	 `(button ,text 
	     action ,func
	     help-echo "Rerun this test"))))
;;;_  . Objects
;;;_   , emtvf:obj-or-string
(defun emtvf:obj-or-string (value)
   "Display VALUE.
If VALUE is a string, display it literally, otherwise pretty-print it."
   (if
      (stringp value)
      ;;Indent it so it can't affect outline
      ;;structure. 
      `(indent 4 ,value)
      `(object ,value nil)))
;;;_  . Direct emformat support
;;;_   , emtvf:outline-item-emformat
(defmacro emtvf:outline-item-emformat (headtext contents &optional face fold)
   ""
   
   `(emtvf:outline-item
       (list (emtvf:singles-path) ,headtext)
       (emtvf:with-blank-singles-path ,contents)
       ,face
       ,fold))

;;;_   , emtvf:mapnodes 
(defun emtvf:mapnodes (list els=0)
   "Map emtvf:node over LIST, making dynamic entries"
   (hiformat:map 
      #'(lambda (obj &rest d)
	   (emtvf:make-dynamic 
	      obj 
	      #'emtvf:node))
      list
      :separator "\n"
      :els=0 els=0))

;;;_  . emtvf:shortcut-single
(defmacro emtvf:shortcut-single (name children rest-headline face format-no-child)
   "Display an item and its children, or display its single child.
Intended for items that are basically just containers."
   (let
      ((name-sym (make-symbol "name"))
	 (children-sym (make-symbol "children")))
      `(let
	  ((,name-sym ,name)
	     (,children-sym ,children))
	  (if
	     (= (length ,children-sym) 1)
	     (emtvf:with-more-singles-path ,name-sym
		(emtvf:make-dynamic 
		   (car ,children-sym)
		   #'emtvf:node))
	     (emtvf:outline-item-emformat
		(list ,name-sym ,rest-headline)
		(emtvf:mapnodes ,children-sym ,format-no-child)
		,face)))))

;;;_ , Format functions
;;;_  . emtvf:top

(defun emtvf:top (view-node)
   "Make a format form for VIEW-NODE.
VIEW-NODE must be at least an `emtvp:node'."

   (check-type view-node emtvp:node)
   (utidyv:top 
      ;;$$IMPROVE ME  Make this a var, shared with capturer.
      '((emtvf:*hdln-path*) 
	  (emtvf:*folded*) 
	  (emtvf:*outline-depth* 0))
      `(
	  (w/face "Emtest results" emtvf:face:title)
	  "\n"
	  ,(emtvf:node view-node))))

;;;_  . emtvf:node
(defun emtvf:node (view-node)
   "Make a format form for VIEW-NODE.
VIEW-NODE must be an `emt:view:presentable'.
Must be called in a `utidyv:top' context."

   (check-type view-node emtvp:node)

   (let*
      ((suite view-node)
	 (name
	    (emtvp:node->name view-node))
	 (children
	    (emtvp:node->children view-node))
	 (grades
	    (emt:view:presentable->sum-grades suite))
	 (grade-face
	    (emtvf:grade-overall-face grades))
	 (grades-sum
	    (emtvf:sum-grades-short grades))
	 (boring-p 
	    (emtvf:grade-boring grades)))
      
      (etypecase suite
	 (emt:view:suite
	    (let*
	       (
		  (object
		     (emt:view:suite->result suite))
		  (explorable
		     (emt:view:suite->how-to-run suite)))
	       (etypecase object
		  (null "A null viewable")
		  (emt:testral:test-runner-info
		     (emtvf:outline-item-emformat
			(hiformat:separate
			   (list
			      `(w/face ,name emtvf:face:suitename)
			      grades-sum)
			   " ")
			(emtvf:mapnodes children "No child suites") 
			grade-face
			boring-p))
		  
		  
		  (emt:testral:suite
		     (emtvf:outline-item-emformat
			(hiformat:separate
			   (delq nil
			      (list
				 `(w/face ,name emtvf:face:suitename)
				 (emtvf:button-to-explore explorable "[RUN]")
				 grades-sum))
			   " ")
			(emtvf:mapnodes children "No child suites")
			grade-face
			boring-p)))))
	 
	 (emt:view:note
	    (emtvf:TESTRAL view-node))

	 (emt:view:note-placeholder
	    (emtvf:shortcut-single
	       nil
	       (emtvp:node->children view-node)
	       '()
	       nil
	       "[Note placeholder with no children]"))
	 
	 ;;Base type, appears for the root node.
	 (emt:view:presentable
	    (emtvf:shortcut-single 
	       nil
	       (emtvp:node->children view-node)
	       grades-sum
	       grade-face
	       "[Suite placeholder with no children]")))))


;;;_  . emtvf:TESTRAL (TESTRAL note formatter)
(defun emtvf:TESTRAL (obj &rest d)
   "Make a format form for OBJ.
OBJ must be a TESTRAL viewable (`emt:view:note')."
   (check-type obj emt:view:note)
   (condition-case err
      (let
	 ((note (emt:view:note->contents obj)))
	 (apply 
	    (emtvf:get-TESTRAL-formatter 
	       (emt:testral:note->governor note))
	    obj
	    (emt:testral:note->value note)))
      (error
	 `((w/face "Error in formatter: " emtvf:face:blowout) 
	     (object ,err nil)
	     "\n"))))

;;;_ , About grades
;;;_  . emtvf:grade-boring
(defun emtvf:grade-boring (obj)
   "Return non-nil if OBJ is all passing grades.
OBJ must be a `emt:testral:grade:summary'"
   ;;$$REDESIGN ME  Complete hack here.
   (eq (emtvf:grade-overall-face obj) 'emtvf:face:ok))

;;;_  . emtvf:grade-overall-face
(defun emtvf:grade-overall-face (obj)
   ""
   
   (let*
      (
	 (obj (emtvr:grade->summary obj))
	 (test-cases (emt:testral:grade:summary->test-cases obj))
	 (fails      (emt:testral:grade:summary->fails      obj))
	 (ungradeds  (emt:testral:grade:summary->ungradeds  obj))
	 (dormants   (emt:testral:grade:summary->dormants   obj))
	 (blowouts   (emt:testral:grade:summary->blowouts   obj)))
      (cond
	 ((> blowouts   0) 'emtvf:face:blowout)
	 ((> ungradeds  0) 'emtvf:face:ungraded)
	 ((> fails      0) 'emtvf:face:failed)
	 ((> dormants   0) 'emtvf:face:dormant)
	 ((> test-cases 0) 'emtvf:face:ok)
	 (t                'emtvf:face:dormant))))

;;;_  . emtvf:sum-grades-short
(defun emtvf:sum-grades-short (obj &rest d)
   "Give a summary of grades for this object."
   (let*
      (
	 (obj (emtvr:grade->summary obj))
	 (test-cases (emt:testral:grade:summary->test-cases obj))
	 (fails      (emt:testral:grade:summary->fails      obj))
	 (ungradeds  (emt:testral:grade:summary->ungradeds  obj))
	 (dormants   (emt:testral:grade:summary->dormants   obj))
	 (blowouts   (emt:testral:grade:summary->blowouts   obj)))
      (if
	 (and
	    (= fails     0)
	    (= ungradeds 0)
	    (= dormants  0)
	    (= blowouts  0))
	 (if (> test-cases 0)
	    (list
	       '(w/face "All OK" emtvf:face:ok)
	       " ("
	       (hiformat:grammar:num-and-noun
		  test-cases "case" "cases")
	       ")")
	    '(w/face "Nothing was tested" emtvf:face:dormant))
	 (list
	    '(w/face "Problems: " emtvf:face:failed)
	    (hiformat:separate
	       (delq nil
		  (mapcar
		     #'(lambda (data)
			  (destructuring-bind (n text face) data
			     (when (> n  0) 
				`(w/face ,text ,face))))
		     (list
			(list blowouts  "Blowouts"	 'emtvf:face:blowout)
			(list ungradeds "Ungraded tests" 'emtvf:face:ungraded)
			(list fails     "Failures" 	 'emtvf:face:failed)
			(list dormants  "Dormant tests"  'emtvf:face:dormant))))
	       '(", "))
	    "."))))


;;;_  . emtvf:sum-grades-long
(defun emtvf:sum-grades-long (obj &rest d)
   "Give a summary of grades for this object."
   (let*
      (
	 (obj (emtvr:grade->summary obj))
	 (test-cases (emt:testral:grade:summary->test-cases obj))
	 (fails      (emt:testral:grade:summary->fails      obj))
	 (ungradeds  (emt:testral:grade:summary->ungradeds  obj))
	 (dormants   (emt:testral:grade:summary->dormants   obj))
	 (blowouts   (emt:testral:grade:summary->blowouts   obj)))
      (if
	 (and
	    (= fails     0)
	    (= ungradeds 0)
	    (= dormants  0)
	    (= blowouts  0))
	 (if (> test-cases 0)
	    (list
	       "All OK ("
	       (prin1-to-string test-cases)
	       " "
	       (hiformat:grammar:number-agreement 
		  test-cases "case" "cases")
	       ")" "\n")
	    (list "Nothing was tested" "\n"))
	 (list
	    "Problems: \n"
	    (hiformat:separate
	       (delq nil
		  (list
		     (when (> blowouts  0) 
			(hiformat:grammar:num-and-noun 
			   blowouts
			   "Blowout" "Blowouts"))
		     (when (> ungradeds 0) 
			(hiformat:grammar:num-and-noun 
			   ungradeds
			   "Ungraded test" "Ungraded tests"))
		     (when (> fails     0) 
			(hiformat:grammar:num-and-noun 
			   fails
			   "Failure" "Failures"))
		     (when (> dormants  0) 
			(hiformat:grammar:num-and-noun 
			   dormants
			   "Dormant test" "Dormant tests"))))
	       '(".\n"))
	    "\n"
	    (if (> test-cases 0)
	       (list
		  (prin1-to-string test-cases)
		  " successful "
		  (hiformat:grammar:number-agreement 
		     test-cases "test case" "test cases"))
	       (list "No test cases succeeded"))
	    "\n"))))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/viewer/emformat)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/viewer/emformat.el ends here
