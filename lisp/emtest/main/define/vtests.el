;;;_ tester/define/vtests.el --- Version-controlled tests for Emtest define

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

;; 


;;;_ , Requires

(require 'emtest/testhelp/misc)
(require 'emtest/testhelp/standard)
(require 'emtest/testhelp/mocks/libversion)
(emtmv:require 'emtest/main/define)

;;;_. Body

;;;_  . emt:def:make-prop-eval-form
(emt:deftest-3 emt:def:make-prop-eval-form
   (nil
      (progn
	 (emt:doc "Shows: Makes a form that evals as expected.")
	 (progn
	    (emt:assert
	       (equal
		  (eval
		     (emt:def:make-prop-eval-form
			'(four
			    (+ 2 2))))
		  '(four 4)))
	    (emt:assert
	       (equal
		  (eval
		     (emt:def:make-prop-eval-form
			'(four-form
			    '(+ 2 2))))
		  '(four-form
		      (+ 2 2))))
	    t))))


;;;_  . emt:deftest-3

;;There's a bootstrap problem in defining a suite to test this, so
;;this has to be run manually or thru libversion
(emt:deftest-3 emt:deftest-3
   (nil
      (progn
	 (emth:let-noprops '(dummy-sym)
	    (emt:doc "Situation: A test is defined.")
	    (emt:deftest-3 dummy-sym
	       (nil
		  (progn 12)))
	    (emt:doc "Response: Destructuring finds the expected clauses.")
	    (emt:def:destructure-suite-3 'dummy-sym
	       (emt:assert
		  (=
		     (length clause-list)
		     1))
	       (let*
		  ((clause (car clause-list)))
		  (equal 
		     (car (emt:def:clause->form clause)) 
		     '(progn 12)))
	       t))))
   (nil
      (progn
	 (emth:let-noprops '(dummy-sym)
	    (emt:doc "Situation: A test is defined with properties")
	    (emt:deftest-3
	       ((of 'dummy-sym)
		  (db-id "my-db")
		  (four
		     (+ 2 2))
		  (four-form
		     '(+ 2 2)))
	       (nil
		  (progn 12)))
	    (emt:doc "Response: Destructuring finds the expected properties.")
	    (emt:def:destructure-suite-3 'dummy-sym
	       (emt:assert
		  (equal
		     (assoc 'db-id props)
		     '(db-id "my-db")))
	       (emt:assert
		  (equal
		     (assoc 'four props)
		     '(four 4)))
	       (emt:assert
		  (equal
		     (assoc 'four-form props)
		     '(four-form
			 (+ 2 2))))
	       t))))
   (nil
      (progn
	 (emth:let-noprops '(dummy-sym)
	    (emt:doc "Situation: A test is defined with no clauses")
	    (emt:deftest-3 dummy-sym)
	    (emt:doc "Response: Destructuring finds clauses as the empty list.")
	    (emt:def:destructure-suite-3 'dummy-sym
	       (emt:assert
		  (=
		     (length clause-list)
		     0))
	       t)))))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/main/define/vtests)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; tester/define/vtests.el ends here
