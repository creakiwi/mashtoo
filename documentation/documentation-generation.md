# Documentation Generation

I had to decide how to generate documentation, and find a pattern.

What I came up with is:
```
## /word smoething
```

## Evaluated documentation and wordings

There is no specific orders for the documentation. I will think about it later when working on it.

Just, be logic about arguments orders.

## The function example

I'll use the following function to document the specific documentation I'll use:
```
slugify() {
  string_l_messsage="$1"
  string_l_separator="${2:--}"
  lowercase_msg=$(tr '[:upper:]' '[:lower:]' <<< "$string_l_message")
  result=$(sed -e "s/[^a-z0-9]\{1,\}/${string_l_separator}/g" -e "s/^${string_l_separator}\|${string_l_separator}$//g" <<< "$string_lower")

  printf '%s\n' "$result"
}
```

## Mandatory documentation

Without mandatory documentation of a function, the CI won't pass at all.

### /author

This one is particulary important, I don't like git blame. I don't like how symfony handle it at top of files either.
POSIX shell is totally different of other languages, I had to find a way to handle it.

The best way I found was to put a placeholder for the author.
You don't have to think about anything, just copy paste the example below.

#### Usage example
```
## /author [[author]]
```
At pre-commit hook, it will replace the placeholder with something like this (if your .env.local file is fully completed):
```
## /author Alex Ception (alexandre@creakiwi.com) [https://github.com/alex-ception]
```

#### Explaination

Every [[word]] in documentation section is a placeholder.
In the case of author, it will use your .env.local file.
If you didn't fill it, it will only use the current Linux user.
But you can specify an email address if you want and/or a github nickame (no need to pass the full url).

### /desc

/desc stands for description. It is a short description of the function.

#### Usage example
```
## /desc This function slugify a string.
```

### /usage

This should explain how to use the function. If it has mandatory and/or optional parameters.

#### Usage example
```
## /usage slugify <message>(string) [separator](string)
```


### /return

It should explain what the function returns and it's type.

#### Usage example
```
## /return (string) The slugified message.
```
## Optional documentation

The CI won't cry if those bash documentation types are not present.

### /param

> [!IMPORTANT]
> In this function the signature has mandatory and optional parameters. So in this case, the CI will complain about it.

This explains a mandatory or optional parameter with it's type.

`<foo>` stands for mandatory parameter.

`[bar]` stands for optional parameter.

#### Usage example
```
## /param <message>(string) The message to slugify.
## /param [separator](string) The separator to use [default value: -].
```

### /todo

Should I explain what this do ?

#### Usage example
```
## /todo Add a test for this function.
```

### /note

> This is a note, when you have something to say.

### /posix

I put `/posix` documentation when I see at first glance it does respect POSIX pure shell.

### /unposix

I put `/unposix` documentation when I see at first glance it does not respect POSIX pure shell.
