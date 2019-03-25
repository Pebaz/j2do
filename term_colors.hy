"
A collection of constants for use in making the usage of terminal coloring as
simple as possible.
"

(import colorama)

;; Initialize Colorama to work with Windows
(colorama.init :convert True)

;; Foreground Colors
(setv _CLRfbl colorama.Fore.BLACK)
(setv _CLRfr colorama.Fore.RED)
(setv _CLRfg colorama.Fore.GREEN)
(setv _CLRfy colorama.Fore.YELLOW)
(setv _CLRfb colorama.Fore.BLUE)
(setv _CLRfm colorama.Fore.MAGENTA)
(setv _CLRfc colorama.Fore.CYAN)
(setv _CLRfw colorama.Fore.WHITE)
(setv _CLRfreset colorama.Fore.RESET)

;; Background Colors
(setv _CLRbbl colorama.Back.BLACK)
(setv _CLRbr colorama.Back.RED)
(setv _CLRbg colorama.Back.GREEN)
(setv _CLRby colorama.Back.YELLOW)
(setv _CLRbb colorama.Back.BLUE)
(setv _CLRbm colorama.Back.MAGENTA)
(setv _CLRbc colorama.Back.CYAN)
(setv _CLRbw colorama.Back.WHITE)
(setv _CLRbreset colorama.Back.RESET)

;; Styles
(setv _CLRreset colorama.Style.RESET_ALL)

;; Control `from` imports
(setv __all__ [])
(for [i (dir)] [
	(if (i.startswith "_CLR")
		(__all__.append i))])
