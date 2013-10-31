;;; virtual-desktops.el --- allows you to save/restore a frame configuration:
;;  windows and buffers.
;;
;; Filename: virtual-desktops.el
;; Description: allows you to save/retore a frame configuration: windows and buffers.
;; Author: Cédric Chépied <cedric.chepied@gmail.com>
;; Maintainer: Cédric Chépied
;; Copyright (C) 2012, Cédric Chépied
;; Last updated: Wed Jul  4 17:47:07 UTC
;;     By Cédric Chépied
;;     Update 1
;; Keywords: virtual, desktop
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;allows you to save/retore a frame configuration: windows and buffers.
;;
;;
;; Keys and interactive functions:
;; virtual-desktops-add:             save current configuration in a new virtual
;;                                   desktop and select it (C-c C-d a). Use
;;                                   prefix argument to create several desktops.
;; virtual-desktops-delete:          delete current desktop and select the nil
;;                                   desktop (C-c C-d d)
;; virtual-desktops-delete-specific: delete a specific desktop and select the
;;                                   nil desktop if you choose current
;;                                   desktop (C-c C-d D)
;; virtual-desktops-goto:            restore a specific desktop (C-c C-d g)
;; virtual-desktops-next:            go to next desktop (C->)
;; virtual-desktops-previous:        go to previous desktop (C-<)
;; virtual-desktops-list:            list all desktops (C-c C-d l)
;; virtual-desktops-update:          save current configuration in current
;;                                   desktop
;;
;;
;; Variables:
;; virtual-desktops-auto-update: if non nil, current desktop will be updated
;; before execution of virtual-desktops-next, virtual-desktops-prev and
;; virtual-desktops-goto
;;
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;; Copyright Cédric Chépied 2012
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;
;;
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; TODO
;;
;; list buffer must be interactive
;; make current desktop frame specific
;;
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Code:

