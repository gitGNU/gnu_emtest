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

(require 'utility/pathtree) ;;The view-node type
(require 'utility/loal)     ;;The data-list type
(require 'viewers/hiformat)
(require 'viewers/loformat)
(require 'emtest/viewer/view-types)
(require 'emtest/common/grade-types)
(require 'custom)

;;;_. Body
;;;_ , Data
;;;_  . emtvf:format-alist
(defconst emtvf:format-alist loformat:default-alist
   "List of formatters that emformat uses." )
;;;_  . Faces
(defface emtvf:face:ok 
   '((default :foreground "green3" :weight bold))
   "Face for reporting passed tests")

(defface emtvf:face:failed 
   '((default :foreground "red" :weight bold))
   "Face for reporting failed tests")

(defface emtvf:face:ungraded
   '((default :foreground "red" :strike-through t))
   "Face for reporting ungraded tests")

(defface emtvf:face:blowout 
   '((default :foreground "black" :background "red" :weight bold))
   "Face for reporting blown-out tests")

(defface emtvf:face:dormant
   '((default :foreground "black"))
   "Face for reporting dormant tests")

(defface emtvf:face:title
   '((default :inherit info-title-1))
   "Face for displaying Emtest banner")
;;;_ , Lower format functions
;;;_  . emtvf:insert
(defun emtvf:insert (top-node data-list extra-formats)
   "Insert TOP-NODE via loformat"
   
   (let*
      ((tree (emtvf:top top-node data-list)))
      (loformat:insert
	 tree
	 (append
	    extra-formats
	    emtvf:format-alist))))
;;;_ , Format functions
;;;_  . emtvf:top

(defun emtvf:top (view-node data-list)
   "VIEW-NODE must be at least an `emtvp:node'."

   (check-type view-node emtvp:node)
   `(
       (w/face "Emtest results" emtvf:face:title)
       "\n"
       ,(emtvf:node view-node data-list)))
;;;_  . emtvf:headline
(defun emtvf:headline (depth face headtext)
   "Make a headline of HEADTEXT for DEPTH, using FACE"
   
   `(
       (sep 3)
       (w/face ,(make-string depth ?*) ,face)
       " " 
       ,headtext
       (sep 2)))


;;;_  . emtvf:headline-w-badnesses
(defun emtvf:headline-w-badnesses (depth name badnesses data-list)
   "Make a headline for NAME, describing BADNESSES. "
   (emtvf:headline 
      depth 
      (emtvf:grade-overall-face badnesses) 
      `(
	  ;;This is used in the dynamic treatment.
	  ,(apply #'append
	      (mapcar
		 #'(lambda (x)
		      (list x " "))
		 (loal:val 'hdln-path data-list '())))
	  (w/face ,name font-lock-function-name-face)
	  " "
	  ,(emtvf:sum-badnesses-short badnesses data-list))))


;;;_  . emtvf:node
(defun emtvf:node (view-node data-list)
   "
VIEW-NODE must be an `emt:view:presentable'.
DATA-LIST must be a list of alists."

   (check-type view-node emtvp:node)

   (let
      ((suite view-node)
	 (name
	    (emtvp:node->name view-node))
	 (children
	    (emtvp:node->children view-node))
	 (depth
	    (loal:val 'depth data-list 0)))

      (etypecase suite
	 (emt:view:suite-newstyle
	    (let
	       (
		  (object
		     (emt:view:suite-newstyle->result suite)))
	       (append
		  (emtvf:headline-w-badnesses 
		     (1+ depth)
		     name
		     (emt:view:presentable->sum-badnesses suite)
		     data-list)
		  (etypecase object
		     (null)
		     (emt:testral:test-runner-info
			(list*
			   "Suites tested in " name "\n"
			   (hiformat:map 
			      ;;Formatting for each child
			      #'(lambda (obj data &rest d)
				   (list
				      `(dynamic ,obj 
					  ,(loal:acons 'depth (1+ depth) data)
					  ,#'emtvf:node)))
			      children
			      :data-loal data-list
			      :separator '("\n"))))
		  
		     (emt:testral:suite
			(append
			   ;;$$IMPROVE ME Add a button to rerun the
			   ;;test.
			   ;;(emtvr:suite-newstyle->how-to-run cell)
			   ;;`how-to-run' informs a button.  For now,
			   ;;just use the `emthow'.  Later we may keep
			   ;;or build an `emtt:explorable'
			   ;;or even an `emtt:method'

			   (etypecase (emt:testral:suite->contents object)
			      (emt:testral:runform-list
				 (hiformat:map 
				    ;;Formatting for each child
				    #'(lambda (obj data &rest d)
					 (list
					    `(dynamic ,obj 
						,(loal:acons 
						    'depth (1+ depth) data)
						,#'emtvf:node)))
				    children
				    :data-loal data-list
				    :separator '("\n")
				    :els=0 '("No child suites")))
			      (emt:testral:note-list
				 (hiformat:map
				    #'emtvf:TESTRAL
				    (emt:testral:note-list->notes
				       (emt:testral:suite->contents object))
				    :data-loal data-list
				    :separator '("\n")
				    :els=0 '("No notes")))
			      (null
				 '("No known contents")))

			   ))))))

	 ;;For the various TESTRAL expansions.
	 ;;For now, these aren't even relevant yet.
	 (emt:view:TESTRAL
	    '("Testral data"))
	 
	 (emt:view:TESTRAL-unexpanded
	    '("Unexpanded TESTRAL data"))

	 ;;Base type, for blank nodes.  
	 (emt:view:presentable
	    (if
	       (and
		  (= (length children) 1))
	       (list
		  `(dynamic ,(car children)
		      ;;$$IMPROVE ME Get value from old hdln-path
		      ;;(loal:update 'hdln-path FUNC-WRITE-ME data-list '())
		      ,(loal:acons 'hdln-path (list name) data-list)
		      ,#'emtvf:node))
	       (let
		  ((ch-data-list
		      (loal:acons 'hdln-path '() data-list)))
		  (append
		     (emtvf:headline-w-badnesses 
			(1+ depth)
			name
			(emt:view:presentable->sum-badnesses suite)
			data-list)

		     "\n"
		     (hiformat:map 
			;;Formatting for each child
			#'(lambda (obj data &rest d)
			     (list
				`(dynamic ,obj 
				    ,(loal:acons 'depth (1+ depth) data)
				    ,#'emtvf:node)))
			children
			:separator '("\n")
			:data-loal data-list))))))))

;;;_  . emtvf:TESTRAL (TESTRAL note formatter)
(defun emtvf:TESTRAL (obj data &rest d)
   ""
   
   (let*
      ((depth
	  ;;$$FIX ME We are not getting the incremented depth here.
	  (1+ (loal:val 'depth data-list 0))))
      (append
	 (apply #'append
	    (mapcar
	       #'(lambda (x)
		    (list x " "))
	       (emt:testral:base->prestn-path obj)))
	 (etypecase obj
	    ;;This is the only one that will actually carry over in the
	    ;;long term, the others are actually obsolescent.

	    (emt:testral:alone
	       (typecase obj
		  (emt:testral:error-raised
		     `(
			 ,(emtvf:headline 
			     (1+ depth)
			     'emtvf:face:ungraded
			     "Error raised: ")
			 ,(prin1-to-string
			     (emt:testral:error-raised->err obj))
			 "\n"))
		  (emt:testral:doc
		     (let
			((doc (emt:testral:doc->str obj)))
			(cond
			   ((not (string-match "\n" doc))
			      `(
				  ,(emtvf:headline 
				      (1+ depth)
				      nil
				      doc)))
			   ((string-match ": " doc)
			      `(
				  ,(emtvf:headline 
				      (1+ depth)
				      nil
				      (substring
					 doc
					 0
					 (match-end 0)))
				  ,(substring
				      doc
				      (match-end 0))
				  "\n"))
			   (t
			      `(
				  ,(emtvf:headline 
				      (1+ depth)
				      nil
				      "Doc ")
				  ,(emt:testral:doc->str obj)
				  "\n")))))
		  
		  (emt:testral:not-in-db
		     ;;$$IMPROVE ME Add a button to accept value,
		     ;;putting it in the database.
		     `(
			 ,(emtvf:headline 
			     (1+ depth)
			     'emtvf:face:ungraded
			     "ID not in database ")
			 ,(emtvf:headline 
			     (+ 2 depth)
			     nil
			     "Value ")
			 ,(object (emt:testral:not-in-db->value obj))
			 ;;$$CHECK ME Is this too prolix wrt ID and
			 ;;backend?  Maybe a plain list instead.
			 ,(emtvf:headline 
			     (+ 2 depth)
			     nil
			     "ID ")
			 ,(object (emt:testral:not-in-db->id-in-db obj))
			 ,(emtvf:headline 
			     (+ 2 depth)
			     nil
			     "Backend ")
			 ,(object (emt:testral:not-in-db->backend obj))))
		  
		  
		  (t '((nl-if-none )
			 ,(emtvf:headline 
			     (1+ depth)
			     nil
			     "Doc ")
			 "A TESTRAL note (alone)"
			 "\n"))))

	    ;;Temporary
	    (emt:testral:check:push
	       '("Begin a TESTRAL check"))
	 
	    (emt:testral:push
	       '("Begin a TESTRAL span"))
	 
	    (emt:testral:pop
	       '("End a TESTRAL span"))
	    (emt:testral:separate
	       '("Separate args"))))))

;;;_  . emtvf:info (Suite info formatter)
(defun emtvf:info (obj data &rest d)
   ""
   
   (let*
      ()
      '("Information: None" "\n")
      ))
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

;;;_  . emtvf:sum-badnesses-short
(defun emtvf:sum-badnesses-short (obj data &rest d)
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
	    (hiformat:map 
	       #'(lambda (obj &rest r)
		    obj)
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
	       
	       :separator '(", "))
	    "."))))


;;;_  . emtvf:sum-badnesses-long
(defun emtvf:sum-badnesses-long (obj data &rest d)
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
	    (hiformat:map 
	       #'(lambda (obj &rest r)
		    obj)
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
	       :separator '(".\n"))
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
