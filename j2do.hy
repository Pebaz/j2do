"
j2do - Use Jinja2 Templates from the Command Line!

Usage:
    {0} <template> [--out=<outfile>] [--include=<dir>]... <key-value-pairs>...
    {0} <template> [--out=<outfile>] [--include=<dir>]... (--json | --yml | --kv) [-]
    {0} <template> [--out=<outfile>] [--include=<dir>]... (--json | --yml) <answer-file>
    {0} <template> [--out=<outfile>] [--include=<dir>]... --env
    {0} -t <template-string> [--out=<outfile>] <key-value-pairs>...
    {0} -t <template-string> [--out=<outfile>] (--json | --yml | --kv) [-]
    {0} -t <template-string> [--out=<outfile>] (--json | --yml) <answer-file>
    {0} -t <template-string> [--out=<outfile>] --env

Options:
    -h --help        Show this screen.
    -t               Use inline template as string.
    --out=<outfile>  Write output to file instead of printing to stdout.
    --include=<dir>  Add a directory to search for templates.
	--env            Read key value pairs from environment variables (e.g.
                         `$env:j2_name = "'Pebaz'"`)

Notes:
    Please note that environment variable names will be passed to the template
	with only lowercase letters. This is done to normalize what is passed to
	the template no matter what the shell decides to do.


[✔] Docopt Parser
[✔] Finalize `name=value` syntax (looping?)
[✔] Get template string from CLI
[✔] Use as library
[✔] Built-in color variables (passed to render func)
"

(import sys)  ;; Command line arguments
(import os)  ;; Environment variables
(import [tempfile [NamedTemporaryFile :as TmpFile]])
(import [pathlib [Path]])
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

	Args:
		include(list): a list of string paths to folders that have templates.
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
	
	(if (get cmd-args "<template>")
		(setv template (get cmd-args "<template>"))

		;; If template string is used, we need to store it in a file because
		;; `j2do()` expects a filename.
		[(setv tmp-file (TmpFile "w" :delete False))
			(tmp-file.file.write (get cmd-args "<template-string>"))
			(tmp-file.close)
			(print tmp-file.name)
			(setv template tmp-file.name)])

	(setv outfile (get cmd-args "--out"))
	(setv includes (get cmd-args "--include"))

	;; Determine where to get the data

	(if (get cmd-args "-") [
			;; Get data from stdin
		]
		(get cmd-args "<answer-file>") [
			;; Use the answer file (json, yml)
		]
		(get cmd-args "--env") [
			;; Get the key-value pairs from shell environment
			;; { i.lower().split('j2_')[1] : os.environ[i] for i in os.environ if i.lower().startswith('j2_') }
			(setv data
				(dfor evar os.environ
					:if (.startswith (evar.lower) "j2_")
					[(get (.split (evar.lower) "j2_") 1)
					(get os.environ evar)]))
		]

		(get cmd-args "<key-value-pairs>") [
			;; Get the key-value pairs from the command line arguments
			(setv data
				(dfor kv (get cmd-args "<key-value-pairs>") [
					(get (kv.split "=") 0)
					(parse-datatype (get (kv.split "=") 1))]))
		])

	(print data)
	(exit)

	;; ------------>
	;; Get the key-value pairs from the command line
	(setv data
		(dfor arg (cut args 2) [
			(get (arg.split "=") 0)
			(parse-datatype (get (arg.split "=") 1))]))
	;; <-----------

	;; Add terminal color constants for use within templates
	(setv term-colors
		(dfor color all-term-colors [
			color
			(get (globals) color)]))

	;; Combine the two datasets into one dictionary
	(setv all-data (dict
		(unpack-mapping data)
		(unpack-mapping term-colors)))

	(j2do template all-data outfile includes)

	;; Delete the temp file (if it exists)
	(if tmp-file
		(.unlink (Path template)))

    (return 0))


(if (= __name__ "__main__")
    (.exit sys (main sys.argv)))
