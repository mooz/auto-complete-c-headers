EMACS=emacs

all: byte-compile

byte-compile:
	${EMACS} -Q -L . -batch -f batch-byte-compile auto-complete-c-headers.el

clean:
	rm -f *.elc
