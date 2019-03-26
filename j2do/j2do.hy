"
j2do - Use Jinja2 Templates from the Command Line!

Usage:
    {0} <template> [--out=<outfile>] [--include=<dir>]... <key-value-pairs>...
    {0} <template> [--out=<outfile>] [--include=<dir>]... (--json | --yml | --kv) [-]
    {0} <template> [--out=<outfile>] [--include=<dir>]... (--json | --yml | --kv) <answer-file>
    {0} <template> [--out=<outfile>] [--include=<dir>]... --env
    {0} -t <template-string> [--out=<outfile>] <key-value-pairs>...
    {0} -t <template-string> [--out=<outfile>] (--json | --yml | --kv) [-]
    {0} -t <template-string> [--out=<outfile>] (--json | --yml | --kv) <answer-file>
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

[✔] Remove print
[✔] Verify use as library
[✔] Document each function
[ ] Reference Jinja2 documentation
[ ] Document included colors
[ ] Setup script
[ ] Command script .sh: hy j2do.hy %*
"

(import sys)  ;; Command line arguments
(import os)  ;; Environment variables
(import json)  ;; JSON Parser
(import [tempfile [NamedTemporaryFile :as TmpFile]])  ;; Temporary files
(import [pathlib [Path]])  ;; TmpFile deletion after use
(import [builtins [eval :as parse-datatype]])  ;; Python object from string
(import yaml)  ;; YAML Parser
(import jinja2)  ;; Templating engine
(import [docopt [docopt]])  ;; CLI Framework
(import [term-colors [*]])  ;; Terminal colors
(import [term-colors [__all__ :as all-term-colors]])  ;; Color names


;; Make sure that the right script/executable name is showing in the docstring
(if (= __name__ "__main__")
	(setv __doc__ (__doc__.format (get sys.argv 0)))
	(setv __doc__ (__doc__.format "j2do.hy")))

;; Control from imports
(setv __all__ ["j2do"])


(defn j2do [template data &optional outfile [include "."]]
	"
	Use Jinja2 to process a template filename with a set of key-value pairs.

	Template is a filename, not the file's contents. Values within the data
	variable can be nested like JSON and referenced easily within a template.
	A list of directory search paths can be provided so that templates can
	reference each other easily.

	Args:
		template(str): the path to the template file (`.j2`).
		data(dict): key-value pairs to map to names within template.
		outfile(str): the filename that should contain the rendered template.
		include(list): a list of string paths to folders that have templates.

	Returns:
		A string containing the rendered template text.
	"
	(setv env (jinja2.Environment :loader (jinja2.FileSystemLoader include)))
	(setv template (env.get-template template))
	(setv output (template.render (unpack-mapping data)))

	(if outfile
		(with [file (open outfile "w")]
			(file.write output))
		(return output)))


(defn parse-kv [collection]
	"
	Takes a list of keys/values separated by `=` and adds them to dictionary.

	Expects this data structure:
	```
	[
		'name=\"'Pebaz'\",
		'age=24'
	]
	```
	And turns it into this data structure:
	```
	{
		'name' : '\"Pebaz\"',
		'age' : 24
	}
	```
	Values are parsed by using the `eval` function to obtain a valid Python
	object. Note that this could be considered a security concern if j2do is
	being used on a server, etc.

	Args:
		collection(list): a list of strings containing key-value pairs.

	Returns:
		A Python dictionary containing the key-value pairs.
	"
	(return (dfor kv collection [
		(get (kv.split "=") 0)
		(parse-datatype (get (kv.split "=") 1))])))


(defn main [args]
	"
	Reads command line parameters from Docopt and passes them to `j2do()`.

	Utilizes the appropriate parser necessary to convert the key-value pairs
	from different data sources into a dictionary that Jinja2 understands.

	Args:
		args(list): the command line arguments.

	Returns:
		An integer return code.
	"
	(setv cmd-args (docopt __doc__))
	
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
	(if (= (len includes) 0)
		(setv includes ["."]))

	;; Determine where to get the data

	(if
		(get cmd-args "-") [
			;; Get data from stdin
			(setv lines (lfor line sys.stdin (line.strip)))
			(setv text (.join "\n" lines))

			(if (get cmd-args "--json") (setv data (json.loads text))
				(get cmd-args "--yml") (setv data (yaml.load text))
				(get cmd-args "--kv") (setv data (parse-kv lines)))]

		(get cmd-args "<answer-file>") [
			;; Use the answer file (json, yml)
			(setv lines
				(lfor i (.readlines (open (get cmd-args "<answer-file>")))
					(i.strip)))
			(setv text (.join "\n" lines))

			(if (get cmd-args "--json") (setv data (json.loads text))
				(get cmd-args "--yml") (setv data (yaml.load text))
				(get cmd-args "--kv") (setv data (parse-kv lines)))]

		(get cmd-args "--env") [
			;; Get the key-value pairs from shell environment
			(setv data
				(dfor evar os.environ
					:if (.startswith (evar.lower) "j2_")
					[(get (.split (evar.lower) "j2_") 1)
					(get os.environ evar)]))]

		(get cmd-args "<key-value-pairs>")
			;; Get the key-value pairs from the command line arguments
			(setv data (parse-kv (get cmd-args "<key-value-pairs>"))))

	;; Add terminal color constants for use within templates
	(setv term-colors
		(dfor color all-term-colors [
			color
			(get (globals) color)]))

	;; Combine the two datasets into one dictionary
	(setv all-data (dict
		(unpack-mapping data)
		(unpack-mapping term-colors)))

	(print (j2do template all-data outfile includes))

	;; Delete the temp file (if it exists)
	(if (in "tmp_file" (locals))
		(.unlink (Path template)))

    (return 0))


(if (= __name__ "__main__")
    (.exit sys (main sys.argv)))