(provide 'virtual-desktops)

;;constants
(defconst virtual-desktops-list-buffer-name "##virtual-desktops##")

;;global variables
(defvar virtual-desktops-list (list nil))
(defvar virtual-desktops-current 0)
(defvar virtual-desktops-mode-line-string nil)

;;group
(defgroup virtual-desktop nil "Customization of virtual-desktop variables."
  :tag "virtual-desktop"
  :group 'emacs)


;;customizable variables
(defcustom virtual-desktops-auto-update "desktop auto update" "If non nil, current desktop will be updated when calling any virtual-desktops function."
  :type 'boolean
  :group 'virtual-desktop)


;; Custom Minor Mode
(define-minor-mode virtual-desktops-mode
  "Enable desktops creation which save or restore windows and buffers of the frame."
  ;; The initial value - Set to 1 to enable by default
  nil
  ;; The indicator for the mode line.
  ""
  ;; The minor mode keymap
  `(
    (,(kbd "C->") . virtual-desktops-next)
    (,(kbd "C-<") . virtual-desktops-prev)
	(,(kbd "C-c C-d a") . virtual-desktops-add)
  	(,(kbd "C-c C-d d") . virtual-desktops-del)
  	(,(kbd "C-c C-d D") . virtual-desktops-del-specific)
  	(,(kbd "C-c C-d g") . virtual-desktops-goto)
  	(,(kbd "C-c C-d l") . virtual-desktops-list)
   )
   ;; Make mode global rather than buffer local
   :global 1

   ;;initialize variables
   (progn
	 (setq virtual-desktops-list (list nil))
	 (setq virtual-desktops-current 0)
	 (if virtual-desktops-mode
		 (setq virtual-desktops-mode-line-string " (D nil) ")
	     (setq virtual-desktops-mode-line-string ""))
	 (or global-mode-string
		 (setq global-mode-string '("")))
	 (or (memq 'virtual-desktops-mode-line-string global-mode-string)
		 (setq global-mode-string
			   (append global-mode-string '(virtual-desktops-mode-line-string)))))
)


(defun virtual-desktops-restore (number)
  (let ((desktop (nth number virtual-desktops-list)))
	(when desktop
	  (set-window-configuration desktop))))

(defun virtual-desktops-create-desktop ()
  (current-window-configuration))

;;delete a desktop if it is not the nil desktop
(defun virtual-desktops-delete (number)
  (if (and (< number (safe-length virtual-desktops-list))
		   (> number 0))
	  (setq virtual-desktops-list (delq (nth number virtual-desktops-list) virtual-desktops-list))
	  (message (concat "Cant delete this desktop :" (number-to-string number))))
)


(defun virtual-desktops-update-mode-line ()
  (if (= virtual-desktops-current 0)
	  (setq virtual-desktops-mode-line-string " (D nil) ")
	  (setq virtual-desktops-mode-line-string (concat " (D " (number-to-string virtual-desktops-current) ") ")))
  (force-mode-line-update)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;								Interactive functions									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun virtual-desktops-add (nb-desktops)
  (interactive "P")
  (if virtual-desktops-mode
	  (progn (setq virtual-desktops-list (append virtual-desktops-list (list (virtual-desktops-create-desktop))))
			 (setq virtual-desktops-current (1- (safe-length virtual-desktops-list)))
			 (virtual-desktops-update-mode-line)
             (when (and (integerp nb-desktops)
                        (> nb-desktops 1))
               (virtual-desktops-add (1- nb-desktops))))
	  (message "virtual-desktops-mode must be enabled"))
)


(defun virtual-desktops-update ()
  (interactive)
  (if virtual-desktops-mode
	  (progn (if (not (= virtual-desktops-current 0))
				 (let (desktop)
				   (setq desktop (virtual-desktops-create-desktop))
				   (setcar (nthcdr virtual-desktops-current virtual-desktops-list) desktop))))
  	  (message "virtual-desktops-mode must be enabled"))
)

(defun virtual-desktops-del ()
  (interactive)
    (if virtual-desktops-mode
		(progn (virtual-desktops-delete virtual-desktops-current)
			   (setq virtual-desktops-current 0)
			   (virtual-desktops-update-mode-line))
	    (message "virtual-desktops-mode must be enabled"))
)

(defun virtual-desktops-del-specific ()
  (interactive)
  (if virtual-desktops-mode
	  (progn (let (desktop)
			   (setq desktop (read-from-minibuffer "desktop to delete? "))
			   (virtual-desktops-delete (string-to-number desktop))
			   (if (= virtual-desktops-current (string-to-number desktop))
				   (setq virtual-desktops-current 0)))
			 (virtual-desktops-update-mode-line))
	  (message "virtual-desktops-mode must be enabled"))
)

(defun virtual-desktops-next ()
  (interactive)
  (if virtual-desktops-mode
	  (if (not (active-minibuffer-window))
		  (progn (if (not (equal nil virtual-desktops-auto-update))
					 (virtual-desktops-update))
				 (setq virtual-desktops-current (1+ virtual-desktops-current))
				 (if (>= virtual-desktops-current (safe-length virtual-desktops-list))
					 (setq virtual-desktops-current 0))
				 (virtual-desktops-restore virtual-desktops-current)
				 (virtual-desktops-update-mode-line))
		  (message "pb minibuffer"))
	  (message "virtual-desktops-mode must be enabled"))
)

(defun virtual-desktops-prev ()
  (interactive)
  (if virtual-desktops-mode
	  (if (not (active-minibuffer-window))
		  (progn (if (not (equal nil virtual-desktops-auto-update))
					 (virtual-desktops-update))
				 (setq virtual-desktops-current (1- virtual-desktops-current))
				 (if (< virtual-desktops-current 0)
					 (setq virtual-desktops-current (1- (safe-length virtual-desktops-list))))
				 (virtual-desktops-restore virtual-desktops-current)
				 (virtual-desktops-update-mode-line))
		  (message "pb minibuffer"))
	  (message "virtual-desktops-mode must be enabled"))
)

(defun virtual-desktops-goto ()
  (interactive)
  (if virtual-desktops-mode
	  (if (not (active-minibuffer-window))
		  (progn (if (not (equal nil virtual-desktops-auto-update))
					 (virtual-desktops-update))
				 (let (desktop number)
				   (setq desktop (read-from-minibuffer "desktop to display? "))
				   (if (equal "nil" desktop)
					   (setq number 0)
					   (setq number (string-to-number desktop)))
				   (setq virtual-desktops-current number))
				 (virtual-desktops-restore virtual-desktops-current)
				 (virtual-desktops-update-mode-line)))
	  (message "virtual-desktops-mode must be enabled"))
)

(defun virtual-desktops-list ()
  (interactive)
  (if virtual-desktops-mode
	  (progn (let (buffer i)
			   ;;killing buffer if it exists
			   (if (not (equal nil (get-buffer virtual-desktops-list-buffer-name)))
				   (kill-buffer virtual-desktops-list-buffer-name))

			   ;;creating buffer
			   (setq buffer (get-buffer-create virtual-desktops-list-buffer-name))
			   (switch-to-buffer buffer)

			   ;;insert desktop list
			   (insert "This is desktop list\nYou can set point on the desired one and press RET to switch to this desktop\n\n")
			   (setq i 0)
			   (while (< i (safe-length virtual-desktops-list))
				 (insert (propertize (number-to-string i) 'font-lock-face '(:foreground "red")))
				 (insert "\t")
				 (let (window window-list)
				   (setq window-list (nth i virtual-desktops-list))
				   (if (equal window-list nil)
					   (insert "nil")
					 (dolist (window window-list)
					   (insert "<")
					   (if (equal nil (buffer-name (virtual-desktops-get-window-buffer window)))
						   (insert "Deleted buffer")
						 (insert (buffer-name (virtual-desktops-get-window-buffer window))))
					   (insert "> "))))
				 (insert "\n\n")
				 (setq i (1+ i)))

			   ;;setting buffer read only
			   (read-only-mode)))
			 (message "virtual-desktops-mode must be enabled"))
)

;;virtual-desktops.el ends here
