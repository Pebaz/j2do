"""
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
"""

import sys

if __name__ == '__main__':
    __doc__ = __doc__.format(sys.argv[0])
else:
    __doc__ = __doc__.format("iso.py")

from docopt import docopt

result = docopt(__doc__)

print(result)
