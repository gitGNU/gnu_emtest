;;;_ formatter/dynamic/tests.el --- Tests for formatter/dynamic

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

(require 'formatter/dynamic)

;;;_. Body
;;;_ , Config
(defconst formatter/dynamic:td:db-file
   (emtb:expand-filename-by-load-file "db")
   "The file where the database is located" )
;;;_ , Insulation
(defconst formatter/dynamic:th:surrounders 
   '()
   "The normal surrounders for formatter/dynamic tests" )
;;;_ , 
(defconst formatter/dynamic:th:format-alist 
   '((dynamic fmtdyn:insert))
   "" )
;;;_ , Tests
(emt:deftest-3
   ((of 'fmtdyn:insert)
      (db-id
	 `(persist ,formatter/dynamic:td:db-file)))
   (nil
      (with-temp-buffer
	 (let
	    ((my-fmtdyn (fmtdyn:create)))
	    (emt:doc "Situation: In an empty temp buffer, with a fmtdyn.")
	    (emt:doc "Operation: Insert a string")
	    (fmtdyn:with my-fmtdyn
	       (loformat:insert
		  "Hello"
		  formatter/dynamic:th:format-alist))
	    (emt:assert
	       (equal
		  (buffer-string)
		  "Hello")))))
   
   (nil
      (with-temp-buffer
	 (let
	    ((my-fmtdyn (fmtdyn:create)))
	    (emt:doc "Situation: In an empty temp buffer, with a fmtdyn.")
	    (emt:doc "Operation: Insert a dynamic that is just a string")
	    (fmtdyn:with my-fmtdyn
	       (loformat:insert
		  `(dynamic "Hello" identity ())
		  formatter/dynamic:th:format-alist))

	    (emt:assert
	       (equal
		  (buffer-string)
		  "Hello")))))

   ;;A top-level with multiple interstices.
   (nil
      (with-temp-buffer
	 (let
	    ((my-fmtdyn (fmtdyn:create)))
	    (emt:doc "Situation: In an empty temp buffer, with a fmtdyn.")
	    (emt:doc "Operation: Insert a form with multiple dynamic
   objects / multiple interstices.")
	    (fmtdyn:with my-fmtdyn
	       (loformat:insert
		  `("He" (dynamic "llo" identity ()) ", "
		      (dynamic "World" identity ())
		      "!")
		  formatter/dynamic:th:format-alist))

	    (emt:assert
	       (equal
		  (buffer-string)
		  "Hello, World!")))))

   (nil
      (with-temp-buffer
	 (let
	    ((my-fmtdyn (fmtdyn:create)))
	    (emt:doc "Situation: In an empty temp buffer, with a fmtdyn.")
	    (emt:doc "Operation: Insert a form with multiple dynamic
      objects, not all at the top level of the tree")
	    (fmtdyn:with my-fmtdyn
	       (loformat:insert
		  `("He" ((dynamic "llo" identity ())) ", "
		      (((dynamic "World" identity ())))
		      "!")
		  formatter/dynamic:th:format-alist))

	    (emt:assert
	       (equal
		  (buffer-string)
		  "Hello, World!")))))

   (nil
      (with-temp-buffer
	 (let
	    ((my-fmtdyn (fmtdyn:create)))
	    (emt:doc "Situation: In an empty temp buffer, with a fmtdyn.")
	    (emt:doc "Operation: Insert a nested dynamic")
	    (fmtdyn:with my-fmtdyn
	       (loformat:insert
		  `("He" (dynamic "llo" identity ()) ", "
		      (dynamic 
			 (
			    (dynamic "W" identity ()) 
			    "or" 
			    (dynamic "ld" identity ())) 
			 identity ())
		      "!")
		  formatter/dynamic:th:format-alist))

	    (emt:assert
	       (equal
		  (buffer-string)
		  "Hello, World!")))))

   ;;Changing the content, then redisplaying it
   )


;;;_. Footers
;;;_ , Provides

(provide 'formatter/dynamic/tests)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + no-byte-compile: t
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; formatter/dynamic/tests.el ends here
