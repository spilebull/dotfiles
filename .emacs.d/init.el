;; Cask Settings
(require 'cask "/home/te-koyama/.cask/cask.el")
(cask-initialize)
(require 'pallet)

;; Init Loader Settings
(require 'init-loader)
(setq init-loader-show-log-after-init nil)
(init-loader-load "/home/te-koyama/.emacs.d/inits")

;; モードラインに行番号表示.
(global-linum-mode t)
(put 'dired-find-alternate-file 'disabled nil)

;; モードラインに列番号表示.
(column-number-mode t)
