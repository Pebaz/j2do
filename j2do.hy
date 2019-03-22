"
Docopt arguments go here.
"

(import sys)


(defn main [args]
    (print "j2do - Jinja2 template quick replace command line tool.")
    (return 0))


(if (= __name__ "__main__")
    (.exit sys (main sys.argv)))