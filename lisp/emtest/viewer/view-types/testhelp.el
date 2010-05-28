;;;_ emtest/viewer/view-types/testhelp.el --- Testhelp file for view-types

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

(require 'emtest/viewer/view-types)

;;;_. Body
(defconst emtvr:thd
   (append
      emt:testral:thd:examples
      (emtg:define+ ()
	 (group
	    ((type receive-alist-item))
	    (type-must-be () (emtm:pattern emtvr:suite-newstyle))
	    (item
	       ( (role original-add)
		  (what-test test-1))
	       (emtg:with 
		  (append emt:testral:thd:examples emtg:all-examples)
		  ()
		  (emtm:make-pattern
		     (emtvr:make-suite-newstyle
			:result 
			(eval
			   '(emtg (type suite)(what-test test-1)(role original-add)))
			:how-to-run
			(eval 
			   '(emtg (type explorable)(what-test test-1)))
			:id
			(eval 
			   '(emtg (type how-to-run)(what-test test-1)))
			:presentation-path
			(eval 
			   '(emtg (type presentation-path)(what-test test-1)))
			:testrun-id 
			(eval 
			   '(emtg (type testrun-id)(role original-add)))))))

	    (item
	       ( (role replace)
		  (what-test test-1))
	       (emtg:with 
		  (append emt:testral:thd:examples emtg:all-examples)
		  ()
		  (emtm:make-pattern
		     (emtvr:make-suite-newstyle
			:result 
			(eval
			   '(emtg (type suite)(what-test test-1)(role replace)))
			:how-to-run
			(eval 
			   '(emtg (type explorable)(what-test test-1)))
			:id
			(eval 
			   '(emtg (type how-to-run)(what-test test-1)))
			:presentation-path
			(eval 
			   '(emtg (type presentation-path)(what-test test-1)))
			:testrun-id 
			(eval 
			   '(emtg (type testrun-id)(role replace))))))))))
   "View-types examples plus TESTRAL report examples."
   )


;;;_. Footers
;;;_ , Provides

(provide 'emtest/viewer/view-types/testhelp)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/viewer/view-types/testhelp.el ends here
