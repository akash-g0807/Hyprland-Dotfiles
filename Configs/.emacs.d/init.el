
(setq inhibit-startup-message t)

;;;; WAYLAND
(when (getenv "WAYLAND_DISPLAY")
  (setq wl-copy-p nil
        interprogram-cut-function (lambda (text)
                                    (setq-local process-connection-type 'pipe)
                                    (setq wl-copy-p (start-process "wl-copy" nil "wl-copy" "-f" "-n"))
                                    (process-send-string wl-copy-p text)
                                    (process-send-eof wl-copy-p))
        interprogram-paste-function (lambda ()
                                      (unless (and wl-copy-p (process-live-p wl-copy-p))
                                        (shell-command-to-string "wl-paste -n | tr -d '\r'")))))
(defvar runemacs/default-font-size 120)
(defvar xdg-bin (getenv "XDG_BIN_HOME")
  "The XDG bin base directory.")

(defvar xdg-cache (getenv "XDG_CACHE_HOME")
  "The XDG cache base directory.")

(defvar xdg-config (getenv "XDG_CONFIG_HOME")
  "The XDG config base directory.")

(defvar xdg-data (getenv "XDG_DATA_HOME")
  "The XDG data base directory.")

(defvar xdg-lib (getenv "XDG_LIB_HOME")
  "The XDG lib base directory.")



(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar


;;; Code:

;; Set up the visible bell
(setq visible-bell t)

;;;;;;; FONT CONFIG
(set-face-attribute 'default nil :font "Fira Code Retina" :height 120)

(set-face-attribute 'default nil :font "Fira Code Retina" :height runemacs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 120)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 135 :weight 'regular)

;;;;;;;; FINT CONFIG

(load-theme 'wombat)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))


;; Line Numbers and Column Numbers
(column-number-mode)
;; set type of line numbering (global variable)
(setq display-line-numbers-type 'relative) 

;; activate line numbering in all buffers/modes
(global-display-line-numbers-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                eshell-mode-hook
                dashboard-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;;;;;;;;;; DASHBOARD ;;;;;;;;;;;;;;;;;;

(require 'dashboard)
(dashboard-setup-startup-hook)
;; Or if you use use-package
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))

;;;;;;;;;;; DASHBOARD ;;;;;;;;;;;;;;;;;

;;;; NATIVE COMPILE
;; Silence compiler warnings as they can be pretty disruptive
(if (boundp 'comp-deferred-compilation)
    (setq comp-deferred-compilation nil)
    (setq native-comp-deferred-compilation nil))
;; In noninteractive sessions, prioritize non-byte-compiled source files to
;; prevent the use of stale byte-code. Otherwise, it saves us a little IO time
;; to skip the mtime checks on every *.elc file.
(setq load-prefer-newer noninteractive)


;; Commmand Log Mode
(use-package command-log-mode)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(global-set-key (kbd "C-M-j") 'counsel-switch-buffer)


(use-package all-the-icons)

;; DOOM MODELINE
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; DOOM THEMES

;; Don't keep asking to load theme
(setq sml/no-confirm-load-theme t)
(setq custom-safe-themes t)

(use-package doom-themes
  :init (load-theme 'doom-one))
(doom-themes-neotree-config)



;; Rainbow Delimiters for brackets
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which key
  ;; It tells which key chords are available for a specific shortcut
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))
(use-package which-key
  :init
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit t
        which-key-separator " → " ))
(which-key-mode)

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-allow-imprecise-window-fit nil
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; COUNSEL STUFF
;; ADD SWITCH BUFFER COMMANDS
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

;;; IVY PRESICNT
(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  (prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))


;; GENERAL EL
(use-package general
  :config
  (general-create-definer rune/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rune/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")))


;; VIM

(use-package evil
  :init (setq evil-want-C-i-jump nil)     ;; tweak evil's configuration before loading it
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode))
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))
(use-package evil-tutor)

(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "fde" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/Emacs.org")))))



(add-hook 'after-make-frame-functions (lambda (f) (set-face-attribute 'default f :font "Fira Code Retina")))
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))


;;;;;;;;;;;;;;;;;;; GARBAGE COLLECTION ::::::::::::::::::::::::::::;;;
  ;; Using garbage magic hack.
 (use-package gcmh
   :config
   (gcmh-mode 1))
;; Setting garbage collection threshold
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive (setq comp-async-report-warnings-errors nil)

;;;;;;;;;;;;;;;;;; GARBAGE COLLECTION ::::::::::::::::::::::::::::;;;

;;;;;;;;;;;;;;;;;; FOCUS NEW BUFFER

(use-package window
  :ensure nil
  :bind (("C-x 2" . vsplit-last-buffer)
         ("C-x 3" . hsplit-last-buffer)
         ;; Don't ask before killing a buffer.
         ([remap kill-buffer] . kill-this-buffer))
  :preface
  (defun hsplit-last-buffer ()
    "Focus to the last created horizontal window."
    (interactive)
    (split-window-horizontally)
    (other-window 1))

  (defun vsplit-last-buffer ()
    "Focus to the last created vertical window."
    (interactive)
    (split-window-vertically)
    (other-window 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 
 ;; HYDRA

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rune/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(vterm octicons company-math company-auctex auto-dictionary auctex-latexmk flycheck-aspell dired-single pyvenv python-mode platformio-mode dired-subtree irony-mode lsp-latex yasnipper lsp-pyright latex-preview-pane centaur-tabs pdf-tools dired-hide-dotfiles neotree lua-mode haskell-mode smex peep-dired dired-open all-the-icons-dired company-lsp irony ccls evil-nerd-commenter company-box company typescript-mode lsp-ivy lsp-treemacs lsp-ui lsp-mode visual-fill-column forge evil-magit magit dashboard counsel-projectile projectile hydra which-key use-package rainbow-delimiters ivy-rich helpful general evil-collection doom-themes doom-modeline counsel command-log-mode all-the-icons)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; BUFFERS
(use-package general
  :config
  (general-evil-setup t))

(nvmap :prefix "SPC" :states '(normal visual global) :keymaps 'override
       "b b"   '(ibuffer :which-key "Ibuffer")
       "b c"   '(clone-indirect-buffer-other-window :which-key "Clone indirect buffer other window")
       "b k"   '(kill-current-buffer :which-key "Kill current buffer")
       "b n"   '(next-buffer :which-key "Next buffer")
       "b p"   '(previous-buffer :which-key "Previous buffer")
       "b B"   '(ibuffer-list-buffers :which-key "Ibuffer list buffers")
       "b K"   '(kill-buffer :which-key "Kill buffer"))

;; BOOKMARKS
(setq bookmark-default-file "~/.emacs.d/bookmarks")
(nvmap :prefix "SPC" :states '(normal visual global) :keymaps 'override
       "b L"   '(list-bookmarks :which-key "List Bookmarks")
       "b m"   '(bookmark-set :which-key "Set Bookmark")
       "b M"   '(bookmark-set :which-key "Delete Bookmarks")
       "b w"   '(bookmark-save :which-key "Save bookmark tp file")
       "b RET" '(counsel-bookmark :which-key "Save bookmark"))
      

;; EVALUATE ELSIP COMMANDS
(nvmap :states '(normal visual global) :keymaps 'override :prefix "SPC"
       "e b"   '(eval-buffer :which-key "Eval elisp in buffer")
       "e d"   '(eval-defun :which-key "Eval defun")
       "e e"   '(eval-expression :which-key "Eval elisp expression")
       "e l"   '(eval-last-sexp :which-key "Eval last sexression")
       "e r"   '(eval-region :which-key "Eval region"))

;; PROJECTILE

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package projectile
  :config
  (projectile-global-mode 1))

(use-package counsel-projectile
 :after projectile
 :config
 (counsel-projectile-mode 1))


 ;; MAGIT
 (use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Forge for github tokens
(use-package forge)

;; Git timemachine
(use-package git-timemachine
  :after git-timemachine
  :hook (evil-normalize-keymaps . git-timemachine-hook)
  :config
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-j") 'git-timemachine-show-previous-revision)
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-k") 'git-timemachine-show-next-revision)
)

;; Highlight TODO
(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

;;;;;;;;;;;;;;;;;;;;;;;; ORG MODE STUFF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

;; Org Mode Configuration ------------------------------------------------------

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
   (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))


(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t))


;;;;;; ORG AGENDA ;;;;;;

(setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

 ; (setq org-agenda-files
	;'("~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org"
	;  "~/Projects/Code/emacs-from-scratch/OrgFiles/Habits.org"
	 ; "~/Projects/Code/emacs-from-scratch/OrgFiles/Birthdays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

(advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  
  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup)

;;;;;; ORG AGENDA ;;;;;;

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))


(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;; ORG FACES

(use-package org-faces
  :ensure nil
  :custom
  (org-todo-keyword-faces
   '(("DONE"    . (:foreground "#8abeb7" :weight bold))
     ("NEXT"    . (:foreground "#f0c674" :weight bold))
     ("SOMEDAY" . (:foreground "#b294bb" :weight bold))
     ("TODO"    . (:foreground "#b5bd68" :weight bold))
     ("WAITING" . (:foreground "#de935f" :weight bold)))))



;;;;;;;;;;;;;;;;;;;;;; ORG  BABEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))


(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

  ;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

;;;;;;;;;;;;;;;;;;;;;; ORG  BABEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-package org
  :delight "Θ"
  :hook (org-mode . turn-off-auto-fill)
  :bind ("C-c i" . org-insert-structure-template)
  :preface
  (defun my/org-archive-done-tasks ()
    "Archive finished or cancelled tasks."
    (interactive)
    (org-map-entries
     (lambda ()
       (org-archive-subtree)
       (setq org-map-continue-from (outline-previous-heading)))
     "TODO=\"DONE\"|TODO=\"CANCELLED\"" (if (org-before-first-heading-p) 'file 'tree)))

  (defun my/org-jump ()
    "Jump to a specific task."
    (interactive)
    (let ((current-prefix-arg '(4)))
      (call-interactively 'org-refile)))

  (defun my/org-use-speed-commands-for-headings-and-lists ()
    "Activate speed commands on list items too."
    (or (and (looking-at org-outline-regexp) (looking-back "^\**"))
        (save-excursion (and (looking-at (org-item-re)) (looking-back "^[ \t]*")))))

  (defmacro ignore-args (fnc)
    "Returns function that ignores its arguments and invokes FNC."
    `(lambda (&rest _rest)
       (funcall ,fnc)))
  :hook (;; (after-save . my/config-tangle)
         (auto-save . org-save-all-org-buffers)
         (org-mode . visual-line-mode))
  :custom
  (org-archive-location "~/.personal/archives/%s::")
  (org-blank-before-new-entry '((heading . t)
                                (plain-list-item . t)))
  (org-confirm-babel-evaluate nil)
  (org-cycle-include-plain-lists 'integrate)
  (org-ellipsis " ▾")
  (org-export-backends '(ascii beamer html icalendar latex man md org texinfo))
  (org-hide-emphasis-markers t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-modules '(org-crypt
                 org-habit
                 org-mouse
                 org-protocol
                 org-tempo))
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-targets '((org-agenda-files :maxlevel . 1)
                        ("~/.personal/agenda/home.org" :maxlevel . 2)
                        ("~/.personal/agenda/work.org" :maxlevel . 2)))
  (org-refile-use-cache nil)
  (org-refile-use-outline-path nil)
  (org-startup-indented t)
  (org-startup-with-inline-images t)
  (org-tag-alist
   '((:startgroup . "Context")
     ("@errands" . ?e)
     ("@home" . ?h)
     ("@work" . ?w)
     (:endgroup)
     (:startgroup . "Difficulty")
     ("easy" . ?E)
     ("medium" . ?M)
     ("challenging" . ?C)
     (:endgroup)
     ("bug" . ?b)
     ("car" . ?v)
     ("future" . ?F)
     ("goal" . ?g)
     ("health" . ?H)
     ("house" . ?O)
     ("meeting" . ?m)
     ("planning" . ?p)
     ("phone" . ?0)
     ("purchase" . ?P)
     ("reading" . ?r)
     ("review" . ?R)
     ("study" . ?s)
     ("sport" . ?S)
     ("talk" . ?T)
     ("tech" . ?t)
     ("trip" . ?I)
     ("thinking" . ?i)
     ("update" . ?u)
     ("watch" . ?l)
     ("writing" . ?W)))
  (org-tags-exclude-from-inheritance '("crypt" "project"))
  (org-todo-keywords '((sequence "TODO(t)"
                                 "STARTED(s)"
                                 "NEXT(n)"
                                 "SOMEDAY(.)"
                                 "WAITING(w)""|" "DONE(x!)" "CANCELLED(c@)")))
  (org-use-effective-time t)
  (org-use-speed-commands 'my/org-use-speed-commands-for-headings-and-lists)
  (org-yank-adjusted-subtrees t)
  :config
  (add-to-list 'org-global-properties '("Effort_ALL". "0:05 0:15 0:30 1:00 2:00 3:00 4:00"))
  (add-to-list 'org-speed-commands '("$" call-interactively 'org-archive-subtree))
  (add-to-list 'org-speed-commands '("i" call-interactively 'org-clock-in))
  (add-to-list 'org-speed-commands '("o" call-interactively 'org-clock-out))
  (add-to-list 'org-speed-commands '("s" call-interactively 'org-schedule))
  (add-to-list 'org-speed-commands '("x" org-todo "DONE"))
  (add-to-list 'org-speed-commands '("y" org-todo-yesterday "DONE"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (advice-add 'org-deadline :after (ignore-args #'org-save-all-org-buffers))
  (advice-add 'org-schedule :after (ignore-args #'org-save-all-org-buffers))
  (advice-add 'org-store-log-note :after (ignore-args #'org-save-all-org-buffers))
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  (advice-add 'org-todo :after (ignore-args #'org-save-all-org-buffers))
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  (org-clock-persistence-insinuate)
  (org-load-modules-maybe t))


  ;;; MORE AGENDA STUFF

  (use-package org-agenda
  :ensure nil
  :bind (:map org-agenda-mode-map
              ("C-n" . org-agenda-next-item)
              ("C-p" . org-agenda-previous-item)
              ("j" . org-agenda-goto)
              ("X" . my/org-agenda-mark-done-next)
              ("x" . my/org-agenda-mark-done))
  :preface
  (defun my/org-agenda-mark-done (&optional arg)
    "Mark the current TODO as done in org-agenda."
    (interactive "P")
    (org-agenda-todo "DONE"))

  (defun my/org-agenda-mark-done-next ()
    "Mark the current TODO as done and add another task after it."
    (interactive)
    (org-agenda-todo "DONE")
    (org-agenda-switch-to)
    (org-capture 0 "t"))
  :custom
  (org-agenda-category-icon-alist
   `(("home" ,(list (all-the-icons-faicon "home" :v-adjust -0.05)) nil nil :ascent center :mask heuristic)
     ("inbox" ,(list (all-the-icons-faicon "inbox" :v-adjust -0.1)) nil nil :ascent center :mask heuristic)
     ("people" ,(list (all-the-icons-material "people" :v-adjust -0.25)) nil nil :ascent center :mask heuristic)
     ("work" ,(list (all-the-icons-material "work" :v-adjust -0.25)) nil nil :ascent center :mask heuristic)
     ("routine" ,(list (all-the-icons-material "repeat" :v-adjust -0.25)) nil nil :ascent center :mask heuristic)
     ))
  (org-agenda-custom-commands
   '(("d" "Dashboard"
      ((agenda "" ((org-deadline-warning-days 7)))
       (todo "NEXT"
             ((org-agenda-overriding-header "Next Tasks")))
       (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

     ("n" "Next Tasks"
      ((agenda "" ((org-deadline-warning-days 7)))
       (todo "NEXT"
             ((org-agenda-overriding-header "Next Tasks")))))

     ("h" "Home Tasks" tags-todo "@home")
     ("w" "Work Tasks" tags-todo "@work")

     ("E" "Easy Tasks" tags-todo "easy")
     ("C" "Challenging Tasks" tags-todo "challenging")

     ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
      ((org-agenda-overriding-header "Low Effort Tasks")
       (org-agenda-max-todos 20)
       (org-agenda-files org-agenda-files)))))
  (org-agenda-dim-blocked-tasks t)
 ;; (org-agenda-files '("~/.personal/agenda"))
  (org-agenda-inhibit-startup t)
  (org-agenda-show-log t)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-span 2)
  (org-agenda-start-on-weekday 6)
  (org-agenda-start-with-log-mode t)
  (org-agenda-sticky nil)
  (org-agenda-tags-column 90)
  (org-agenda-time-grid '((daily today require-timed)))
  (org-agenda-use-tag-inheritance t)
  (org-columns-default-format "%14SCHEDULED %Effort{:} %1PRIORITY %TODO %50ITEM %TAGS")
  (org-default-notes-file "~/.personal/agenda/inbox.org")
 ;; (org-directory "~/.personal")
  (org-enforce-todo-dependencies t)
  (org-habit-completed-glyph ?✓)
  (org-habit-graph-column 80)
  (org-habit-show-habits-only-for-today nil)
  (org-habit-today-glyph ?‖)
  (org-track-ordered-property-with-tag t))


  ;;; NOTIFIER

  (use-package org-wild-notifier
  :after org
  :custom
  (alert-default-style 'libnotify)
  (org-wild-notifier-notification-title "Agenda Reminder")
  :config (org-wild-notifier-mode))


  ;;; ORG CAPTURE

  (use-package org-capture
  :ensure nil
  :preface
  (defvar my/org-active-task-template
    (concat "* NEXT %^{Task}\n"
            ":PROPERTIES:\n"
            ":Effort: %^{effort|1:00|0:05|0:15|0:30|2:00|4:00}\n"
            ":CAPTURED: %<%Y-%m-%d %H:%M>\n"
            ":END:") "Template for basic task.")
  (defvar my/org-appointment
    (concat "* TODO %^{Appointment}\n"
            "SCHEDULED: %t\n") "Template for appointment task.")
  (defvar my/org-basic-task-template
    (concat "* TODO %^{Task}\n"
            ":PROPERTIES:\n"
            ":Effort: %^{effort|1:00|0:05|0:15|0:30|2:00|4:00}\n"
            ":CAPTURED: %<%Y-%m-%d %H:%M>\n"
            ":END:") "Template for basic task.")
  (defvar my/org-contacts-template
    (concat "* %(org-contacts-template-name)\n"
            ":PROPERTIES:\n"
            ":BIRTHDAY: %^{YYYY-MM-DD}\n"
            ":END:") "Template for a contact.")
  :custom
  (org-capture-templates
   `(
     ("c" "Contact" entry (file+headline "~/.personal/agenda/contacts.org" "Inbox"),
      my/org-contacts-template
      :empty-lines 1)

     ("p" "People" entry (file+headline "~/.personal/agenda/people.org" "Tasks"),
      my/org-basic-task-template
      :empty-lines 1)
     ("a" "Appointment" entry (file+headline "~/.personal/agenda/people.org" "Appointments"),
      my/org-appointment
      :empty-lines 1)
     ("m" "Meeting" entry (file+headline "~/.personal/agenda/people.org" "Meetings")
      "* Meeting with %? :meeting:\n%U" :clock-in t :clock-resume t :empty-lines 1)
     ("P" "Phone Call" entry (file+headline "~/.personal/agenda/people.org" "Phone Calls")
      "* Phone %? :phone:\n%U" :clock-in t :clock-resume t)

     ("i" "New Item")
     ("ib" "Book" checkitem (file+headline "~/.personal/items/books.org" "Books")
      "- [ ] %^{Title} - %^{Author}\n  %U"
      :immediate-finish t)
     ("il" "Learning" checkitem (file+headline "~/.personal/items/learning.org" "Things")
      "- [ ] %^{Thing}\n  %U"
      :immediate-finish t)
     ("im" "Movie" checkitem (file+headline "~/.personal/items/movies.org" "Movies")
      "- [ ] %^{Title}\n  %U"
      :immediate-finish t)
     ("ip" "Purchase" checkitem (file+headline "~/.personal/items/purchases.org" "Purchases")
      "- [ ] %^{Item}\n  %U"
      :immediate-finish t)

     ("t" "New Task")
     ("ta" "Active" entry (file+headline "~/.personal/agenda/inbox.org" "Active"),
      my/org-active-task-template
      :empty-lines 1
      :immediate-finish t)
     ("tb" "Backlog" entry (file+headline "~/.personal/agenda/inbox.org" "Backlog"),
      my/org-basic-task-template
      :empty-lines 1
      :immediate-finish t))))

;; ORG CLOCK
(use-package org-clock
  :ensure nil
  :after org
  :preface
  (defun my/org-mode-ask-effort ()
    "Ask for an effort estimate when clocking in."
    (unless (org-entry-get (point) "Effort")
      (let ((effort
             (completing-read
              "Effort: "
              (org-entry-get-multivalued-property (point) "Effort"))))
        (unless (equal effort "")
          (org-set-property "Effort" effort)))))
  :hook (org-clock-in-prepare-hook . my/org-mode-ask-effort)
  :custom
  (org-clock-clocktable-default-properties
   '(:block thisweek :maxlevel 2 :scope agenda :link t :compact t :formula %
            :step week :fileskip0 t :stepskip0 t :narrow 50
            :properties ("Effort" "CLOCKSUM" "TODO")))
  (org-clock-continuously nil)
  (org-clock-in-switch-to-state "STARTED")
  (org-clock-out-remove-zero-time-clocks t)
  (org-clock-persist t)
  ;;(org-clock-persist-file (expand-file-name (format "%s/emacs/org-clock-save.el" xdg-cache)))
  (org-clock-persist-query-resume nil)
  (org-clock-report-include-clocking-task t)
  (org-show-notification-handler (lambda (msg) (alert msg))))

;; PRG LANGUAGES

(use-package python :ensure nil :after org)
(use-package ob-C :ensure nil :after org)
(use-package ob-css :ensure nil :after org)
(use-package ob-dot :ensure nil :after org)
(use-package ob-emacs-lisp :ensure nil :after org)
(use-package ob-gnuplot :ensure nil :after org)
(use-package ob-java :ensure nil :after org)
(use-package ob-js :ensure nil :after org)
(use-package ob-latex
  :ensure nil
  :after org
  :custom (org-latex-compiler "xelatex"))
(use-package ob-makefile :ensure nil :after org)
(use-package ob-org :ensure nil :after org)

(use-package ob-python :ensure nil :after org)
(use-package ob-shell :ensure nil :after org)
(use-package ob-sql :ensure nil :after org)


;; ORG NOTES AND ROAM
(use-package org-roam
  :after org
  :init
  (setq org-roam-v2-ack t)
  (setq my/daily-note-filename "%<%Y-%m-%d>.org.gpg"
        my/daily-note-header "#+title: %<%Y-%m-%d %a>\n\n[[roam:%<%Y-%B>]]\n\n")
  :custom
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n")
      :unnarrowed t)))
  (org-roam-completion-everywhere t)
  (org-roam-dailies-directory "journal/")
  (org-roam-dailies-capture-templates
   `(("d" "default" plain
      "* %?"
      :if-new (file+head ,my/daily-note-filename
                         ,my/daily-note-header)
      :empty-lines 1)

     ("j" "journal" plain
      "** %<%I:%M %p>  :journal:\n\n%?\n\n"
      :if-new (file+head+olp ,my/daily-note-filename
                             ,my/daily-note-header
                             ("Journal"))
      :empty-lines 1)
     ("m" "meeting" entry
      "** %<%I:%M %p> - %^{Meeting Title}  :meeting:\n\n%?\n\n"
      :if-new (file+head+olp ,my/daily-note-filename
                             ,my/daily-note-header
                             ("Meetings"))
      :empty-lines 1)))
  ;; (org-roam-directory "~/.personal/notes")
  :custom (org-roam-graph-viewer "/usr/bin/firefox")
  :config (org-roam-setup))

;;;;;;;;;;;;;;;;;;;;;;;; ORG MODE STUFF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; PERSPECTIVE
(use-package perspective
  :custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init 
  (persp-mode)
  :config
  ;; Sets a file to write to when we save states
  (setq persp-state-default-file "~/.config/emacs/sessions"))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)


;;;;;;;;;;;;;;;;;;; LSP MODE

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))


;;; COMPANY MODE
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; CCLS
(use-package ccls
  :init (setq ccls-sem-highlight-method 'font-lock)
  :hook ((c-mode c++-mode objc-mode) . (lambda () (require 'ccls) (lsp-deferred))))

;; Brackteting in programming languages
(setq electric-pair-preserve-balance nil)
(electric-pair-mode 1)

;; IRONY MODE
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)


(use-package ccls
  :ensure t
  :config
  (setq ccls-executable "ccls")
  (setq lsp-prefer-flymake nil)
  (setq-default flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck c/c++-gcc))
  :hook ((c-mode c++-mode objc-mode) .
         (lambda () (require 'ccls) (lsp))))


(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-cpptools)
  (yas-global-mode))


  (use-package platformio-mode)
  ;; edit ino files with adruino mode. 
  (add-to-list 'auto-mode-alist '("\\.ino$" . arduino-mode)) 
  ;; Enable irony for all c++ files, and platformio-mode only
  ;; when needed (platformio.ini present in project root).
  (add-hook 'c++-mode-hook (lambda ()
                             (irony-mode)
                             (irony-eldoc)
                             (platformio-conditionally-enable)))

  ;; Use irony's completion functions.
  (add-hook 'irony-mode-hook
            (lambda ()
              (define-key irony-mode-map [remap completion-at-point]
                'irony-completion-at-point-async)

              (define-key irony-mode-map [remap complete-symbol]
                'irony-completion-at-point-async)

              (irony-cdb-autosetup-compile-options)))


;;;;;;;;;;;;;;;;;;; LSO MODE
(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))


;;;;;;;;;; DEBUGGING DAP ;;;;;;;;;;;;

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands dap-debug
  :config
  ;; Set up Node debugging

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :wk "debugger")))
(add-hook 'dap-stopped-hook
          (lambda (arg) (call-interactively #'dap-hydra)))
;;;;;;;;;; DEBUGGING DAP ;;;;;;;;;;;;


;;;;;;;; PYTHON LANGUAGE SERVER ;;;;;;;;;;;;;;;;

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :after python-mode
  :config
  (pyvenv-mode 1))

;;; A minimal config for using lsp-mode

(setq lsp-keymap-prefix "C-c l")

(require 'lsp-mode)
;; Start lsp-mode with desired languages
(add-hook 'python-mode-hook #'lsp)
(add-hook 'go-mode-hook     #'lsp)
;; Add more as needed

(setq lsp-eldoc-render-all t)

;; Drop-down auto completion
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))
;;;;;;;; PYTHON LANGUAGE SERVER ;;;;;;;;;;;;;;;;


;; DIRED
(use-package all-the-icons-dired)
(use-package dired-open)
(use-package peep-dired)

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
               "d d" '(dired :which-key "Open dired")
               "d j" '(dired-jump :which-key "Dired jump to current")
               "d p" '(peep-dired :which-key "Peep-dired"))

(with-eval-after-load 'dired
  ;;(define-key dired-mode-map (kbd "M-p") 'peep-dired)
  (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
  (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
  (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
  (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file))

(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;; With dired-open plugin, you can launch external programs for certain extensions
;; For example, I set all .png files to open in 'sxiv' and all .mp4 files to open in 'mpv'
(setq dired-open-extensions '(("gif" . "sxiv")
                              ("jpg" . "sxiv")
                              ("png" . "sxiv")
                              ("mkv" . "mpv")
                              ("mp4" . "mpv")))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))

(use-package dired-single)

  (evil-collection-define-key 'normal 'dired-mode-map
      "h" 'dired-single-up-directory
      "l" 'dired-single-buffer)

;; SHOW HIDE DOTFILES

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))


;; FILE RELATED KEYBINDINGS
(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "."     '(find-file :which-key "Find file")
       "f f"   '(find-file :which-key "Find file")
       "f r"   '(counsel-recentf :which-key "Recent files")
       "f s"   '(save-buffer :which-key "Save file")
       "f u"   '(sudo-edit-find-file :which-key "Sudo find file")
       "f y"   '(dt/show-and-copy-buffer-path :which-key "Yank file path")
       "f C"   '(copy-file :which-key "Copy file")
       "f D"   '(delete-file :which-key "Delete file")
       "f R"   '(rename-file :which-key "Rename file")
       "f S"   '(write-file :which-key "Save file as...")
       "f U"   '(sudo-edit :which-key "Sudo edit file"))

;; GENERAL COMMANDS
(nvmap :keymaps 'override :prefix "SPC"
       "SPC"   '(counsel-M-x :which-key "M-x")
       "c c"   '(compile :which-key "Compile")
       "c C"   '(recompile :which-key "Recompile")
       "h r r" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :which-key "Reload emacs config")
       "t t"   '(toggle-truncate-lines :which-key "Toggle truncate lines"))
(nvmap :keymaps 'override :prefix "SPC"
       "m *"   '(org-ctrl-c-star :which-key "Org-ctrl-c-star")
       "m +"   '(org-ctrl-c-minus :which-key "Org-ctrl-c-minus")
       "m ."   '(counsel-org-goto :which-key "Counsel org goto")
       "m e"   '(org-export-dispatch :which-key "Org export dispatch")
       "m f"   '(org-footnote-new :which-key "Org footnote new")
       "m h"   '(org-toggle-heading :which-key "Org toggle heading")
       "m i"   '(org-toggle-item :which-key "Org toggle item")
       "m n"   '(org-store-link :which-key "Org store link")
       "m o"   '(org-set-property :which-key "Org set property")
       "m t"   '(org-todo :which-key "Org todo")
       "m x"   '(org-toggle-checkbox :which-key "Org toggle checkbox")
       "m B"   '(org-babel-tangle :which-key "Org babel tangle")
       "m I"   '(org-toggle-inline-images :which-key "Org toggle inline imager")
       "m T"   '(org-todo-list :which-key "Org todo list")
       "o a"   '(org-agenda :which-key "Org agenda")
       )
    

;;;;;;; DIRED SUB TREE
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)))


;;;;;; DIRED NARROW
(use-package dired-narrow
  :ensure nil
  :bind (("C-c C-n" . dired-narrow)
         ("C-c C-f" . dired-narrow-fuzzy)))

;;Zooming in and out
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; MX Commands
(setq ivy-initial-inputs-alist nil)
(use-package smex)
(smex-initialize)

;; Language support syntax highlightinh
(use-package haskell-mode)
(use-package lua-mode)
(use-package markdown-mode)

;; NEOTREE
;; Function for setting a fixed width for neotree.
;; Defaults to 25 but I make it a bit longer (35) in the 'use-package neotree'.
(defcustom neo-window-width 25
  "*Specifies the width of the NeoTree window."
  :type 'integer
  :group 'neotree)

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-window-width 30
        neo-theme (if (display-graphic-p) 'icons 'arrow)
        ;;neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))
(defun my/disable-line-numbers (&optional dummy)
    (display-line-numbers-mode -1))
(add-hook 'neo-after-create-hook 'my/disable-line-numbers)


;; show hidden files
(setq-default neo-show-hidden-files t)

(nvmap :prefix "SPC"
       "t n"   '(neotree-toggle :which-key "Toggle neotree file viewer")
       "d n"   '(neotree-dir :which-key "Open directory in neotree"))


;; Runtime performance
(setq gc-cons-threshold (* 2 1000 1000))

;; MOUSE SCROLLING
(setq scroll-conservatively 101) ;; value greater than 100 gets rid of half page jumping
(setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; how many lines at a time
(setq mouse-wheel-progressive-speed t) ;; accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse


;; spell check

(use-package flyspell)
(use-package flycheck-aspell)
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))


(eval-after-load "flyspell"
  '(progn
     (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
     (define-key flyspell-mouse-map [mouse-3] #'undefined)))

(defun flyspell-english ()
  (interactive)
  (ispell-change-dictionary "default")
  (flyspell-buffer))
(setq ispell-program-name "aspell")
(setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_GB"))
(setq spell-fu-directory "~/+STORE/dictionary") ;; Please create this directory manually.
(setq ispell-personal-dictionary "~/+STORE/dictionary/.pws")
(setq ispell-dictionary "en")

(use-package lsp-ltex
  :disabled
  :custom
  (lsp-ltex-enabled nil)
  (lsp-ltex-mother-tongue "fr"))

(use-package ispell
  :preface
  (defun my/switch-language ()
    "Switch between the English and French for ispell, flyspell, and LanguageTool."
    (interactive)
    (let* ((current-dictionary ispell-current-dictionary)
           (new-dictionary (if (string= current-dictionary "en_GB") "fr_BE" "en_GB")))
      (ispell-change-dictionary new-dictionary)
      (if (string= new-dictionary "fr_GB")
          (progn
            (setq lsp-ltex-language "fr"))
        (progn
          (setq lsp-ltex-language "en-GB")))
      (flyspell-buffer)
      (message "[✓] Dictionary switched to %s" new-dictionary)))
  :custom
  (ispell-hunspell-dict-paths-alist
   '(("en_GB" "/usr/share/hunspell/en_GB.aff")
     ("fr_BE" "/usr/share/hunspell/fr_BE.aff")))
  ;; Save words in the personal dictionary without asking.
  (ispell-silently-savep t)
  :config
  (setenv "LANG" "en_GB")
  (cond ((executable-find "hunspell")
         (setq ispell-program-name "hunspell")
         (setq ispell-local-dictionary-alist '(("en_GB"
                                                "[[:alpha:]]"
                                                "[^[:alpha:]]"
                                                "['’-]"
                                                t
                                                ("-d" "en_GB" )
                                                nil
                                                utf-8)
                                               ("fr_BE"
                                                "[[:alpha:]ÀÂÇÈÉÊËÎÏÔÙÛÜàâçèéêëîïôùûü]"
                                                "[^[:alpha:]ÀÂÇÈÉÊËÎÏÔÙÛÜàâçèéêëîïôùûü]"
                                                "['’-]"
                                                t
                                                ("-d" "fr_BE")
                                                nil
                                                utf-8))))
        ((executable-find "aspell")
         (setq ispell-program-name "aspell")
         (setq ispell-extra-args '("--sug-mode=ultra"))))
  ;; Ignore file sections for spell checking.
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_align" . "#\\+end_align"))
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_align*" . "#\\+end_align*"))
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_equation" . "#\\+end_equation"))
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_equation*" . "#\\+end_equation*"))
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_example" . "#\\+end_example"))
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_labeling" . "#\\+end_labeling"))
  (add-to-list 'ispell-skip-region-alist '("#\\+begin_src" . "#\\+end_src"))
  (add-to-list 'ispell-skip-region-alist '("\\$" . "\\$"))
  (add-to-list 'ispell-skip-region-alist '(org-property-drawer-re))
  (add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:")))

;;;;;;;;;;;;;;;;;;;;;;;; LATEX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  (define-key pdf-view-mode-map (kbd "C-r") 'isearch-backward)
  (add-hook 'pdf-view-mode-hook (lambda ()
				  (bms/pdf-midnite-amber))) ; automatically turns on midnight-mode for pdfs
  )

(use-package auctex-latexmk
  :ensure t
  :config
  (auctex-latexmk-setup)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

(use-package reftex
  :ensure t
  :defer t
  :config
  (setq reftex-cite-prompt-optional-args t)) ;; Prompt for empty optional arguments in cite

(use-package auto-dictionary
  :ensure t
  :init(add-hook 'flyspell-mode-hook (lambda () (auto-dictionary-mode 1))))

(use-package company-auctex
  :ensure t
  :init (company-auctex-init))

(use-package company-math
  :ensure t
)

(defun my-latex-mode-setup ()
  (setq-local company-backends
              (append '((company-math-symbols-latex company-latex-commands))
                      company-backends)))

(add-hook 'tex-mode-hook 'my-latex-mode-setup)
(add-hook 'TeX-mode-hook 'my-latex-mode-setup)

(use-package tex
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config (progn
	    (setq TeX-source-correlate-mode t)
	    (setq TeX-source-correlate-method 'synctex)
	    (setq TeX-auto-save t)
	    (setq TeX-parse-self t)
	    (setq-default TeX-master "paper.tex")
	    (setq reftex-plug-into-AUCTeX t)
	    (pdf-tools-install)
	    (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
		  TeX-source-correlate-start-server t)
	    ;; Update PDF buffers after successful LaTeX runs
	    (add-hook 'TeX-after-compilation-finished-functions
		      #'TeX-revert-document-buffer)
	    (add-hook 'LaTeX-mode-hook
		      (lambda ()
			(reftex-mode t)
			(flyspell-mode t)))
	    ))
(use-package latex-preview-pane)

(require 'latex)					;(add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))
(add-hook 'LaTeX-mode-hook ;this are the hooks I want to enable during LaTeX-mode
	  (lambda()
	    (turn-on-reftex) ;enable reftex
	   ; (turn-on-cdlatex) ; I am not using cdlatex mauch.
	    (set (make-local-variable 'company-backends) '((separate: company-reftex-labels company-reftex-citations) (separate: company-auctex-symbols company-auctex-environments company-capf company-auctex-macros) company-math-symbols-latex
	    company-latex-commands ))
	    (rainbow-delimiters-mode)
	    (setq TeX-auto-save t) ;enable autosave on during LaTeX-mode
	    (setq TeX-parse-self t) ; enable autoparsing
	    (setq TeX-save-query nil) ;
	    (setq TeX-source-correlate-method 'synctex) ; enable synctex
 
	    (setq TeX-source-correlate-mode t) ; enable text-source-correlate using synctex
	    (TeX-fold-mode 1); enableing tex fold mode for better readability.
;;	    (TeX-fold-buffer 1)
	    (setq-default TeX-master nil) 
	    (global-set-key (kbd "C-c C-g") 'pdf-sync-forward-search) ;sync from text to pdf
	    (add-hook 'TeX-after-compilation-finished-functions
		      #'TeX-revert-document-buffer) ; reload pdf buffer
	    (setq reftex-plug-into-AUCTeX t) ; enable auctex
	    (setq reftex-bibliography-commands '("bibliography" "nobibliography" "addbibresource"))
	    (local-set-key [C-tab] 'TeX-complete-symbol) ;tex complete symbol
	    ; could be ispell as well, depending on your preferences
	    (setq ispell-program-name "aspell") 
; this can obviously be set to any language your spell-checking program supports
	    (setq ispell-dictionary "english") 
	    (flyspell-mode) ; flyspell mode enable
	    (flyspell-buffer); flyspell buffer
	    (turn-on-auto-fill)
	    (visual-line-mode)
	    (LaTeX-math-mode)
	    )
	  )


(use-package lsp-latex
  :if (executable-find "texlab")
  ;; To properly load `lsp-latex', the `require' instruction is important.
  :hook (LaTeX-mode . (lambda ()
                        (require 'lsp-latex)
                        (lsp-deferred)))
  :custom (lsp-latex-build-on-save t))


;;;;;;;;;;;;;;;;;;;;;;;; LATEX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;; CENTAUR TABS ;;;;;;;;;;;;;;;;

(use-package centaur-tabs
  :init
  (setq centaur-tabs-enable-key-bindings t)
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-show-new-tab-button t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'under
        centaur-tabs-show-count nil
        ;; centaur-tabs-label-fixed-length 15
        ;; centaur-tabs-gray-out-icons 'buffer
        ;; centaur-tabs-plain-icons t
        x-underline-at-descent-line t
        centaur-tabs-left-edge-margin nil)
  (centaur-tabs-change-fonts (face-attribute 'default :font) 110)
  (centaur-tabs-headline-match)
  ;; (centaur-tabs-enable-buffer-alphabetical-reordering)
  ;; (setq centaur-tabs-adjust-buffer-order t)
  (centaur-tabs-mode t)
  (setq uniquify-separator "/")
  (setq uniquify-buffer-name-style 'forward)
  (defun centaur-tabs-buffer-groups ()
    "`centaur-tabs-buffer-groups' control buffers' group rules.

Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
    (list
     (cond
      ;; ((not (eq (file-remote-p (buffer-file-name)) nil))
      ;; "Remote")
      ((or (string-equal "*" (substring (buffer-name) 0 1))
           (memq major-mode '(magit-process-mode
                              magit-status-mode
                              magit-diff-mode
                              magit-log-mode
                              magit-file-mode
                              magit-blob-mode
                              magit-blame-mode
                              )))
       "Emacs")
      ((derived-mode-p 'prog-mode)
       "Editing")
      ((derived-mode-p 'dired-mode)
       "Dired")
      ((memq major-mode '(helpful-mode
                          help-mode))
       "Help")
      ((memq major-mode '(org-mode
                          org-agenda-clockreport-mode
                          org-src-mode
                          org-agenda-mode
                          org-beamer-mode
                          org-indent-mode
                          org-bullets-mode
                          org-cdlatex-mode
                          org-agenda-log-mode
                          diary-mode))
       "OrgMode")
      (t
       (centaur-tabs-get-group-name (current-buffer))))))
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  (term-mode . centaur-tabs-local-mode)
  (calendar-mode . centaur-tabs-local-mode)
  (org-agenda-mode . centaur-tabs-local-mode)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  ("C-S-<prior>" . centaur-tabs-move-current-tab-to-left)
  ("C-S-<next>" . centaur-tabs-move-current-tab-to-right)
  (:map evil-normal-state-map
        ("g t" . centaur-tabs-forward)
        ("g T" . centaur-tabs-backward)))


(nvmap :keymaps 'override :prefix "SPC"
       "t c"   '(centaur-tabs-mode :which-key "Toggle Centaur tabs gloablly")
       "t C"   '(centaur-tabs-local-mode :which-key "Toggle Centaur tabs locally")
)


(evil-define-key 'normal centaur-tabs-mode-map (kbd "g <right>") 'centaur-tabs-forward        ; default Doom binding is 'g t'
                                               (kbd "g <left>")  'centaur-tabs-backward       ; default Doom binding is 'g T'
                                               (kbd "g <down>")  'centaur-tabs-forward-group
                                               (kbd "g <up>")    'centaur-tabs-backward-group)

;;;;;;;;;;; CENTAUR TABS ;;;;;;;;;;;;;;;;


(setq doom-font (font-spec :family "JetBrains Mono" :size 15)
      doom-variable-pitch-font (font-spec :family "Ubuntu" :size 15)
      doom-big-font (font-spec :family "JetBrains Mono" :size 24))

(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)

(defun dt/org-colors-doom-one ()
  "Enable Doom One colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#51afef" ultra-bold)
         (org-level-2 1.6 "#c678dd" extra-bold)
         (org-level-3 1.5 "#98be65" bold)
         (org-level-4 1.4 "#da8548" semi-bold)
         (org-level-5 1.3 "#5699af" normal)
         (org-level-6 1.2 "#a9a1e1" normal)
         (org-level-7 1.1 "#46d9ff" normal)
         (org-level-8 1.0 "#ff6c6b" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-dracula ()
  "Enable Dracula colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#8be9fd" ultra-bold)
         (org-level-2 1.6 "#bd93f9" extra-bold)
         (org-level-3 1.5 "#50fa7b" bold)
         (org-level-4 1.4 "#ff79c6" semi-bold)
         (org-level-5 1.3 "#9aedfe" normal)
         (org-level-6 1.2 "#caa9fa" normal)
         (org-level-7 1.1 "#5af78e" normal)
         (org-level-8 1.0 "#ff92d0" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-gruvbox-dark ()
  "Enable Gruvbox Dark colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#458588" ultra-bold)
         (org-level-2 1.6 "#b16286" extra-bold)
         (org-level-3 1.5 "#98971a" bold)
         (org-level-4 1.4 "#fb4934" semi-bold)
         (org-level-5 1.3 "#83a598" normal)
         (org-level-6 1.2 "#d3869b" normal)
         (org-level-7 1.1 "#d79921" normal)
         (org-level-8 1.0 "#8ec07c" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-monokai-pro ()
  "Enable Monokai Pro colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#78dce8" ultra-bold)
         (org-level-2 1.6 "#ab9df2" extra-bold)
         (org-level-3 1.5 "#a9dc76" bold)
         (org-level-4 1.4 "#fc9867" semi-bold)
         (org-level-5 1.3 "#ff6188" normal)
         (org-level-6 1.2 "#ffd866" normal)
         (org-level-7 1.1 "#78dce8" normal)
         (org-level-8 1.0 "#ab9df2" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-nord ()
  "Enable Nord colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#81a1c1" ultra-bold)
         (org-level-2 1.6 "#b48ead" extra-bold)
         (org-level-3 1.5 "#a3be8c" bold)
         (org-level-4 1.4 "#ebcb8b" semi-bold)
         (org-level-5 1.3 "#bf616a" normal)
         (org-level-6 1.2 "#88c0d0" normal)
         (org-level-7 1.1 "#81a1c1" normal)
         (org-level-8 1.0 "#b48ead" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-oceanic-next ()
  "Enable Oceanic Next colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#6699cc" ultra-bold)
         (org-level-2 1.6 "#c594c5" extra-bold)
         (org-level-3 1.5 "#99c794" bold)
         (org-level-4 1.4 "#fac863" semi-bold)
         (org-level-5 1.3 "#5fb3b3" normal)
         (org-level-6 1.2 "#ec5f67" normal)
         (org-level-7 1.1 "#6699cc" normal)
         (org-level-8 1.0 "#c594c5" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-palenight ()
  "Enable Palenight colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#82aaff" ultra-bold)
         (org-level-2 1.6 "#c792ea" extra-bold)
         (org-level-3 1.5 "#c3e88d" bold)
         (org-level-4 1.4 "#ffcb6b" semi-bold)
         (org-level-5 1.3 "#a3f7ff" normal)
         (org-level-6 1.2 "#e1acff" normal)
         (org-level-7 1.1 "#f07178" normal)
         (org-level-8 1.0 "#ddffa7" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-solarized-dark ()
  "Enable Solarized Dark colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#268bd2" ultra-bold)
         (org-level-2 1.6 "#d33682" extra-bold)
         (org-level-3 1.5 "#859900" bold)
         (org-level-4 1.4 "#b58900" semi-bold)
         (org-level-5 1.3 "#cb4b16" normal)
         (org-level-6 1.2 "#6c71c4" normal)
         (org-level-7 1.1 "#2aa198" normal)
         (org-level-8 1.0 "#657b83" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-solarized-light ()
  "Enable Solarized Light colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#268bd2" ultra-bold)
         (org-level-2 1.6 "#d33682" extra-bold)
         (org-level-3 1.5 "#859900" bold)
         (org-level-4 1.4 "#b58900" semi-bold)
         (org-level-5 1.3 "#cb4b16" normal)
         (org-level-6 1.2 "#6c71c4" normal)
         (org-level-7 1.1 "#2aa198" normal)
         (org-level-8 1.0 "#657b83" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

(defun dt/org-colors-tomorrow-night ()
  "Enable Tomorrow Night colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#81a2be" ultra-bold)
         (org-level-2 1.6 "#b294bb" extra-bold)
         (org-level-3 1.5 "#b5bd68" bold)
         (org-level-4 1.4 "#e6c547" semi-bold)
         (org-level-5 1.3 "#cc6666" normal)
         (org-level-6 1.2 "#70c0ba" normal)
         (org-level-7 1.1 "#b77ee0" normal)
         (org-level-8 1.0 "#9ec400" normal)))
    (set-face-attribute (nth 0 face) nil :font doom-variable-pitch-font :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
    (set-face-attribute 'org-table nil :font doom-font :weight 'normal :height 1.0 :foreground "#bfafdf"))

;; Load our desired dt/org-colors-* theme on startup
(dt/org-colors-doom-one)

;; SUDO EDIT
(use-package sudo-edit)

;; Eshell
(use-package eshell-toggle
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term))

  (use-package eshell-syntax-highlighting
    :after esh-mode
    :config
    (eshell-syntax-highlighting-global-mode +1))

  ;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
  ;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
  ;; eshell-aliases-file -- sets an aliases file for the eshell.

  (setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
        eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))


;; VTERM
(use-package vterm
:config
(setq shell-file-name "/bin/zsh"
      vterm-max-scrollback 5000))

;; VTERM TOGGLE
(use-package vterm-toggle
  :after vterm
  :config
  ;; When running programs in Vterm and in 'normal' mode, make sure that ESC
  ;; kills the program as it would in most standard terminal programs.
  (evil-define-key 'normal vterm-mode-map (kbd "<escape>") 'vterm--self-insert)
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.4))))

;; General Keybinding
(use-package general
  :config
  (general-evil-setup)
 ;; set up 'SPC' as the global leader key
  (general-create-definer dt/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (dt/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
    "TAB TAB" '(comment-line :wk "Comment lines")
    "u" '(universal-argument :wk "Universal argument"))

  (dt/leader-keys
    "b" '(:ignore t :wk "Bookmarks/Buffers")
    "b b" '(switch-to-buffer :wk "Switch to buffer")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-current-buffer :wk "Kill current buffer")
    "b K" '(kill-some-buffers :wk "Kill multiple buffers")
    "b l" '(list-bookmarks :wk "List bookmarks")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(basic-save-buffer :wk "Save buffer")
    "b S" '(save-some-buffers :wk "Save multiple buffers")
    "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

  (dt/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d n" '(neotree-dir :wk "Open directory in neotree")
    "d p" '(peep-dired :wk "Peep-dired"))

  (dt/leader-keys
    "e" '(:ignore t :wk "Eshell/Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e R" '(eww-reload :which-key "Reload current page in EWW")
    "e s" '(eshell :which-key "Eshell")
    "e w" '(eww :which-key "EWW emacs web wowser"))

  (dt/leader-keys
    "f" '(:ignore t :wk "Files")    
    "f c" '((lambda () (interactive)
              (find-file "~/.config/emacs/config.org")) 
            :wk "Open emacs config.org")
    "f e" '((lambda () (interactive)
              (dired "~/.config/emacs/")) 
            :wk "Open user-emacs-directory in dired")
    "f d" '(find-grep-dired :wk "Search for string in files in DIR")
    "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
    "f i" '((lambda () (interactive)
              (find-file "~/.config/emacs/init.el")) 
            :wk "Open emacs init.el")
    "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
    "f l" '(counsel-locate :wk "Locate a file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f u" '(sudo-edit-find-file :wk "Sudo find file")
    "f U" '(sudo-edit :wk "Sudo edit file"))

  (dt/leader-keys
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-displatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file"))

 (dt/leader-keys
    "h" '(:ignore t :wk "Help")
    "h a" '(counsel-apropos :wk "Apropos")
    "h b" '(describe-bindings :wk "Describe bindings")
    "h c" '(describe-char :wk "Describe character under cursor")
    "h d" '(:ignore t :wk "Emacs documentation")
    "h d a" '(about-emacs :wk "About Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
    "h d m" '(info-emacs-manual :wk "The Emacs manual")
    "h d n" '(view-emacs-news :wk "View Emacs news")
    "h d o" '(describe-distribution :wk "How to obtain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs problems")
    "h d t" '(view-emacs-todo :wk "View Emacs todo")
    "h d w" '(describe-no-warranty :wk "Describe no warranty")
    "h e" '(view-echo-area-messages :wk "View echo area messages")
    "h f" '(describe-function :wk "Describe function")
    "h F" '(describe-face :wk "Describe face")
    "h g" '(describe-gnu-project :wk "Describe GNU Project")
    "h i" '(info :wk "Info")
    "h I" '(describe-input-method :wk "Describe input method")
    "h k" '(describe-key :wk "Describe key")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe language environment")
    "h m" '(describe-mode :wk "Describe mode")
    "h r" '(:ignore t :wk "Reload")
    "h r r" '((lambda () (interactive)
                (load-file "~/.config/emacs/init.el")
                (ignore (elpaca-process-queues)))
              :wk "Reload emacs config")
    "h t" '(load-theme :wk "Load theme")
    "h v" '(describe-variable :wk "Describe variable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))

  (dt/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (dt/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (dt/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (dt/leader-keys
    "o" '(:ignore t :wk "Open")
    "o d" '(dashboard-open :wk "Dashboard")
    "o f" '(make-frame :wk "Open buffer in new frame")
    "o F" '(select-frame-by-name :wk "Select frame by name"))

  ;; projectile-command-map already has a ton of bindings 
  ;; set for us, so no need to specify each individually.
  (dt/leader-keys
    "p" '(projectile-command-map :wk "Projectile"))

  (dt/leader-keys
    "s" '(:ignore t :wk "Search")
    "s d" '(dictionary-search :wk "Search dictionary")
    "s m" '(man :wk "Man pages")
    "s t" '(tldr :wk "Lookup TLDR docs for a command")
    "s w" '(woman :wk "Similar to man but doesn't require man"))

  (dt/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t e" '(eshell-toggle :wk "Toggle eshell")
    "t f" '(flycheck-mode :wk "Toggle flycheck")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
    "t o" '(org-mode :wk "Toggle org mode")
    "t r" '(rainbow-mode :wk "Toggle rainbow mode")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  (dt/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))
)
