;; verparse.el
;;
;; Author: Chuck McClish (charles.mcclish@microchip.com)
;; This file should be loaded in your .emacs file when you load a verilog file
;;
;; It issues the verparse script with the necessary arguments and returns the data
;; in the form of opening the returned file and moving the cursor to point or (in
;; the case of multi-line outputs) returns the multiple outputs to an interactive
;; buffer

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

; Setup symbol rings
(defvar verparse-signal-symbol-ring nil)
(defvar verparse-module-symbol-ring nil)
(defvar verparse-define-symbol-ring nil)

; Run a signal definition search
(defun verparse-signal-search ()
  "Issue a signal search using the external verparse perl script and open the
   returned file in a new buffer and move point to the returned line number"
  (interactive)
  ; Create an interactive prompt
  (setq verparse-search-string (read-from-minibuffer "Goto signal definition: " (verparse-get-default-symbol) nil nil 'verparse-signal-symbol-ring))
  (cons verparse-search-string verparse-signal-symbol-ring)
  
  ; Issue the verparse command
  (setq verparse-output-string (shell-command-to-string (concat "verparse -t signal -f "
                                                                buffer-file-name
                                                                " -s "
                                                                verparse-search-string)))
  ; Check to see if returned string is empty
  (if (string= "\n" verparse-output-string)
      (message (concat "The signal '" verparse-search-string "' was not found."))

  ; Open up the returned file and move point to the returned line number
  (progn
    (setq verparse-output-list (split-string verparse-output-string "[ \n]+" t))
    (find-file (car verparse-output-list))
    (goto-line (string-to-number (nth 1 verparse-output-list)))))
  )

; Run a module definition search
(defun verparse-module-search ()
  "Issue a module search using the external verparse perl script and open the
   returned file in a new buffer and move point to the returned line number"
  (interactive)
  ; Create an interactive prompt
  (setq verparse-search-string (read-from-minibuffer "Goto module definition: " (verparse-get-default-symbol) nil nil 'verparse-module-symbol-ring))
  (cons verparse-search-string verparse-module-symbol-ring)
  
  ; Issue the verparse command
  (setq verparse-output-string (shell-command-to-string (concat "verparse -t module -s "
                                                                verparse-search-string)))
  ; Check to see if returned string is empty
  (if (string= "\n" verparse-output-string)
      (message (concat "The module '" verparse-search-string "' was not found."))

  ; Open up the returned file and move point to the returned line number
  (progn
    (setq verparse-output-list (split-string verparse-output-string "[ \n]+" t))
    (find-file (car verparse-output-list))
    (goto-line (string-to-number (nth 1 verparse-output-list)))))
  )

; Run a define value search
(defun verparse-define-search ()
  "Issue a define search using the external verparse perl script and print
   the defined value in the minbuffer"
  (interactive)
  ; Create an interactive prompt
  (setq verparse-search-string (read-from-minibuffer "Find value of define: " (verparse-get-default-symbol) nil nil 'verparse-define-symbol-ring))
  (cons verparse-search-string verparse-define-symbol-ring)
  
  ; Issue the verparse command
  (setq verparse-output-string (shell-command-to-string (concat "verparse -t define -s "
                                                                verparse-search-string)))
  ; Check to see if returned string is empty
  (if (string= "\n" verparse-output-string)
      (message (concat "The define '" verparse-search-string "' was not found."))

  ; Return the searched define value
  (progn
    (setq verparse-output-list (split-string verparse-output-string "[ \n]+" t))
    (message (concat "Value of define '" verparse-search-string "': " (car verparse-output-list)))))
  )


; Pull the verilog symbol from word under point
(defun verparse-get-default-symbol ()
  "Return symbol around current point as a string."
  (save-excursion
    (buffer-substring (progn
			(skip-chars-backward " \t")
			(skip-chars-backward "a-zA-Z0-9_")
			(point))
		      (progn
			(skip-chars-forward "a-zA-Z0-9_")
			(point)))))

;; Keybindings for commands, add these to the verilog-mode-map
;; used in Emacs verilog-mode
(define-key verilog-mode-map "\C-c\C-f" 'verparse-signal-search)
(define-key verilog-mode-map "\C-c\C-m" 'verparse-module-search)
(define-key verilog-mode-map "\C-c\C-d" 'verparse-define-search)

;; Add commands to the Verilog-mode menu
(easy-menu-add-item verilog-menu
   '("Verparse")
      ["Goto signal definition" verparse-signal-search
       :help "Go to the definition of the given signal"])

(easy-menu-add-item verilog-menu
   '("Verparse")
      ["Goto module definition" verparse-module-search
       :keys "C-c C-m"
       :help "Go to the definition of the given module"])

(easy-menu-add-item verilog-menu
   '("Verparse")
      ["Return the define value" verparse-define-search
       :keys "C-c C-d"
       :help "Return the value of the given define"]
      )

;; Remove the verilog-mode version of the module goto
(easy-menu-remove-item verilog-menu
   '("Move") "Goto function/module")

(provide 'verparse)

;; Local Variables:
;; checkdoc-permit-comma-termination-flag:t
;; checkdoc-force-docstrings-flag:nil
;; End:

;;; verparse.el ends here