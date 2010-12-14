;;;_ utility/pathtree.el --- Pathtree library

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: lisp, internal

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

(eval-when-compile
   (require 'cl))
(require 'utility/pending)

;;;_. Body
;;;_ , Pathtree
;;;_  . Types
;;;_   , emtvp->id-element
;;$$FIXME These types should be gotten by TESTRAL from here, not vv.
;;Or both from a common source.  It is a presentation element anyways.
(deftype emtvp->id-element ()
   'emt:testral:id-element)
;;;_   , emtvp:node
(defstruct (emtvp:node
	      (:constructor emtvp:make-node)
	      (:conc-name emtvp:node->)
	      (:copier nil))
   "A node in a pathtree"
   (name ()      :type (or null emtvp->id-element))
   ;;$$REMOVE ME and remove from callers
   ;;Is this full path ever actually useful?
   ;;(path ()      :type (repeat emtvp->id-element))

   (parent () :type (or null emtvp:node))
   (children () 
      :type (repeat emtvp:node))
   (dirty-flags ()
      :type (repeat symbol))
   ;;$$REMOVE ME and remove from callers.
   ;;(data () :type t)

   )
;;;_   , emtvp
(defstruct (emtvp
	      (:constructor emtvp:make)
	      (:conc-name emtvp->)
	      (:copier nil))
   "A pathtree object"
   (root ()         :type emtvp:node)

   ;;*Callbacks*
   (node-dirtied   () 
      :type function
      :doc "Function to act on a node according to its dirty-flags
   field.

This function should not directly modify parent or children nodes,
other than by setting dirty flags in them and pushing them onto the
dirty list.")
   (make-node
      :type function
      :doc "Function to make a node.  It takes:

 * A node or nil
 * The data argument or nil

It returns a node of type which will be included in the pathtree.
That node must be compatible with the TYPE field here.  If the
data argument is nil, the node is to be a placeholder (or nil was
passed as data)

It is legal to alter old node and return it.  It is this
function's responsibility to set dirty flags appropriately in old
node." )

   ;;*Misc*
   (type 'emtvp:node
      :doc "The type of nodes.   Used in testing and testhelping.
Must be derived from `emtvp:node'.")
   (dirty () 
      :type (repeat emtvp:node)
      :doc "Dirty-list of nodes that want updating via NODE-DIRTIED"))



;;;_  . emtvp:add/replace-node
(defun  emtvp:add/replace-node (tree path arg)
   "Add a node to TREE at PATH.
TREE must be a `emtvp'.
PATH must be a list of `emtvp->id-element'.
ARG must be suitable as a second argument to tree field `make-node'."
   (check-type tree emtvp)
   (check-type path (repeat emtvp->id-element))
   (emtvp:add/replace-node-recurse 
      tree (emtvp->root tree) path arg))

;;;_  . emtvp:add/replace-node-recurse
(defun emtvp:add/replace-node-recurse (tree node path arg)
   "Add node ARG to the subtree NODE of TREE.
Create any ancestor nodes that don't already exist.

TREE must be a `emtvp'.
NODE must be a `emtvp:node' or descendant.
PATH must be a list of `emtvp->id-element'.
ARG must be suitable as a second argument to tree field `make-node'."

   (let*
      (
	 (name (car path))
	 (tail (cdr path))
	 (old-child
	    (find name
	       (emtvp:node->children node)
	       :key #'emtvp:node->name
	       :test #'equal)))

      (if
	 tail
	 (let
	    ((child
		(or 
		   old-child
		   (emtvp:add-child 
		      tree 
		      node 
		      name 
		      (funcall (emtvp->make-node tree) nil nil)))))
	    
	    ;;Recurse.  Keep looking.
	    (emtvp:add/replace-node-recurse 
	       tree child (cdr path) arg))
	 (progn
	    (when old-child
	       ;;Remove the old node.  
	       (callf2 remove old-child
		  (emtvp:node->children node))
	       ;;Could process the old node later, but YAGNI.  It is
	       ;;`node-dirtied' callback's responsibility to process
	       ;;the node's children.
	       '(progn
		   (push 'deleted
		      (emtvp:node->dirty-flags old-child))
		   (push old-child
		      (emtvp->dirty tree))))
	    (emtvp:add-child 
	       tree 
	       node 
	       name 
	       (funcall (emtvp->make-node tree) old-child arg))))))


;;;_  . emtvp:add-child
(defun emtvp:add-child (tree parent name new-child)
   "Add node NEW-CHILD at the end of PARENT's children"
   
   (setf
      (emtvp:node->name        new-child) name
      (emtvp:node->parent      new-child) parent
      (emtvp:node->dirty-flags new-child) '(new))

   ;;Don't set NEW-CHILD's children - the callback is allowed to set
   ;;them and expect them to be used.

   (callf append
      (emtvp:node->children parent)
      (list new-child))
   (push
      new-child
      (emtvp->dirty tree))
   new-child)

;;;_  . emtvp:remove-node-recurse
(defun emtvp:remove-node-recurse (path)
   ""
   ;;Punt for now.  Not needed until we're much further along.  Remove
   ;;it and set its `deleted' dirty flag.  It is `node-dirtied'
   ;;callback's responsibility to process the node's children.
   (let*
      ()
      
      ))

;;;_  . emtvp:make-pathtree
(defun emtvp:make-pathtree (node-dirtied make-node type &optional root-name)
   "Make an empty tree"
   (let
      ((root (funcall make-node nil nil)))
      (setf
	 (emtvp:node->name        root) (or root-name "")
	 (emtvp:node->parent      root) nil
	 (emtvp:node->dirty-flags root) '(new))
      (emtvp:make
	 :root         root
	 :node-dirtied node-dirtied
	 :make-node    make-node
	 :type         type)))

;;;_  . emtvp:freshen
(defun emtvp:freshen (tree)
   ""
   ;;This call empties the dirty list too.
   (pending:do-all
      (emtvp->dirty tree)
      #'(lambda (el tree)
	   "Call the cleaner callback.  No-op if there are no dirty-flags."
	   (if
	      (emtvp:node->dirty-flags el)
	      (funcall (emtvp->node-dirtied tree) el)
	      '()))
      (list tree)
      #'(lambda (unprocessed &rest args)
	   (format
	      "Couldn't process nodes %S"
	      (mapconcat
		 #'(lambda (x)
		      (emtvp:node->name x))
		 unprocessed
		 "\n")))
      t))


;;;_ , Utilities to help define "cleaning" callbacks
;;;_  . emtvp:util:match-as-car
(defun emtvp:util:match-as-car (x el)
   ""
   (and 
      (listp el)
      (eq (car el) x)))

;;;_  . emtvp:util:member-as-car
(defun emtvp:util:member-as-car (elt list)
   ""
   (member* elt list
      :test #'emtvp:util:match-as-car))
;;;_  . emtvp:util:handle-dirty
(defmacro emtvp:util:handle-dirty (obj form)
   "Evaluate form with:
 * DIRTY-FLAGS bound to OBJ's dirty flags
 * NEW-DIRTY-NODES bound, but don't play with it

And with the following functions defined:

 * UNDIRTY - remove flag to this node's dirty flags
 * UNDIRTY-CAR - remove governor from this node's dirty
   flags, where the flag is of the form (GOVERNOR args...)
 * NEW-DIRTY - add flag to OBJ's dirty flags
 * NEW-DIRTY-NODE - add flag to another object's dirty flags."
   (let
      ((objsym (make-symbol "objsym")))
      `(let* 
	  (  (,objsym ,obj)
	     (dirty-flags (emtvp:node->dirty-flags ,objsym))
	     (new-dirty-nodes '()))
	  (flet
	     (  (undirty (flag)
		   (setq dirty-flags
		      (delete* flag dirty-flags)))
		(undirty-car (flag)
		   (setq dirty-flags
		      (delete* 
			 flag
			 dirty-flags 
			 :test #'emtvp:util:match-as-car)))
		(new-dirty (flag)
		   (push flag dirty-flags))
		(new-dirty-node (flag node)
		   (push flag (emtvp:node->dirty-flags node))
		   (push node new-dirty-nodes)))
	 
	     ,form)
      
	  (setf 
	     (emtvp:node->dirty-flags ,objsym) dirty-flags)
      

	  ;;Return the nodes we newly know are dirty.  If dirty-flags is
	  ;;non-nil, that includes this node.
	  (if dirty-flags
	     (cons ,objsym new-dirty-nodes)
	     new-dirty-nodes))))



;;;_. Footers
;;;_ , Provides

(provide 'utility/pathtree)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; utility/pathtree.el ends here