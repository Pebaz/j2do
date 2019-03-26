# J2DO

The point of this project boils down to two things:

* [Hy](http://docs.hylang.org/en/stable/) is *amazingly* cool.
* [Jinja2](<http://jinja.pocoo.org/>) is *beautiful* and *extremely useful*.

I want to use Jinja2 from the command line and I'm sure others have wanted the same thing.  Sometimes you just want to write a super simple template really quick and pipe values to it from the command line.  **J2DO** is that tool.  Now you can use Jinja2 templates inline or from `.j2` files and pipe or pump data to them from the command line.  In addition, [JQ](<https://stedolan.github.io/jq/>) is a fantastic partner to J2Do because you can use it to transform datasets from disparate programs into something that your Jinja2 template can understand.

## Installation

```bash
pip install git+https://github.com/Pebaz/j2do.git
```

## Usage

Example template file `scuttle.j2`:

```jinja2
{% for i in range(times) %}
    Hello {{ name }}!
{% endfor %}
```

Render this template with command line arguments:

```bash
j2do scuttle.j2 name="'Pebaz'" times=3
```

Render this template with JSON input:

```json
{
    "name" : "Yelbu",
    "times" : 3
}
```

```sh
j2do scuttle.j2 --json answers.json
```

Render this template with YAML input:

```yaml
name: "Nodibu"
times: 3
```

```sh
j2do scuttle.j2 --yml answers.yml
```

Render this template with a text file containing key-value pairs:

```ini
name="Protodip"
times=3
```

```bash
j2do scuttle.j2 --kv answers.txt
```

Process a given template with Environment Variable input:

```sh
set j2_name="'Pebaz'"
set j2_times=3
j2do scuttle.j2 --env
```

Process a given template with STDIN input:

```bash
cat answers.yml | j2do scuttle.j2 --yml -
cat answers.json | j2do scuttle.j2 --json -
cat answers.txt | j2do scuttle.j2 --kv -
```

Use JQ along with J2DO:

```json
{
    "name" : "Yelbu",
    "times" : 3,
    "extra" : "not used"
}
```

```bash
cat answers.json | jq "del(.extra)" | j2do scuttle.j2 --json -
```

Use J2DO as a library:

```python
from j2do import j2do

data = {"name" : "'Pebaz'", "times" : 3}

out = j2do(
    template="mytemplate.j2",   # Template to load
    data=data,                  # Data to pass to template
    include=["templates"],      # Where to find templates (accepts list)
    outfile=None                # Return text don't output file (defaults to None)
)

print(out)
```

### Terminal Coloring Shortcuts

The template rendering environment comes preloaded with constants you can use to create more attractive terminal output.

```jinja2
Hello {{_CLRfg}}{{name}}{{_CLRreset}}!
```

This will output "Hello Pebaz!" to the screen with only the name "Pebaz" highlighted green.  Look into `term_colors.hy` for the list of possible colors.  Foreground and Background colors are supported.

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

* For another similar project, check out:  [J2CLI](https://github.com/kolypto/j2cli)

* The name `j2do` comes from `sudo` 😉

### TODO

- [ ] Make default syntax: `j2do "inline template" ...` and files: `j2do -f temp.j2 ...`