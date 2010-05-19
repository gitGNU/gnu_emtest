;;;_ tester/tester/rtest.el --- Tests for tester/tester

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
(require 'emtest/runner/tester)
(require 'emtest/runner/tester/testhelp)
(require 'emtest/runner/launch/testhelp) ;;For emtt:th:run-suite

;;;_. Body
;;;_   , emtts:surround
' ;;OBSOLETE.  See `emtt:add-surrounders'
(rtest:deftest emtts:surround

   (  "Args: Empty list of protectors.
Result: Just form."
      (equal
	 (emt:tester:surround 'foo ())
	 'foo))
   
   (  "Args: List of one protector.
Result: Form is surrounded by that protector."
      (equal
	 (emt:tester:surround 'foo '(progn))
	 '(progn foo)))

   (  "Args: List of one protector, more complicated form.
Result: More complicated form is correctly surrounded."
      (equal
	 (emt:tester:surround '(let (a b) foo) '(progn))
	 '(progn (let (a b) foo))))

   (  "Args: List of three protectors.
Result: Form is surrounded by all three in order, first outermost."
      (equal
	 (emt:tester:surround 'foo '(progn save-excursion with-temp-buffer))
	 '(progn (save-excursion (with-temp-buffer foo)))))
   
   )

;;;_   , emtts:get-extra-protectors
'
(rtest:deftest emtts:get-extra-protectors

   ;;Test of emt:tester:get-extra-protectors.  Requires a bogus
   ;;tests-own-args object -- but syntax is immature right now.
   (  "Situation: protectors is not a list
Response: Error."
      (progn) ;;Test-form
      )
   )

;;;_   , emtts:get-surrounders
'
(rtest:deftest emtts:get-surrounders
   
   
   (  "Demonstrate: emt:tester:get-surrounders returns a list of symbols."
      
      (every
	 #'symbolp
	 (emt:tester:get-surrounders 
	    emtts:thd:simplest-tests-own-args
	    nil)))
   

   (  "Demonstrate: emt:tester:get-surrounders returns a list of symbols."
      
      (every
	 #'symbolp
	 (emt:tester:get-surrounders 
	    emtts:thd:simplest-tests-own-args
	    t)))
   
   ;;Since tester's always-surrounders is not controlled by this, we
   ;;can't test proper contents, but since we just append, should be
   ;;no problem.
   )

;;;_    . emtt:trap-errors

(rtest:deftest emtt:trap-errors
   '  ;;OBSOLETE
   (  "Shows: Works with `emtts:surround'."
      (equal
	 (eval
	    (emt:tester:surround 12 '(emtt:trap-errors)))
	 
	 12))
   
   (  "Situation: Body throws an emt:already-handled error.
Response: (Punt) Marks the event-group aborted.
Adds no error report.
Does not signal error."
      (progn
	 (assert
	    (not
	       (emt:gives-error
		  (emtt:trap-errors
		     (signal 'emt:already-handled ())))))
	 t))
   
   ;;More to add.  See [[id:ca903ca0-bd5d-4985-8cd3-a5a4dd998b5c][]]
   
   )



;;;_ , emtt:get-properties
(rtest:deftest emtt:get-properties

   (  "Situation: A test is defined with properties.
That test is now being run.
Behavior: `emtt:get-properties' returns the relevant property."
      (let-noprops '(dummy-sym)
	 (emt:deftest-3 
	    (
	       (of 'dummy-sym)
	       (db-id "my-db")
	       (example-dir "examples/"))
	    (()
	       (progn
		  (emt:doc "Docstring" )
		  (emtp 531a913c-aa10-4730-9be5-30c1cb02b7c4
		     ()
		     t))))
	 
	 (emtp:eval
	    (emtt:th:run-suite 'dummy-sym #'ignore)
	    (tp 531a913c-aa10-4730-9be5-30c1cb02b7c4
	       ()
	       (progn
		  (assert
		     (equal
			(emtt:get-properties 'db-id)
			"my-db")
		     t)
		  (assert
		     (equal
			(emtt:get-properties 'example-dir)
			"examples/")
		     t))))
	 t)))



;;;_ , emtt:explore-clause
(rtest:deftest emtt:explore-clause
   
   ;;Check that it stores top-level badnesses.
   ;;Check that it stores top-level info.

   )

;;;_  . emtt:explore-one

(put 'emtt:explore-one 'rtest:test-thru
   'emt:test-finder:top)

;;;_   , emt:test-finder:top

(rtest:deftest emt:test-finder:top

   (  "Shows: It passes callback an `emt:testral:report'."
      (progn
	 (emtt:th:explore-one '(error "An example error") 
	    #'(lambda (report)
		 (check-type report emt:testral:report)
		 (let
		    ((emty:use t))
		    (check-type report emt:testral:report))))
	 t)))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/runner/tester/rtest)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; tester/tester/rtest.el ends here