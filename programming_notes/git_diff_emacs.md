# Using process substitution to view git diffs in Emacs

Suppose you want to inspect the output of `git diff` inside Emacs.

Your first instinct might be:

```shell
git diff | emacs -
```

Reasonable guess.

After all POSIX has a utility syntax guideline saying that, for utilities whose operands are files, "`-`" should mean standard input (or standard output when used as an output file).

This is only a convention. A fine old Unix convention, yes, but still a convention: **each program must implement it**.

And Emacs does not play along here. It treats `-` as a filename or command-line option, not as "please read from stdin".

So, in the traditional way, you check the Emacs man page and find:

```
--insert=file
        Insert contents of file into the current buffer.
```

and, remembering some old Unix lore:

```shell
git diff | emacs --insert /dev/stdin
```

This works, the diff is inserted into an Emacs buffer... but Emacs may not automatically enable `diff-mode`. So we can force it:

```shell
git diff | emacs --insert /dev/stdin --eval '(diff-mode)'
```

Not bad. A little verbose, perhaps.

There is another way: avoid `stdin` entirely and use _process substitution_ (available in Bash or Zsh):

```shell
emacs <(git diff) --eval '(diff-mode)'
```

The `<(...)` syntax tells the shell to run the command inside the parentheses, make its output available through a temporary file-like path and pass that path as an argument to `emacs`.

In other words, Emacs sees something file-shaped.

That's the trick.

It's different from a pipe:

```shell
git diff | emacs
```

With a pipe, `git diff` is connected to Emacs' standard input. As noted Emacs doesn't use `stdin` as a file argument in the way tools like `cat`, `grep` or `less` do.

With process substitution, Emacs sees a filename, so it can open it normally.

Of course process substitution is a handy toy:

```shell
diff <(sort old.txt) <(sort new.txt)
```

Here, both sort commands produce file-like streams, and `diff` compares them as if they were real files.