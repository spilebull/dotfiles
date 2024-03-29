(dolist (dir (list
	      "/sbin"
	      "/usr/sbin"
	      "/bin"
	      "/usr/bin"
	      "/usr/local/bin"
	      (expand-file-name "~/bin")
	      (expand-file-name "~/.emacs.d/bin")
	      ))
  (when (and (file-exists-p dir) (not (member dir exec-path)))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))

(require 'multi-term)
(setq multi-term-program shell-file-name)
