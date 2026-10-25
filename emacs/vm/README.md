# Emacs VM (View Mail) for GNU Emacs

Added reference for the Emacs mail reader VM (a.k.a. ViewMail).

## Source

- Official: https://gitlab.com/emacs-vm/vm
- GitHub mirror: https://github.com/emacsmirror/vm
- NonGNU ELPA: `M-x package-install RET vm RET`

## What it is

VM is a mail reader that runs inside GNU Emacs. Written by Kyle Jones as an alternative to RMAIL. It supports:

- POP and IMAP (non-blocking)
- MIME with inline and external display
- Standard UNIX mbox and BABYL folders
- Virtual folders for searching across folders
- HTML mail via shr
- PGP via EasyPG
- Emacs 28.1 or later

## Install

From NonGNU ELPA (recommended):

```
M-x package-install RET vm RET
```

Or from source:

```bash
git clone https://gitlab.com/emacs-vm/vm.git
cd vm
# follow INSTALL.md
```

Minimal `.emacs` setup:

```elisp
(require 'vm-autoloads)
(setq vm-primary-inbox "~/mail/inbox")
(setq vm-folder-directory "~/mail/")
```

## Notes

This directory holds the reference and integration notes for OpenGrok. The full VM sources remain upstream (GPL). To vendor the full tree, add it as a submodule:

```bash
git submodule add https://gitlab.com/emacs-vm/vm.git emacs/vm/upstream
```
