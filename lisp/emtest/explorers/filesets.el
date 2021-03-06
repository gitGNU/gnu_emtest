;;;_ emtest/explorers/filesets.el --- Launch tests via fileset

;;;_. Headers
;;;_ , License
;; Copyright (C) 2011  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: maint,convenience,lisp

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

(require 'emtest/types/testral-types)
(require 'emtest/types/run-types)
(require 'emtest/main/find-tests)
(require 'fileset-whole)

;;;_. Body

;;;_ , Launchers 
;;;_  . emt:xp:fileset-launch
(defun emt:xp:fileset-launch (fileset-name rerun)
   "Launch the tests defined in FILESET."
   
   (emt:lch:run
      `(fileset ,fileset-name)
      (emt:lch:get-prop-list rerun)
      (list (concat "fileset " fileset-name))))

;;;_  . emtest:fileset
;;;###autoload
(defun emtest:fileset (fileset-name)
   "Launch the tests defined in FILESET.
If prefix arg is given, prompt for fileset name in any case."
   (interactive
      (list
	 (fileset-whole-read-fileset current-prefix-arg)))
   (emt:xp:fileset-launch fileset-name t))


;;;_  . emtest:fileset-all
;;;###autoload
(defun emtest:fileset-all (fileset-name)
   "Launch the tests defined in FILESET.
If prefix arg is given, prompt for fileset name in any case."
   (interactive
      (list
	 (fileset-whole-read-fileset current-prefix-arg)))
      (emt:xp:fileset-launch fileset-name nil))

;;;_ , Explorer emt:xp:fileset
;;;###autoload
(defun emt:xp:fileset (test-id props path report-f)
   "Run the tests defined in fileset."
   (if (cdr test-id)
      (let*
	 (
	    (fileset-name (second test-id))
	    (fileset
	       (filesets-get-fileset-from-name fileset-name))
	    (test-files
	       (filesets-get-filelist fileset nil nil))
	    (test-files
	       ;;Remove those that aren't elisp source
	       (remove-if-not
		  #'(lambda (filename)
		       (string-match emacs-lisp-file-regexp filename))
		  test-files))
	    (dummy
	       (dolist (filename test-files)
		  (when (not (assoc filename load-history))
		     (load filename t nil t))))

	    (suite-list
	       (let* 
		  ((suite-syms))
		  (do-symbols (sym)
		     (let*
			((props (get sym 'emt:properties))
			   (load-file-name (second (assoc 'load-file-name props))))
			(when
			   (and load-file-name
			      (member load-file-name test-files))
	       
			   ;;Collect that suite by symbol
			   (push sym suite-syms))))
		  suite-syms))
	 
	    ;;$$ENCAP ME Scheduling a list of suite-syms.
	    (list-to-run
	       (mapcar
		  #'(lambda (suite-sym)
		       (emt:run:make-explorable
			  :how-to-run
			  (emt:run:->how `(suite ,suite-sym))
			  :prestn-path 
			  (append 
			     path
			     (list (symbol-name suite-sym)))
			  ;;For now, libraries have no
			  ;;properties. 
			  :properties ()
			  :aliases ()))
		  suite-list)))

	 (funcall report-f 
	    (emt:testral:make-suite
	       :contents
	       (emt:testral:make-runform-list
		  :els list-to-run)
	       ;;Punt - only if it crapped out right here.
	       :grade '())
	    list-to-run))

      ;; Tell about filesets that we know about.
      (funcall report-f
	 (emt:testral:make-suite
	    :contents 
	    (emt:testral:make-runform-list
	       :els
	       (mapcar 
		  #'(lambda (x)
		       (let
			  ((name (first x)))
		       (emt:run:make-explorable
			  :how-to-run  
			  (emt:run:->how (list 'fileset name))
			  :prestn-path
			  (list 'fileset name))))
		  filesets-data))
	    :grade nil)
	 '())))


;;;_ , Register
;;;###autoload (eval-after-load 'emtest/main/all-explorers
;;;###autoload '(emt:exps:add 'fileset #'emt:xp:fileset
;;;###autoload "Fileset" t))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/explorers/filesets)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/explorers/filesets.el ends here
