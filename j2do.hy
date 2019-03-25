"
Docopt arguments go here.

[ ] Docopt Parser
[ ] Finalize `name=value` syntax (looping?)
[ ] Get template string from CLI
[ ] Use as library
[ ] Built-in color variables (passed to render func)
"

(import [builtins [eval :as parse-datatype]])  ;; Python object from string
(import sys)  ;; Command line arguments
(import jinja2)  ;; Templating engine
(import docopt)  ;; CLI Framework
(import [term-colors [*]])  ;; Terminal colors
(import [term-colors [__all__ :as all-term-colors]])  ;; Color names


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
