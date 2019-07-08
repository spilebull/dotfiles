;; --------------------------------------------------
;; php-mode
;;
;; --------------------------------------------------
(load-library "php-mode")
(require 'php-mode)

(add-hook 'php-mode-hook '(lambda () (setq tab-width 2)))

(add-to-list 'auto-mode-alist '("\.php$" . php-mode))       ;*.phpのファイルのときにphp-modeを自動起動
(add-to-list 'auto-mode-alist '("\.blade\.php$" . web-mode)) ;*.blade.phpのファイルのときにweb-modeを自動起動
