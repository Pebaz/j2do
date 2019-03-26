"
j2do - Use Jinja2 Templates from the Command Line!

Usage:
    {0} <template> [--out=<outfile>] [--include=<dir>]... [<key-value-pairs>...]
    {0} <template> [--out=<outfile>] [--include=<dir>]... (--json | --yml | --env) [-]
    {0} <template> [--out=<outfile>] [--include=<dir>]... (--json | --yml | --env) <answer-file>
    {0} -t <template-string> [--out=<outfile>] [<key-value-pairs>...]
    {0} -t <template-string> [--out=<outfile>] (--json | --yml | --env) [-]
    {0} -t <template-string> [--out=<outfile>] (--json | --yml | --env) <answer-file>

Options:
    -h --help  Show this screen.
    -t  Use inline template as string.
    --out=<outfile>
    --include=<dir>


[ ] Docopt Parser
[ ] Finalize `name=value` syntax (looping?)
[ ] Get template string from CLI
[ ] Use as library
[ ] Built-in color variables (passed to render func)
"

(import sys)  ;; Command line arguments
(import [builtins [eval :as parse-datatype]])  ;; Python object from string
(import jinja2)  ;; Templating engine
(import [docopt [docopt]])  ;; CLI Framework
(import [term-colors [*]])  ;; Terminal colors
(import [term-colors [__all__ :as all-term-colors]])  ;; Color names


;; Make sure that the right script/executable name is showing in the docstring
(if (= __name__ "__main__")
	(setv __doc__ (__doc__.format (get sys.argv 0)))
	(setv __doc__ (__doc__.format "j2do.hy")))


(defn j2do [template data &optional outfile [include "."]]
	"
	Map a given template with the given names.
	"
	(setv env (jinja2.Environment :loader (jinja2.FileSystemLoader include)))
	(setv template (env.get-template template))
	(setv output (template.render (unpack-mapping data)))

	(if outfile
		(with [file (open outfile)]
			(file.write output))
		(print output)))


(defn main [args]
	"
	THIS IS SOME TEXT! 😁
	"
	(setv cmd-args (docopt __doc__))
	(print cmd-args)
	(exit)

	(if (= (len args) 0)
		(print "j2do - Jinja2 template quick replace command line tool."))

	(setv env (jinja2.Environment :loader (jinja2.FileSystemLoader ".")))

	;; Currently args = ['j2do.hy', './some-template.j2']
	(setv template (env.get-template (get args 1)))

	(setv data
		(dfor arg (cut args 2) [
			(get (arg.split "=") 0)
			(parse-datatype (get (arg.split "=") 1))]))

	(setv term-colors
		(dfor color all-term-colors [
			color
			(get (globals) color)]))

	; (print (template.render
	; 	(unpack-mapping data)
	; 	(unpack-mapping term-colors)))

	(setv all-data (dict
		(unpack-mapping data)
		(unpack-mapping term-colors)))

	(j2do template all-data :include ".")

    (return 0))


(if (= __name__ "__main__")
    (.exit sys (main sys.argv)))
