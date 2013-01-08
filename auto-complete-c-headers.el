;;; auto-complete-c-headers.el --- An auto-complete source for C/C++ header files

;; Copyright (C) 2013  Masafumi Oyamada

;; Author: Masafumi Oyamada <stillpedant@gmail.com>
;; Keywords: c

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; (require 'auto-complete-c-headers)
;; (add-to-list 'ac-sources 'ac-source-c-headers)

;;; Code:

(eval-when-compile (require 'cl))

(defvar achead:include-patterns (list "\\.\\(h\\|hpp\\|hh\\)$")
  "Regexp pattern list that limits the candidates. If a candidate
  matches a pattern in `achead:include-patterns', the candidates
  will be displayed.")

(defvar achead:include-directories (list "/usr/include/" "/usr/local/include/")
  "Standard include directories.")

(defvar achead:get-include-directories-function 'achead:get-include-directories
  "Function that collects include directories.")

(defun achead:get-include-directories ()
  "Default function for `achead:get-include-directories-function',
  which simply returns the contents of
  `achead:include-directories'. "
  achead:include-directories)

(defvar achead:ac-prefix "#\\(?:include\\|import\\)[ \t]*[<\"][ \t]*\\([^\"<>' \t\r\n]+\\)"
  "`prefix' value for `auto-complete'")

(defun achead:get-include-directories-from-options (cmd-line-options)
  "Extract include directory names from command line options
  like (\"-I~/.local/include/\" \"-I~/src/include/\")."
  (loop for option in cmd-line-options
        when (let (case-fold-search)
               (string-match "^-I\\(.*\\)" option))
        collect (match-string 1 option)))

(defvar achead:include-cache nil
  "Cache file list of include directories.")

(defun achead:file-list-for-directory (dir)
  "Get file list of the directory `dir'."
  (ignore-errors
    (or (assoc-default dir achead:include-cache)
        (let ((files (directory-files dir nil "^[^.]")))
          (push (cons dir files) achead:include-cache)
          files))))

(defun achead:path-should-be-displayed (path)
  "Decide `path' should be displayed as a candidate."
  (loop for include-pattern in achead:include-patterns
        when (string-match-p include-pattern path)
        return t))

(defun achead:get-include-file-candidates (&optional basedir)
  "Get all header files under `basedir' as if -I option is
enabled for directories returned by
`achead:get-include-directories-function'."
  (loop with dir-suffix = (or basedir "")
        for include-base in (cons dir-suffix (funcall achead:get-include-directories-function))
        append (loop with dir = (file-name-directory (concat (file-name-as-directory include-base)
                                                             dir-suffix))
                     with files = (achead:file-list-for-directory dir)
                     for file in files
                     ;; FIXME: Are there a good way to bind variable inside a loop (`with' cannot capture `file')?
                     ;; (concat dir file) should be bounded to a variable like `real-path'
                     when (or (file-directory-p (concat dir file))
                              (and achead:include-patterns (achead:path-should-be-displayed (concat dir file))))
                     collect (if (file-directory-p (concat dir file))
                                 (concat dir-suffix (concat file "/"))
                               (concat dir-suffix file)))))

(defun achead:ac-candidates ()
  "Candidate-collecting function for `auto-complete'."
  (ignore-errors
    (achead:get-include-file-candidates (file-name-directory ac-prefix))))

(ac-define-source c-headers
  `((init . (setq achead:include-cache nil))
    (candidates . achead:ac-candidates)
    (prefix . ,achead:ac-prefix)
    (requires . 0)
    (symbol . "I")
    (action . ac-start)
    (limit . nil)))

(provide 'auto-complete-c-headers)
;;; auto-complete-c-headers.el ends here
