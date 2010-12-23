;;;_ emtest/viewer/testral/not-in-db.el --- TESTRAL formatter for not-in-db

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: lisp,maint,internal

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

(require 'emtest/viewer/emformat)


;;;_. Body
;;;_ , emtvf:TESTRAL-gov:not-in-db
;;;###autoload
(defun emtvf:TESTRAL-gov:not-in-db (value id backend)
   "Formatter for TESTRAL note governed by `not-in-db'"
   (emtvf:outline-item-2
      "ID not in database "
      `(
	  ,(emtvf:headline 
	      (+ 2 depth)
	      nil
	      (list
		 "Value "
		 (emtvf:button "[Accept]"
		    `(lambda ()
			(interactive)
			(emdb:set-value
			   ',backend
			   ',id
			   ',value
			   'correct-answer))
		    '(help-echo "Accept this value"))))
	  ,(if
	      (stringp value)
	      ;;Indent it so it can't affect outline
	      ;;structure. 
	      `(indent 4 ,value)
	      `(object ,value nil)))
      (1+ depth)
      'emtvf:face:ungraded))
;;;_. Footers
;;;_ , Register it
;;;###autoload (emtvf:TESTRAL:add-gov
;;;###autoload    'not-in-db 
;;;###autoload    #'emtvf:TESTRAL-gov:not-in-db)


;;;_ , Provides

(provide 'emtest/viewer/testral/not-in-db)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/viewer/testral/not-in-db.el ends here
