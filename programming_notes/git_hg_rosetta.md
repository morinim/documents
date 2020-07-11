# Git equivalents of most common Mercurial commands

Since many of our projects were once stored in Mercurial repositories, we found useful a [git-hg Rosetta stone](https://github.com/sympy/sympy/wiki/Git-hg-rosetta-stone):

- `hg clone` -> `git clone`
- `hg diff` ->
  * `git diff` shows unstaged changes
  * `git diff --cached` shows staged changes
  * `git diff HEAD` shows all changes (both staged and unstaged)
`git diff HEAD`
- `hg diff -r A:B` -> `hg diff A B`
- `hg status` -> `git status`
- `hg manifest` -> `git ls-tree -r --name-only --full-tree HEAD`
- `hg commit` -> `git add ; git commit` or `git commit -a`
- `hg view` -> `gitk` and `git gui`
- `hg log` -> `git log`
- `hg add` -> `git add`
- `hg push` -> `git push`
- `hg pull ; hg update` -> `git pull`
- `hg update tip` -> `git checkout HEAD`
- `hg merge` -> `git merge`
- `hg revert filename` -> `git checkout filename` (`git checkout -- .` for everything in the current directory)
- `hg backout` -> `git revert`
- `hg rollback` -> `git reset --soft HEAD^`. With git you may actually prefer to use `--amend`, e.g.:
  * `git commit "Fixed #123"`
  * remembered that I forgot to do something
  * do something
  * `git commit --amend` and edit the notes
- `hg rm` / `hg mv` -> `git rm` / `git mv`
- `hg addremove` -> `git add -A`
- `.hgrc` -> `.gitconfig`
- `.hgignore` -> `.gitignore`
