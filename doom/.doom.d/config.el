;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Antoniy Chonkov"
      user-mail-address "antoniy@chonkov.net")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 15 :weight 'semi-light)
      doom-big-font (font-spec :family "FiraCode Nerd Font" :size 24))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq
 doom-theme 'doom-one

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
 org-directory "~/notes/"

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
 display-line-numbers-type 'visual
)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(defun insert-current-date () (interactive)
  (insert (shell-command-to-string "echo -n $(date +%Y-%m-%d)")))

(define-key evil-normal-state-map (kbd "g j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "g k") 'evil-previous-visual-line)

(setq evil-snipe-scope 'buffer)
(evil-snipe-override-mode 1)

(defun read-system-path ()
  (with-temp-buffer
    (insert-file-contents "/etc/paths")
    (goto-char (point-min))
    (replace-regexp "\n" ":")
    (thing-at-point 'line)))

(setenv "PATH" (read-system-path))


(after! projectile
  (setq projectile-project-search-path '("~/projects/")
        projectile-globally-ignored-directories '("*target" "*.terraform" "flow-typed" "node_modules" "~/.emacs.d/.local/" ".idea" ".vscode" ".ensime_cache" ".eunit" ".git" ".hg" ".fslckout" "_FOSSIL_" ".bzr" "_darcs" ".tox" ".svn" ".stack-work" ".ccls-cache" ".cache" ".clangd"))
        projectile-globally-ignored-file-suffixes '("class" ".elc" ".pyc" ".o"))

(setq lsp-java-vmargs '("-noverify" "-Xmx1G" "-javaagent:/Users/antoniy/.m2/repository/org/projectlombok/lombok/1.18.12/lombok-1.18.12.jar" "-Xbootclasspath/a:/Users/antoniy/.m2/repository/org/projectlombok/lombok/1.18.12/lombok-1.18.12.jar"))

