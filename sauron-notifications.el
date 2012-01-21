;;; sauron-notications.el --- a notifications tracking module, part of sauron
;;
;; Copyright (C) 2012 Dirk-Jan C. Binnema

;; This file is not part of GNU Emacs.
;;
;; Sauron is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Sauron is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;  For documentation, please see:
;;  https://github.com/djcb/sauron/blob/master/README.org

;;; Code:
(require 'notifications nil 'noerror)
(eval-when-compile (require 'cl))

;; this tracks the D-Bus notifications module that ships with Emacs 24

(defun sauron-notications-start ()
  "Start tracking notifications."
  (if (not (fboundp 'notifications-notify))
    (message "sauron-notifications not available")
    (progn
      ;; activate the advice
      (ad-enable-advice 'notifications-notify 'after 'sr-notifications-hook)
      (ad-activate 'notifications-notify))))

(defun sauron-notications-stop ()
  "Stop tracking notifications."
  (when (boundp 'notifications-notify)
    (progn
      ;; activate the advice
      (ad-disable-advice 'notifications-notify 'after 'sr-notifications-hook)
      (ad-deactivate 'notifications-notify))))

(defadvice notifications-notify
  (after sr-notifications-hook (&rest params) disable)
  "\"Hook\" `sauron-add-event' to `notifications-notify'"
  (let ((title (plist-get params :title))
        (body (plist-get params :body))
        (prio
	  (case (plist-get params :urgency)
	    (low 3)
	    (normal 4)
	    (critical 5)
	    (otherwise 2))))
    (sauron-add-event
      'notify
      prio
      (concat title
	(if (and title body) " - ") body))))

(provide 'sauron-notications)
