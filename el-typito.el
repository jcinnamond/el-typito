(defface el-typito-pending-face
  '((t :foreground "grey"))
  "Face for characters still to be typed"
  :group :el-typito)

(defface el-typito-error-face
  '((t :background "red"))
  "Face for characters mistyped"
  :group :el-typito)

(defun el-typito-check-char ()
  (interactive)
  (delete-backward-char 1)
  (if (char-equal (car el-typito--thing-to-type) last-input-event)
      (progn
	(set-text-properties (point) (+ 1 (point)) nil)
	(forward-char)
	(setq el-typito--thing-to-type (cdr el-typito--thing-to-type))
	(if (el-typito--finished-p)
	    (el-typito--report-and-stop)))
    (progn
      (set-text-properties (point) (+ 1 (point)) '(font el-typito-error-face))
      (message "no bad")
      (setq el-typito--errors (+ 1 el-typito--errors)))))

(defun el-typito-start ()
  (interactive)
  (let ((original-content (buffer-substring-no-properties (point-min) (point-max)))
	(buffer (generate-new-buffer (generate-new-buffer-name "el-typito"))))
    (setq el-typito--thing-to-type (string-to-list original-content))
    (switch-to-buffer buffer)
    (insert original-content)
    (set-text-properties (point-min) (point-max) '(face el-typito-pending-face))
    (goto-char (point-min)))
  (setq el-typito--errors 0)
  (message "Type what you see")
  (add-hook 'post-self-insert-hook 'el-typito-check-char nil t))

(defun el-typito-stop ()
  (interactive)
  (remove-text-properties (point-min) (point-max) '(face el-typito-pending-face))
  (remove-hook 'post-self-insert-hook 'el-typito-check-char t))

(defun el-typito--report-and-stop ()
  (message (format "Hooray, all done with %d errors" el-typito--errors))
  (el-typito-stop))

(defun el-typito--finished-p ()
  (null el-typito--thing-to-type))
