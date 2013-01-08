# auto-complete-c-headers

An auto-complete source for C/C++ header files.

![screenshot](https://raw.github.com/mooz/auto-complete-c-headers/images/screenshot.png "Completing project-specific header files")

## Setup

```lisp
(defun my:ac-c-headers-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers))

(add-hook 'c++-mode-hook 'my:ac-c-headers-init)
(add-hook 'c-mode-hook 'my:ac-c-headers-init)
```

## Customizing

See docstrings of `achead:include-directories` and `achead:get-include-directories-function`.
