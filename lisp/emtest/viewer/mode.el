;;;_ emtest/viewer/mode.el --- Mode setup for emviewer

;;;_. Headers
;;;_ , License
;; Copyright (C) 2010  Tom Breton (Tehom)

;; Author: Tom Breton (Tehom) <tehom@panix.com>
;; Keywords: convenience,tools,maint

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

(require 'outline)
(require 'outline-magic nil t)

;;;_. Body
;;;_ , emtest/viewer/mode-map
(defconst emtest/viewer/mode-map 
   (let ((map (make-sparse-keymap)))
      (suppress-keymap map)
      (define-key map "a" 'show-all)
      (define-key map "b" 'outline-backward-same-level)
      (define-key map "c" 'hide-entry)
      (define-key map "d" 'hide-subtree)
      (define-key map "e" 'show-entry)
      (define-key map "f" 'outline-forward-same-level)
      (define-key map "h" 'hide-sublevels)
      (define-key map "i" 'show-children)
      (define-key map "k" 'show-branches)
      (define-key map "l" 'hide-leaves)
      (define-key map "n" 'outline-next-visible-heading)
      (define-key map "o" 'hide-other)
      (define-key map "p" 'outline-previous-visible-heading)
      (define-key map "q" 'bury-buffer)
      (define-key map "s" 'show-subtree)
      (define-key map "t" 'hide-body)
      (define-key map "u" 'outline-up-heading)

      (when (featurep 'outline-magic)
	 (define-key map "\t" 'outline-cycle))
      
      map)
   "Keymap for emtest/viewer/mode" )
;;;_ , Keymap for menu bar
;;;_ , emtest/viewer/mode-hook
(defvar emtest/viewer/mode-hook nil 
   "This hook is run when emtest/viewer/mode starts" )
;;;_ , emtest/viewer/mode
(defun emtest/viewer/mode ()
   "Mode for Emtest results.
The default keymap resembles that of outline mode, except it uses bare
keys and no prefix.
"
   (kill-all-local-variables)

   ;;Borrowed from outline mode to support its borrowed commands.
   (make-local-variable 'line-move-ignore-invisible)
   (setq line-move-ignore-invisible t)
   (add-to-invisibility-spec '(outline . t))
   (add-hook 'change-major-mode-hook 'show-all nil t)

   (setq major-mode 'emtest/viewer/mode)
   (setq mode-name "Emtest")
   (use-local-map emtest/viewer/mode-map)
   (put 'emtest/viewer/mode 'mode-class 'special)
   (run-mode-hooks emtest/viewer/mode-hook))



;;;_. Footers
;;;_ , Provides

(provide 'emtest/viewer/mode)

;;;_ * Local emacs vars.
;;;_  + Local variables:
;;;_  + mode: allout
;;;_  + End:

;;;_ , End
;;; emtest/viewer/mode.el ends here
