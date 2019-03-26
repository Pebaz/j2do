"""
Usage:
pip install git+https://github.com/Pebaz/j2do.git
"""

from setuptools import setup, find_packages

setup(
	name='j2do',
	version='0.1',
	description='Use Jinja2 templates from the command line!',
	author='http://github.com/Pebaz',
	license='GPL-3.0',
	packages=find_packages(),
	install_requires=[
		'jinja2==2.10',
		'docopt==0.6.2',
		'hy==0.16.0',
		'pyaml==18.11.0',
		'colorama==0.4.0'
	],
	scripts=['j2do.bat', 'j2do.sh']
)
