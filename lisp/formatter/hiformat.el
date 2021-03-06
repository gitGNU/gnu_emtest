;;;_ formatter/hiformat.el --- Hi-level formatting functionality for Emtest

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

;; For format functions that prefer to be called at form-creation
;; time, not at insertion time.

;;;_ , Requires
(eval-when-compile
   (require 'cl))

;;;_. Body
;;;_ , Types
;;;_  . hiformat:xformer
(deftype hiformat:xformer ()
   "A formatting function.  
 * Takes an input object.
 * Return value is a hiformat:format.

The type only demands a function, so it's mostly for
   documentation."
   '(satisfies functionp))

;;;_ , Functions
;;;_  . hiformat:map Map over a list
(defun* hiformat:map (func list &key separator els=0 els=1)
   "Format LIST, using FUNC to transform each element.
FUNC must be a function taking 2 args:
 * Object
 * Immediate data.  This is a list.  It will contain `first', `last'
   and `index' set to appropriate values.

ELS=0 is used if the list is empty.  ELS=0 must be a formattable.

ELS=1, if given, is used if the list has just 1 element (a singleton).
ELS=1 must be a function taking 1 arg, the singleton object."
   (check-type func hiformat:xformer)
   (let*
      ((len (length list)))
      (cond
	 ((= len 0) els=0)  ;;Correct even if els=0 is nil
	 ((and (= len 1) els=1)
	    (funcall els=1 (car list)))
	 (t
	    (loop
	       for el in list
	       for index from 0
	       collect
	       (let* 
		  ;;Create appropriate loop variables
		  (
		     (immediate-data
			(append
			   (list (list 'index index))
			   (if (= index 0)        '((first t)) '())
			   (if (= index (1- len)) '((last t))  '())))
		     (sub-list
			(funcall func el immediate-data)))
	    
		  (if (= index 0) 
		     sub-list
		     (let
			((sep-form
			    (if (functionp separator)
			       (funcall separator immediate-data)
			       separator)))
			(if sep-form
			   (list nil sep-form sub-list)
			   sub-list)))))))))
;;;_  . hiformat:separate
(defun hiformat:separate (list &optional separator)
   "Separate the items in LIST.
SEPARATOR, if non-nil, separates the items, otherwise a single
space separates them."
   (hiformat:map
      #'(lambda (obj &rest r) obj)
      list
      :separator (or separator " ")))

;;;_ , Slightly touching on grammar
;;;_  . hiformat:grammar:number-agreement
(defun hiformat:grammar:number-agreement (n singular plural)
   ""
   
   (if (= n 1) singular plural))

;;;_  . hiformat:grammar:num-and-noun
(defun hiformat:grammar:num-and-noun (n singular plural)
   ""
   (list 
      (prin1-to-string n)
      " "
      (hiformat:grammar:number-agreement 
	 n singular plural)))

;;;_. Footers
;;;_ , Provides

(provide 'formatter/hiformat)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; formatter/hiformat.el ends here
