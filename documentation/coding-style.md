# Coding Style

## General rules

- [x] POSIX compliant
- [x] No bash
- [x] Must work on busybox

## Variable naming

- [x] ALWAYS lowercase
- [x] Since local does not exist, use the following convention: file_firstletteroffuntion_variable (exeample: in `time.sh` with `diff_timestamp` function, a variable shuold be `time_dt_foo="$1"`).

## Documentation

The CI won't pass if function doesn't have the following conventions.

### Function with arguments

```
## /author [[author]]
## /desc A short description of the function
## /usage function_name <foo>(type) [bar](type)
## ## /param <foo> (type) A brief description of a MANDATORY foo parameter
## ## /param [bar] (type) A brief description of an OPTIONAL bar parameter
## /return (type) Description of the value returned
```

### Function without arguments

```
## /author [[author]]
## /desc A short description of the function
## /usage function_name <foo>(type) [bar](type)
## /return (type) Description of the value returned
```

### About the /author

It strictly recommanded that you leave it as it is, a placeholder:
```
/author [[author]]
```
First, pre-commit hook will copy your `.env.local` to `.env`.

Then, pre-commit hook will replace `[[author]]` occurence by informations you put in your .env.local file.

At least, you nickname will be used, except if you're using root, then I'll think later about merge requests stuff.


## Advices
 - [x] On local variables in functions, you can reinitialize them but it's not mandatory
