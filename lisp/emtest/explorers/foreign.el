;;;_ emtest/explorers/foreign.el --- Explorer that serves test-frameworks on other programs

;;;_. Headers
;;;_ , License
;; Copyright (C) 2012  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: tools

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

(require 'tq)
(require 'emtest/types/testral-types)


;;;_. Body
;;;_ , Customizations

(defcustom emt:xp:foreign:launchables
   '()
   
   "List of executables suitable for this and config data for them."
   :type 
   '(repeat
       (list
	  (string
	     :value "Unnamed"
	     :tag "name"
	     :help-echo "Your nickname for this entry")
	  ;; And its arguments.
	  (cons
	     (file
		:value ""
		:tag "executable"
		:help-echo "The executable's filename")
	     (repeat
		(string  
		   :value ""
		   :tag "arg"
		   :help-echo "An argument when invoking the executable")))
	  (string
	     :value "EndOfAnswer"
	     :tag "terminating regex"
	     :help-echo "Regular expression indicating the end of an answer string")
	  (boolean
	     :value t
	     :tag "Use shell"
	     :help-echo "Whether to go thru shell when launching the executable")
	  (file    
	     :value ""
	     :tag "database-file"
	     :help-echo "Optional: database file for persistent test data.  Need not already exist.")
	  ;; Should be properties for it.
	  (boolean 
	     :value nil
	     :tag "Run all immediately"
	     :help-echo "Whether to immediately run all tests")
	  (integer
	     :value 120
	     :tag "Timeout"
	     :help-echo "How many seconds the last test to shut down the executable")))
   
   :group 'emtest)


;;;_ , Alist of foreign testers currently running
(defvar emt:xp:foreign:current-testers
   '()
   ;; For now, timer is not used.
   "Alist of current foreign processes.  

Each element is of the form \(name tq timer launchable\)" )

;;;_ , emt:xp:foreign:make-tq
;; Could share this with expect.el
(defun emt:xp:foreign:make-tq (exec+args shell proc-base-name)
   ""
   (let* 
      ((proc 
	  (apply 
	     (if shell
		#'start-process-shell-command
		#'start-process)
	     proc-base-name nil exec+args)))
      (unless
	 ;;0 status means a live process
	 (equal
	    (process-exit-status proc)
	    0)
	 (error
	    "No live process"))
      (tq-create proc)))
;;;_ , emt:xp:foreign:launchable->tq
(defun emt:xp:foreign:launchable->tq (launchable)
   "Make a transaction queue appropriate to LAUNCHABLE"
   
   (emt:xp:foreign:make-tq (second launchable) (fourth launchable) "foreign"))

;;;_ , emt:xp:foreign:revive-tester
(defun emt:xp:foreign:revive-tester (tester)
   "Make sure the tq of TESTER is alive.

TESTER should be an element of emt:xp:foreign:current-testers."
   
   (destructuring-bind (name tq timer launchable) tester
      (unless
	 (buffer-live-p (tq-buffer tq))
	 ;; Cancel any timer that was running wrt it.  (Even though we
	 ;; don't make timers yet).
	 (when (timerp timer) (cancel-timer timer))
	 (setf (second tester) 
	    (emt:xp:foreign:launchable->tq launchable)))))

;;;_ , emt:xp:foreign:get-tester

(defun emt:xp:foreign:get-tester (name)
   "Get the tester for name.

NAME should be the nickname of some launchable"
   
   (let*
      (
	 (launchable
	    (assoc name emt:xp:foreign:launchables))
	 (tester (assoc name emt:xp:foreign:current-testers)))
      (if tester
	 (emt:xp:foreign:revive-tester tester)
	 ;; If it doesn't exist, make it.
	 (progn
	    (setq tester 
	       (list 
		  name
		  (emt:xp:foreign:launchable->tq launchable)
		  ;; No timer yet
		  nil
		  launchable))
	    (push tester emt:xp:foreign:current-testers)))
      tester))

;;;_ , Related to stopping it a certain time after last Q.

;; time = number of seconds, just like repeat.  

;;(run-at-time time repeat function &rest args)
;;(cancel-timer timer)
;;(tq-close queue)

;; Timer should just check tq every so often, and check that it got
;; some answer in the meantime.
;;;_ , Utility

;;;_ , Text to Csexp
;;;_  . emt:xp:foreign:read-buffer-csexp-loop
(defun emt:xp:foreign:read-buffer-csexp-loop ()
   ""
   
   (let
      ((rv-csexp (list)))
      ;; We come directly here when we see the end of a list.
      (catch 'emt:xp:foreign:csexp-EOL
	 (while (not (eobp))
	    ;; We come directly here, skipping push, when we read a
	    ;; non-object.
	    (catch 'emt:xp:foreign:csexp-NOTHING
	       (push (emt:xp:foreign:read-buffer-csexp-single) rv-csexp))))
      (nreverse rv-csexp)))

;;;_  . emt:xp:foreign:read-buffer-csexp-single
(defun emt:xp:foreign:read-buffer-csexp-single ()
   ""
   
   (if
      (looking-at "[0-9]*:")
      (let*
	 (  (start (match-beginning 0))
	    (end (match-end 0))
	    ;; First we read how many chars to read - careful not
	    ;; to include ":"
	    (digit-str (buffer-substring start (1- end)))
	    (num-chars (read digit-str))
	    (end-of-read  (+ end num-chars))
	    ;; Then we read the string itself
	    (str (buffer-substring end end-of-read)))
	 (goto-char end-of-read)
	 str)
	 
      (case (prog1
	       (char-after)
	       ;; Don't move past end of buffer, in case we're reading
	       ;; the last char in the buffer.
	       (unless (eobp) (forward-char)))
	 
	 (?\( 
	    (emt:xp:foreign:read-buffer-csexp-loop))
	 (?\)
	    (throw 'emt:xp:foreign:csexp-EOL nil))
	 ;; Read nothing for whitespace etc.
	 (t (throw 'emt:xp:foreign:csexp-NOTHING nil)))))
;;;_  . emt:xp:foreign:read-buffer-csexp
(defun emt:xp:foreign:read-buffer-csexp (text)
   ""

   (with-temp-buffer
      (insert text)
      (goto-char 1)
      (catch 'emt:xp:foreign:csexp-EOL
	 (catch 'emt:xp:foreign:csexp-NOTHING
	    (emt:xp:foreign:read-buffer-csexp-single)))))
;;;_ , Csexp to text
;;;_ , Stringtree to obj
;;;_  . emt:xp:foreign:ctor-alist

(defvar emt:xp:foreign:ctor-alist 
   '(
       (list    list t)
       (integer read t)
       (grade   intern) ;; Not sure we'll need this.
       (symbol  intern)
       ;; (prestn-path)

       (suite      emt:testral:make-suite        nil)
       (note       emt:testral:make-note         nil)
       (runforms   emt:testral:make-runform-list nil)
       (notes      emt:testral:make-note-list    nil)
       (report     emt:testral:make-report       nil)
       (explorable emtt:make-explorable          nil)
       
)
   
   "Alist of ctors of foreign-able types from stringtrees, for incoming objects.

Each entry is of the form \(SYMBOL CTOR POSITIONAL?\).

If POSITIONAL? is nil, each argument is expected to be of the form \(KEY
VALUE\).  Before CTOR is called, VALUE is recursively parsed and key
is interned, prepended with \":\".

If POSITIONAL? is t, each argument is simply recursively parsed first." )

;;;_  . emt:xp:foreign:stringtree->object

(defun emt:xp:foreign:stringtree->object (stringtree)
   "Given a stringtree, construct a corresponding object"

   (typecase stringtree
      (string stringtree)
      (cons
	 (when (car stringtree)
	    (let*
	       (
		  (sym (intern (car stringtree)))
		  (cell (assq sym emt:xp:foreign:ctor-alist)))
	       (when cell
		  (destructuring-bind
		     (functor func positionalp) cell
		     (if positionalp
			;; Positionally
			(apply func
			   (mapcar 
			      #'emt:xp:foreign:stringtree->object
			      (cdr stringtree)))
			;;By key - basically imitates structure
			;;construction.
			(apply func
			   (apply #'append
			      (mapcar 
				 #'(lambda (x)
				      (destructuring-bind
					 (key value) x
					 (list 
					    ;; Key had better be a string
					    (intern (concat ":" key)) 
					    (emt:xp:foreign:stringtree->object
					       value))))
				 (cdr stringtree))))))))))))

;;;_ , Obj to stringtree
;;;_  . emt:xp:foreign:stringtreer-alist 
(defvar emt:xp:foreign:stringtreer-alist 
   '(
       (listp    "list"    t identity)
       (integerp "integer" t emt:xp:foreign:singleval-stringtreer)
       (symbolp  "symbol"  t emt:xp:foreign:singleval-stringtreer)
       ;; We don't treat grade etc as a case, it's treated as symbol
       
       (emt:testral:suite-p        "suite"    struct emt:testral:suite)
       (emt:testral:note-p         "note"     struct emt:testral:note)
       (emt:testral:runform-list-p "runforms" struct emt:testral:runform-list)
       (emt:testral:note-list-p    "notes"    struct emt:testral:note-list)
       (emt:testral:report-p       "report"     struct emt:testral:report)
       (emtt:explorable-p          "explorable" struct emtt:explorable)
       
       )
   "Alist of the stringtree-ers of foreign-able types, for outgoing objects.

Each entry is of one of the forms
 * \(PREDICATE NAME t POSITIONAL-STRINGTREER\).
 * \(PREDICATE NAME nil KEYWISE-STRINGTREER\).
 * \(PREDICATE NAME struct STRUCT-SYMBOL\).

Positional-Stringtreer is expected to return a list of positional
arguments.  

Keywise-Stringtreer should return a list where each element of
the list is in the form \(KEY VALUE\), and KEY is the symbol of a
slot (without ':', which will be added in reading)."
   )
;;;_  . emt:xp:foreign:singleval-stringtreer
(defun emt:xp:foreign:singleval-stringtreer (x)
   ""
   (list
      (prin1-to-string x)))

;;;_  . emt:xp:foreign:struct-stringtreer
(defun emt:xp:foreign:struct-stringtreer (struct-sym x)
   ""
   (let
      ((slots 
	  (get struct-sym 'cl-struct-slots))
	 (i 0))

      (delq nil
	 (mapcar
	    #'(lambda (slot-form)
		 (let
		    ((key (car slot-form))
		       (value (aref x i)))
		    (incf i)
		    (unless
		       (eq key 'cl-tag-slot)
		       (list 
			  (symbol-name key)
			  (emt:xp:foreign:object->stringtree value)))))
	    slots))))
;;;_  . emt:xp:foreign:keyvalue-stringtreer
(defun emt:xp:foreign:keyvalue-stringtreer (x)
   ""
   
   (destructuring-bind
      (sym value) x
      (list 
	 ;; Sym had better be a symbol
	 (symbol-name sym)
	 (emt:xp:foreign:object->stringtree
	    value))))
;;;_  . emt:xp:foreign:object->stringtree

(defun emt:xp:foreign:object->stringtree (object)
   "Return a stringtree corresponding to OBJECT"

   (if
      (stringp object)
      object
      (let* 
	 ((occurence
	     (find object emt:xp:foreign:stringtreer-alist
		:test 
		#'(lambda (ob form)
		     (funcall (car form) ob)))))
	 (when occurence
	    (destructuring-bind
	       (predicate name positional stringtreer) occurence
	       (cons
		  name
		  (case positional
		     ((t) 
			(mapcar 
			   #'emt:xp:foreign:object->stringtree
			   (funcall stringtreer object)))
		     ((nil) 
			(mapcar 
			   #'emt:xp:foreign:keyvalue-stringtreer
			   (funcall stringtreer object)))
		     (struct
			(emt:xp:foreign:struct-stringtreer
			   stringtreer object))
		     (t '()))))))))

;;;_ , Text to/from TESTRAL
;;;_ , emt:xp:foreign:encode-TESTRAL
(defun emt:xp:foreign:encode-TESTRAL (raw-question)
   ""
   ;; Punt for now
   "()")
;;;_ , emt:xp:foreign:decode-to-TESTRAL
(defun emt:xp:foreign:decode-to-TESTRAL (text)
   "Convert answer to csexp and thence to object."

   (let*
      ((stringtree (emt:xp:foreign:read-buffer-csexp text))
	 (object
	    (emt:xp:foreign:stringtree->object stringtree)))))

;;;_ , The explorer proper
;;;_  . emt:xp:foreign:report-results
(defun emt:xp:foreign:report-results (passed-object answer)
   "Report the results when we get an answer"
   
   (destructuring-bind
      (report-f tester) passed-object
      (funcall report-f
	 (let
	    ((object (emt:xp:foreign:decode-to-TESTRAL answer)))
	    ;; $$RETHINK This seems to be the expected return, but
	    ;; maybe it should be emt:testral:report?  But report-f
	    ;; expects a suite.
	    (if
	       (emt:testral:suite-p object)
	       object
	       (emt:testral:make-suite
		  ;; Add a note about getting the wrong object.
		  :contents '()
		  :grade 'blowout)))
	 ;; Could schedule any tests a suite returns.
	 '())))

;;;_  . emt:xp:foreign
;;;###autoload
(defun emt:xp:foreign (test-id props-unused path report-f)
   ""
   (if (cdr test-id)
      (let* 
	 (
	    (launchable-name (second test-id))
	    (raw-question (third test-id))
	    (tester (emt:xp:foreign:get-tester launchable-name))
	    (tq (second tester))
	    (terminating-regex (third tester)))
	 
	 (tq-enqueue tq 
	    (emt:xp:foreign:encode-TESTRAL raw-question)
	    terminating-regex
	    (list report-f tester)
	    #'emt:xp:foreign:report-results t))
      

      ;; List foreigns that we could run, from customization list.
      (funcall report-f
	 (emt:testral:make-suite
	    :contents 
	    (emt:testral:make-runform-list
	       :els
	       (mapcar 
		  #'(lambda (x)
		       (let
			  ((name (first x)))
			  (emtt:make-explorable
			     :how-to-run  
			     (list 'foreign name)
			     :prestn-path
			     (list 'foreign name))))
		  emt:xp:foreign:launchables))
	    :grade nil)
	 '())))

;;;_ , Register it

;;;_ , Insinuate
;;;###autoload (eval-after-load 'emtest/main/all-explorers
;;;###autoload  '(emt:exps:add 'foreign #'emt:xp:foreign
;;;###autoload  "Testers in other executables" t))

;;;_. Footers
;;;_ , Provides

(provide 'emtest/explorers/foreign)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/explorers/foreign.el ends here
