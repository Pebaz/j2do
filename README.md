# J2DO

**Educational project for learning the [Hy](http://docs.hylang.org/en/stable/) language, use [J2CLI](https://github.com/kolypto/j2cli) instead.**

*Description of project*

## Installation

```sh
pip install git+https://github.com/Pebaz/j2do.git
```

## Usage

Process a given template with command line arguments:

```bash
j2do scuttle.j2 name="'Pebaz'" badge_number=24 something-else=abc123
```

Process a given template with YAML input:

```sh
j2do scuttle.j2 --yml answers.yml
```

Process a given template with JSON input:

```sh
j2do scuttle.j2 --json answers.json
```

Process a given template with Environment Variable input:

```sh
set j2.name="'Pebaz'"
j2do scuttle.j2 --env
```

Process a given template with STDIN input

```sh

```

Features

1. Accept command line input via pipes: `mycommand | j2do mytemplate.j2`

2. Accept command line input via flag: `j2do mytemplate.j2 -i "this is content that needs to go in"`

3. Accept template files: `.j2`

4. Default behavior output to file: `j2do mytemplate.j2 -i "some content" >> outfile.html`

5. Specify output file with flag: `j2do mytemplate.j2 -i "some content" -o outfile.html`

6. Specify template include dir: `j2do`

7. Implement as library:

   ```python
   import j2do 					# J2DO library
   
   out = j2do.do(
       template="mytemplate.j2",	# Template to load
       include="templates",		# Where to find templates (accepts list)
   	content="some content", 	# Values to pass to template
   	outfile=None 				# Return text don't output file (defaults to None)
   )
   
   # Process `out` in some way
   ```

8. Name comes from Linux: sudo

## Notes

* When passing in parameters from the command line, values should be valid Python values.  Strings should be double-quoted because the terminal will strip them.

  ```bash
  # Work
  j2do scuttle.j2 name="'python understands this'"
  
  # Doesn't Work
  j2do scuttle.j2 name="but not this"
  
  # Example list
  j2do scuttle.j2 items="[1, 2, 'this is a string']"
  ```

