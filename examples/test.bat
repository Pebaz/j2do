:: Main use case - Use j2do from CLI with key-value pairs
j2do -t "Hello {{name}}!" name="'Pebaz'"

:: Test Key-Value pairs passed directly
j2do temp.j2 times=3 name="'Pebaz'"

:: Test JSON from answer file
j2do temp.j2 --json test.json

:: Test YAML from answer file
j2do temp.j2 --yml test.yml

:: Test text file pairs from answer file
j2do temp.j2 --kv test.txt

:: Test JSON from STDIN
type test.json | j2do temp.j2 --json -

:: Test YAML from STDIN
type test.yml | j2do temp.j2 --yml -

:: Test text file pairs from STDIN
type test.txt | j2do temp.j2 --kv -

:: Test KV pairs from environment variables
set j2_name="'Pebaz'"
set j2_times=3
j2do temp.j2 --env

:: Use j2do with jq
type test.json | jq | j2do temp.j2 --json -
