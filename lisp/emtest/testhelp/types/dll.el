;;;_ emtest/testhelp/types/dll.el --- Deftypes for elib's dll

;;;_. Headers
;;;_ , License
;; Copyright (C) 2009  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@localhost.localdomain>
;; Keywords: lisp, maint, oop

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

;; This is no longer in use.


;;;_ , Requires


;;;_. Body

;;;_ , dll-repeat
(deftype dll-repeat (type) 
   `(satisfies 
       (lambda (obj)
	  (dll-repeat-f obj ',type))))

(defun dll-repeat-f (obj type)
   ""
   (and
      (dll-p obj)
      (catch
	 'dll-repeat:not-type
	 (progn
	    (dll-map
	       (lambda (item)
		  (unless
		     (typep item type)
		     (throw 'dll-repeat:not-type nil)))
	       obj)
	    t))))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/testhelp/types/dll)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/testhelp/types/dll.el ends here
