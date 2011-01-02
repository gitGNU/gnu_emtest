;;;_ emtest/support/persist.el --- Persistence for testing

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: lisp,maint,internal,data

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

;; Redesigned persistence for Emtest


;;;_ , Requires

(require 'tinydb/persist)

;;;_. Body
;;;_ , Types
;;;_  . emdb:record
(defstruct (emdb:record
	      (:type list)
	      (:copier nil)
	      (:constructor emdb:make-record)
	      (:conc-name emdb:record->))
   "A record in the database"
   key ;;First so that we can use assoc
   use-category
   timestamp
   value)

;;;_  . use-category type
(deftype emdb:use-category () 
   '(member correct-answer correct-type wrong-answer nil))
;;;_  . Error type emdb:error
;;;_  . Error type emdb:error
(put 'emdb:error 'error-conditions
   '(error emdb:error))
(put 'emdb:error 'error-message
   "Database error: Key %s not found in backend %s")

;;;_ , Accessing items

;;;_  . emdb:get-value
(defun emdb:get-value (backend id &optional category)
   ""
   
   (let*
      ((all
	  (emdb:tinydb:get-all backend))
	 (cell
	    (assoc id all)))
      (if cell
	 (emdb:record->value cell)
	 (signal
	    'emdb:error
	    (list id backend)))))


;;;_  . emdb:set-value
(defun emdb:set-value (backend id value &optional dummy-category)
   ""
  
   (let*
      ((all
	  (remove*
	     id
	     (emdb:tinydb:get-all backend)
	     :key #'emdb:record->key)))
      (push
	 (emdb:make-record
	    :key          id
	    :use-category 'correct-answer
	    :timestamp    (current-time)
	    :value        value)
	 all)
      (emdb:tinydb:set-all backend all)))


;;;_ , The database itself
;;;_  . emdb:tinydb:get-all
(defun emdb:tinydb:get-all (backend)
   "Return the database object as a whole"
   (let
      ((filename
	  (second backend)))
      (tinydb-get-obj (tinydb:filename->tinydb filename))))

;;;_  . emdb:tinydb:set-all
(defun emdb:tinydb:set-all (backend value)
   "Set the database object as a whole"
   (let
      ((filename
	  (second backend)))
      (tinydb-set-obj (tinydb:filename->tinydb filename) value)))


;;;_. Footers
;;;_ , Provides

(provide 'emtest/support/persist)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/support/persist.el ends here
