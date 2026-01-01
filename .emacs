
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs helm-lsp
    projectile hydra flycheck company avy which-key helm-xref
 dap-mode color-theme-sanityinc-tomorrow xcscope iedit kanban
 elmacro yaml-mode json-mode magit magit-gitlab magit-gptcommit
 plantuml-mode rust-mode ellama gptel markdown-mode editorconfig
 jsonrpc copilot-chat cmake-mode dockerfile-mode ws-butler
 clang-format rainbow-delimiters company-box doxymacs track-changes aidermacs))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(use-package aidermacs
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
                                        ; Set API_KEY in .bashrc, that will automatically picked up by aider or in elisp
  (setenv "ANTHROPIC_API_KEY" "sk-...")
                                        ; defun my-get-openrouter-api-key yourself elsewhere for security reasons
  (setenv "OPENROUTER_API_KEY" (my-get-openrouter-api-key))
  :custom
                                        ; See the Configuration section below
  (aidermacs-default-chat-mode 'architect)
  (aidermacs-default-model "openai/gemma-3-27b-it")
;  (aidermacs-default-model "openai/Qwen3-32B")
  )

(require 'ws-butler)
(add-hook 'prog-mode-hook #'ws-butler-mode)

(add-to-list 'load-path "/home/haase/gitx/copilot.el")
(require 'copilot)
(define-key copilot-completion-map (kbd "C-<return>") 'copilot-accept-completion)

;(use-package company-box
;  :hook (company-mode . company-box-mode))

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ;;             ("M-j" . lsp-ui-imenu)
              ;;             ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  ;;  (setq rustic-format-on-save t)
  ;;  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook)
  )


(use-package lsp-mode
  :ensure
  :commands lsp
  :custom
   ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  ;; enable / disable the hints as you prefer:
  (lsp-inlay-hint-enable t)
  ;; These are optional configurations. See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/#lsp-rust-analyzer-display-chaining-hints for a full list
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))


(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))


;(setq inhibit-compacting-fonts t)
;(set-frame-parameter nil 'font-backend "xft")

;; (setq
;;  gptel-model 'codellama:7b
;;  gptel-backend (gptel-make-ollama "Ollama"
;;                  :host "localhost:11435"
;;                  :stream t
;;                  :models '(codellama:7b)))

;; (setq
;;  gptel-model   'llama-3.1-nemotron-70b-instruct
;;  gptel-backend
;;  (gptel-make-openai "xAI"           ;Any name you want
;;    :host "https://llm-gateway.cloud.rsint.net/"
;;    :key "your-api-key"              ;can be a function that returns the key
;;    :endpoint "/v1"
;;    :stream t
;;    :models '(llama-3.1-nemotron-70b-instruct)))


(use-package ellama
    :bind ("C-c e" . ellama-transient-main-menu)
    :init
    ;; setup key bindings
    ;; (setopt ellama-keymap-prefix "C-c e")
    ;; language you want ellama to translate to
    (setopt ellama-language "English")
    ;; could be llm-openai for example
    (require 'llm-ollama)
    (setopt ellama-provider
          (make-llm-ollama
               ;; this model should be pulled to use it
               ;; value should be the same as you print in terminal during pull
               :chat-model "llama3:8b-instruct-q8_0"
               :embedding-model "nomic-embed-text"
               :default-chat-non-standard-params '(("num_ctx" . 8192))))
    (setopt ellama-summarization-provider
              (make-llm-ollama
               :chat-model "qwen2.5:3b"
               :embedding-model "nomic-embed-text"
               :default-chat-non-standard-params '(("num_ctx" . 32768))))
    (setopt ellama-coding-provider
              (make-llm-ollama
               :chat-model "qwen2.5-coder:3b"
               :embedding-model "nomic-embed-text"
               :default-chat-non-standard-params '(("num_ctx" . 32768))))
    ;; Predefined llm providers for interactive switching.
    ;; You shouldn't add ollama providers here - it can be selected interactively
    ;; without it. It is just example.
    (setopt ellama-providers
              '(("zephyr" . (make-llm-ollama
                             :chat-model "zephyr:7b-beta-q6_K"
                             :embedding-model "zephyr:7b-beta-q6_K"))
                ("mistral" . (make-llm-ollama
                              :chat-model "mistral:7b-instruct-v0.2-q6_K"
                              :embedding-model "mistral:7b-instruct-v0.2-q6_K"))
                ("mixtral" . (make-llm-ollama
                              :chat-model "mixtral:8x7b-instruct-v0.1-q3_K_M-4k"
                              :embedding-model "mixtral:8x7b-instruct-v0.1-q3_K_M-4k"))))
    ;; Naming new sessions with llm
    (setopt ellama-naming-provider
              (make-llm-ollama
               :chat-model "llama3:8b-instruct-q8_0"
               :embedding-model "nomic-embed-text"
               :default-chat-non-standard-params '(("stop" . ("\n")))))
    (setopt ellama-naming-scheme 'ellama-generate-name-by-llm)
    ;; Translation llm provider
    (setopt ellama-translation-provider
            (make-llm-ollama
             :chat-model "qwen2.5:3b"
             :embedding-model "nomic-embed-text"
             :default-chat-non-standard-params
             '(("num_ctx" . 32768))))
    ;; customize display buffer behaviour
    ;; see ~(info "(elisp) Buffer Display Action Functions")~
    (setopt ellama-chat-display-action-function #'display-buffer-full-frame)
    (setopt ellama-instant-display-action-function #'display-buffer-at-bottom)
    :config
    ;; send last message in chat buffer with C-c C-c
    (add-hook 'org-ctrl-c-ctrl-c-hook #'ellama-chat-send-last-message))




                                        ;(use-package lsp-jedi  :ensure t)

(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
;; Sample jar configuration
(setq plantuml-jar-path "/usr/share/plantuml/plantuml.jar")
(setq plantuml-default-exec-mode 'jar)
(setq plantuml-output-type "png")


(require 'server)
(unless (server-running-p) (server-start))
(require 'kanban)
(require 'iedit)

(require 'xcscope)
(setq cscope-program "gtags-cscope")
(cscope-setup)

(global-set-key (kbd "M-o") 'ff-find-other-file)

(require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))

(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)


;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)
(add-hook 'json-mode-hook 'lsp)
(add-hook 'python-mode-hook 'lsp)

(require 'yaml-mode)
;(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yplsm\\'" . yaml-mode))
(add-hook 'yaml-mode-hook 'lsp)



(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast



(defun esy/json-path-to-position (pos)
  "Return the JSON path from the document's root to the element at POS.

The path is represented as a list of strings and integers,
corresponding to the object keys and array indices that lead from
the root to the element at POS."
  (named-let loop ((node (treesit-node-at pos)) (acc nil))
    (if-let ((parent (treesit-parent-until
                      node
                      (lambda (n)
                        (member (treesit-node-type n)
                                '("pair" "array"))))))
        (loop parent
              (cons
               (pcase (treesit-node-type parent)
                 ("pair"
                  (treesit-node-text
                   (treesit-node-child (treesit-node-child parent 0) 1) t))
                 ("array"
                  (named-let check ((i 1))
                    (if (< pos (treesit-node-end (treesit-node-child parent i)))
                        (/ (1- i) 2)
                      (check (+ i 2))))))
               acc))
      acc)))

(defun esy/json-path-at-point (point &optional kill)
  "Display the JSON path at POINT.  When KILL is non-nil, kill it too.

Interactively, POINT is point and KILL is the prefix argument."
  (interactive "d\nP" json-ts-mode)
  (let ((path (mapconcat (lambda (o) (format "%s" o))
                         (esy/json-path-to-position point)
                         ".")))
    (if kill
        (progn (kill-new path) (message "Copied: %s" path))
      (message path))
    path))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))



(c-add-style "my-cc-style"
              '("gnu"
                (c-offsets-alist
                 (inline-open . 0)      
                 (block-open  . 0)      
                 (innamespace . 0)      
                 (substatement-open . 0)
                 (innamespace . [0]))))

;; (defconst my-cc-style
;;   '("cc-mode"
;;     (c-offsets-alist . (
;;                         (
;;                         (inline-open . 0)      
;;                         (block-open  . 0)      
;;                         (innamespace . 0)      
;;                         (substatement-open . 0)
;;                         (innamespace . [0]))))))

;; (c-add-style "my-cc-style" my-cc-style)
(add-hook 'c++-mode-hook (lambda () (c-set-style "my-cc-style") ))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++23")))

;(setq lsp-inlay-hint-enable t)
;(lsp-inlay-hints-mode)

(global-set-key (kbd "C-z") 'yank)


(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-cpptools)
  (yas-global-mode))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(compile-command "conan build .. -bf . -sf ..")
 '(cscope-option-do-not-update-database t)
 '(custom-enabled-themes '(sanityinc-tomorrow-blue))
 '(custom-safe-themes
   '("04aa1c3ccaee1cc2b93b246c6fbcd597f7e6832a97aaeac7e5891e6863236f9f" "76ddb2e196c6ba8f380c23d169cf2c8f561fd2013ad54b987c516d3cabc00216" default))
 '(ediff-split-window-function 'split-window-horizontally)
 '(flycheck-cppcheck-standards '("c++23"))
 '(ignored-local-variable-values
   '((eval setq flycheck-clang-include-path
           (list
            (concat
             (file-name-directory
              (or load-file-name buffer-file-name))
             "../../")))
     (company-clang-arguments "-Id:/sb/fast_dev/prg_fw_fast/fast/recipes/WaitingForCnf/FAST_VAR_PC_I386_WIN32_MINGW" "-Id:/sb/fast_dev/prg_fw_fast/" "-DFAST_VAR_SUA_E500MC_OSE" "-DFLYCHECK")
     (eval setq flycheck-clang-include-path
           (list
            (concat
             (file-name-directory
              (or load-file-name buffer-file-name))
             "../../")
            (concat
             (file-name-directory
              (or load-file-name buffer-file-name))
             "../../workdir/InterfaceGen")))))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(lsp-clients-clangd-args '("--header-insertion-decorators=0"))
 '(lsp-copilot-enabled nil)
 '(lsp-enable-on-type-formatting nil)
 '(lsp-inlay-hint-enable t)
 '(lsp-keymap-prefix "C-c C-l")
 '(magit-ediff-dwim-show-on-hunks t)
 '(package-selected-packages
   '(nhexl-mode ox-gfm ox-ioslide org-tree-slide ox-html5slide w3m lsp-java lsp-mode yasnippet lsp-treemacs helm-lsp projectile hydra flycheck company avy which-key helm-xref dap-mode color-theme-sanityinc-tomorrow xcscope iedit kanban elmacro yaml-mode json-mode magit magit-gitlab magit-gptcommit llm lsp-jedi yafolding))
 '(split-width-threshold nil)
 '(tool-bar-mode nil)
 '(warning-suppress-log-types '((comp))))
;(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
; '(default ((t (:family "Terminus" :foundry "xos4" :slant normal :weight normal :height ;169 :width normal)))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Hack" :foundry "SRC" :slant normal :weight regular :height 139 :width normal))))
 '(lsp-ui-sideline-current-symbol ((((background light)) (:background "medium blue" :foreground "black" :height 0.99)) (t (:background "medium blue" :foreground "white" :height 0.99))))
 '(lsp-ui-sideline-symbol ((t (:background "medium blue" :foreground "grey" :height 0.99))))
 '(lsp-ui-sideline-symbol-info ((t (:height 0.99)))))


