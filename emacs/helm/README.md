# Helm for GNU Emacs

Added to the Emacs list alongside VM.

## Source

- Official: https://github.com/emacs-helm/helm
- MELPA / GNU ELPA: `M-x package-install RET helm RET`

## What it is

Helm is an Emacs incremental completion and selection narrowing framework. It provides a powerful alternative to the built-in `completing-read` and related interfaces, with fuzzy matching, multiple sources, actions, and a consistent UI across many Emacs commands.

Common uses:

- `helm-M-x` — enhanced execute-extended-command
- `helm-find-files` — file navigation
- `helm-buffers-list` — buffer switching
- `helm-occur` / `helm-ag` — searching
- `helm-imenu` — symbol navigation

## Install

```
M-x package-install RET helm RET
```

Minimal setup:

```elisp
(require 'helm)
(require 'helm-config)
(helm-mode 1)

(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(global-set-key (kbd "C-x b") #'helm-buffers-list)
```

## Notes

This directory holds the reference for OpenGrok. Full sources remain upstream. To vendor:

```bash
git submodule add https://github.com/emacs-helm/helm.git emacs/helm/upstream
```
