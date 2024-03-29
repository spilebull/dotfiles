;;; editorconfig-core-handle.el --- Handle Class for EditorConfig File

;; Copyright (C) 2011-2015 EditorConfig Team

;; Author: EditorConfig Team <editorconfig@googlegroups.com>
;; Version: 0.7.0
;; URL: https://github.com/editorconfig/editorconfig-emacs#readme

;; See
;; https://github.com/editorconfig/editorconfig-emacs/graphs/contributors
;; or the CONTRIBUTORS file for the list of contributors.

;; This file is part of EditorConfig Emacs Plugin.

;; EditorConfig Emacs Plugin is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.

;; EditorConfig Emacs Plugin is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
;; Public License for more details.

;; You should have received a copy of the GNU General Public License along with
;; EditorConfig Emacs Plugin. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Handle class for EditorConfig config file. This library is used internally
;; from editorconfig-core.el .

;;; Code:

(require 'editorconfig-fnmatch)

;; For cl-defstruct
(require 'cl-lib)

(defvar editorconfig-core-handle--cache-hash
  (make-hash-table :test 'equal)
  "Hash of EditorConfig filename and its `editorconfig-core-handle' instance.")

(cl-defstruct editorconfig-core-handle
  (top-prop nil)
  (prop nil)
  (mtime nil)
  (path nil))



(defun editorconfig-core-handle (conf)
  "Return EditorConfig handle for CONF, which should be a file path.

If CONF does not exist return nil."
  (when (file-readable-p conf)
    (let ((cached (gethash conf
                    editorconfig-core-handle--cache-hash))
           (mtime (nth 5
                    (file-attributes conf))))
      (if (and cached
            (equal (editorconfig-core-handle-mtime cached)
              mtime))
        cached
        (let ((parsed (editorconfig-core-handle--parse-file conf)))
          (puthash conf
            (make-editorconfig-core-handle :top-prop (car parsed)
              :prop (cdr parsed)
              :mtime mtime
              :path conf)
            editorconfig-core-handle--cache-hash))))))

(defun editorconfig-core-handle-root-p (handle)
  "Return non-nil if HANDLE represent root EditorConfig file.

If HANDLE is nil return nil."
  (when handle
    (string-equal "true"
      (downcase (or (cdr (assoc "root"
                           (editorconfig-core-handle-top-prop handle)))
                  "")))))

(defun editorconfig-core-handle-get-properties (handle file)
  "Return list of alist of properties from HANDLE for FILE.
The list returned will be ordered by the lines they appear.

If HANDLE is nil return nil."
  (when handle
    (mapcar 'cdr
      (cl-remove-if-not (lambda (prop)
                          (editorconfig-core-handle--fnmatch-p file
                            (car prop)
                            (file-name-directory (editorconfig-core-handle-path handle))))
        (editorconfig-core-handle-prop handle)))))

(defun editorconfig-core-handle--fnmatch-p (name pattern dir)
  "Return non-nil if NAME match PATTERN.
If pattern has slash, pattern should be relative to DIR.

This function is a fnmatch with a few modification for EditorConfig usage."
  (if (string-match-p "/" pattern)
    (let ((pattern (replace-regexp-in-string "^/"
                     ""
                     pattern))
           (dir (file-name-as-directory dir)))
      (editorconfig-fnmatch-p name
        (concat dir
          pattern)))
    (editorconfig-fnmatch-p name
      (concat "**/"
        pattern))))

(defsubst editorconfig-core-handle--string-trim (str)
  "Remove leading and trailing whitespace from STR."
  (replace-regexp-in-string "[ \t\n\r]+\\'"
    ""
    (replace-regexp-in-string "\\`[ \t\n\r]+"
      ""
      str)))

(defun editorconfig-core-handle--parse-file (conf)
  "Parse EditorConfig file CONF.

This function returns cons of its top properties alist and
alist of patterns and its properties alist.
The list returned will be ordered by the lines they appear.

If CONF is not found return nil."
  (when (file-readable-p conf)
    (with-temp-buffer
      ;; NOTE: Use this instead of insert-file-contents-literally to enable
      ;; code conversion
      (insert-file-contents conf)
      (goto-char (point-min))
      (let ((point-max (point-max))
             (all-props ())
             (top-props nil)

             ;; String of current line
             (line "")
             ;; nil when pattern not appeared yet, "" when pattern is empty ("[]")
             (pattern nil)
             ;; Alist of properties for current PATTERN
             (props ())

             )
        (while (not (eq (point) point-max))
          (setq line
            (buffer-substring-no-properties (point-at-bol)
              (point-at-eol)))
          (setq line
            (replace-regexp-in-string "\\(^\\| \\)\\(#\\|;\\).*$"
              ""
              (editorconfig-core-handle--string-trim line)))

          (cond
            ((string-equal "" line)
              nil)

            ((string-match "^\\[\\(.*\\)\\]$"
               line)
              (when pattern
                (setq all-props
                  `(,@all-props (,pattern . ,props)))
                (setq props nil))
              (setq pattern (match-string 1 line)))

            ((string-match-p "=\\|:"
               line)
              ;; NOTE: Using match-string does not work as expected
              (let* (
                      (idx (string-match "=\\|:"
                             line))
                      (key (downcase (editorconfig-core-handle--string-trim (substring line
                                                                              0
                                                                              idx))))
                      (value (editorconfig-core-handle--string-trim (substring line
                                                                      (1+ idx))))
                      )
                (when (and (< (length key) 51)
                        (< (length value) 256))
                  (if pattern
                    (when (< (length pattern) 4097)
                      (setq props
                        `(,@props (,key . ,value))))
                    (setq top-props
                      `(,@top-props (,key . ,value)))))))
            )
          (forward-line 1))
        (when pattern
          (setq all-props
            `(,@all-props (,pattern . ,props))))
        (cons top-props
          all-props)))))

(provide 'editorconfig-core-handle)

;;; editorconfig-core-handle.el ends here
