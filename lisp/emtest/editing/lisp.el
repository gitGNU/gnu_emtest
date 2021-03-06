;;;_ emtest/editing/lisp.el --- Code for understanding elisp wrt managing tests

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: lisp, maint, internal

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

;; Code for understanding elisp forms, which emtest:defun-at-point etc use


;;;_ , Requires



;;;_. Body

;;;_ , emt:ed:lisp:all-defun-symbols
(defconst emt:ed:lisp:all-defun-symbols 
  '(defun defun* defsubst defsubst* defmacro defmacro* defmethod
      deftype defadvice defstruct 
      emt:deftest-2 emt:deftest-3
      defmath)
   
  "List of defun-variant symbols we might see" )
;;;_ , emt:ed:lisp:suite-sym-at-point-x
(defun emt:ed:lisp:suite-sym-at-point-x (arg)
   "Return the symbol that names the definition at point.
With `nil' ARG, look backwards for it.
With non-nil ARG, look forwards for it."
   (condition-case err
      (save-excursion
	 (beginning-of-defun (if arg -1 nil))
	 (down-list 1)
	 (let*
	    (  (type
		  (read
		     (current-buffer)))
	       (symbol
		  (if
		     (memq type emt:ed:lisp:all-defun-symbols)
		     (read
			(current-buffer)))))
	    (if
	       (and 
		  (eq type 'emt:deftest-3)
		  (listp symbol))
	       ;;Not great, see [[id:sizc6df0xxe0][To eval kv values or not?]]
	       (eval
		  (second
		     (assq 'of symbol)))
	       symbol)))
      (scan-error nil)))
;;;_ , emt:ed:lisp:suite-sym-at-point
(defun emt:ed:lisp:suite-sym-at-point () 
   "Return the symbol of the test suite relevant to the definition at point"
   
   (or
      ;;First try to find it backwards
      (emt:ed:lisp:suite-sym-at-point-x nil)
      ;;If that fails, try to find it forwards
      (emt:ed:lisp:suite-sym-at-point-x -1)))



;;;_. Footers
;;;_ , Provides

(provide 'emtest/editing/lisp)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/editing/lisp.el ends here
