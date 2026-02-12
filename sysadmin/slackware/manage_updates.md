# From quick hacks to a reliable maintenance script

## Introduction

This script serves as a local repository maintenance tool. Since Slackware updates are downloaded and kept locally (due to `DELALL=off` in `slackpkg.conf`), the local package cache grows indefinitely. This script automates the cleanup of that cache by implementing a retention policy: it identifies and removes older versions of packages, ensuring that only the two most recent versions of any given package are kept in the local archive.

## How the Script Works

The script enforces a retention policy on the local package archive:
- **Version Control**. It scans the local package directory and groups files by package name;
- **Retention**. It identifies packages with multiple versions;
- **Cleanup**. It automatically deletes older versions, leaving only the **two most recent versions** of each package.

This ensures you always have the current version and the immediate previous version available for a quick downgrade/rollback if a bug is discovered, without allowing the archive to grow indefinitely.

### Prerequisites

- You must have `root` privileges (or use `sudo`) to move packages into the system's patch directory.
- `DELALL=off` in `/etc/slackpkg/slackpkg.conf`.

### The maintenance workflow

In a system configured with `DELALL=off` in `/etc/slackpkg/slackpkg.conf`, every package downloaded during an update is preserved in the local cache. Over time, this can consume significant disk space.

The standard update procedure follows this sequence:

1. `slackpkg update` - Fetch latest package lists.
2. `slackpkg upgrade-all` - Upgrade the system (packages are saved to cache).
3. `./manage_updates.sh` - Clean the cache.


If everything is ok:

```bash
~# ./manage_updates.sh --force
```


## Evolving a Slackware package cleanup script in Bash

Shell scripts often start life as pragmatic solutions to immediate problems. That was exactly the case here: two small scripts to manage [Slackware](http://www.slackware.com)'s package cache in `/var/cache`. They were short and they did the job (see https://www.linuxquestions.org/questions/slackware-14/today%27s-current-icu4c-upgrade-broke-ktown%27s-sddm-4175619108/page2.html): both scripts worked reliably for their intended purpose and were perfectly reasonable solutions at the time they were written.

Over time, however, they also revealed some natural limitations of scripts written to solve an immediate need: reliance on temporary files, assumptions that were implicit rather than enforced and limited safety mechanisms when running as root.

This document retraces the evolution from those initial scripts to a single, clear and safe maintenance tool. It also highlights the Bash features (and traps) encountered along the way.

## The starting point

We have two simple scripts.

The first is a one-line shortcut for archiving the package cache.

```bash
mv /var/cache/packages /var/cache/packages$(date +%Y%m%d)
```

This script does exactly one thing: after running `slackpkg`, it renames the packages directory to include the current date.

Simple and effective, but intentionally minimal: no diagnostics, no check for existing archives, no dry run and destructive by default.

The second script is more involved. It:

- scans `/var/cache` for `*.t?z` files;
- extracts package names and dates;
- sorts them;
- keeps the two newest versions;
- deletes the rest.

To achieve this, it relies heavily on temporary files in `/tmp`, fixed assumptions about path depth and long pipelines:

```bash
# Remove any old files
rm /tmp/list*

# Get a list of *.t?z archive files
find /var/cache -name "*.t?z" > /tmp/list1

# Get a list of package names without build, arch, version
cat /tmp/list1 | rev | cut -d"/" -f1 | cut -d"-" -f4- | rev > /tmp/list2

# Get a list of dates
cat /tmp/list1 | cut -d"/" -f4 | sed "s/packages//" > /tmp/list3

# Paste the lists together
paste /tmp/list1 /tmp/list2 /tmp/list3 > /tmp/list4

# Sort the list by package name then date(reverse order)
sort --key=2,3r /tmp/list4 > /tmp/list5

# Get a list of packages with 2 later versions
awk '++dups[$2] > 2' /tmp/list5 > /tmp/list6

# Cut the first column from the list
cut -f1 /tmp/list6 > /tmp/list7

# Delete the older files
while read line; do
  rm "$line"{,.asc}
done < /tmp/list7
```

While functional, this approach also comes with some trade-offs:

- intermediate state is scattered across `/tmp`;
- debugging requires inspecting many files;
- errors can silently propagate;
- readability suffers.

## Merge responsibilities

The first design decision was to merge the two scripts into one, but not to merge everything into a single pipeline.

Instead, the new script preserves the original logical phases:

- archive the current packages directory;
- collect package files;
- group and sort them;
- delete older versions.

Each step is labelled and produces diagnostic output.

This reflects an intentional design choice: the script is written for humans first, not for the shell.

## Dry run by default

One of the most important changes is this variable:

```bash
DRY_RUN=true
```

All destructive actions (`mv`, `rm`) are guarded:

```bash
if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY RUN] Would remove $file"
else
    rm -f "$file"
fi
```

This matters because the script runs as root and mistakes become visible before they become permanent.

The pattern is simple, explicit and far safer than trying to infer intent from flags later in the pipeline.

## Arrays instead of temporary files

The original cleanup script uses a chain of `/tmp/listN` files. This works, but it makes the data flow harder to follow.

The rewritten version replaces these files with Bash arrays:

```bash
package_list=()
sortable_list=()
to_remove=()
```

Arrays make the data flow explicit:

- `package_list`: all package files found;
- `sortable_list`: enriched records (path, name, date);
- `to_remove`: final deletion list.

This eliminates filesystem clutter, accidental reuse of stale temp files and the need to "mentally replay" pipelines.

## Letting `find` do the filtering

One subtle but important change is how `packages*` directories are discovered.

Instead of relying on shell globbing:

```shell
/var/cache/packages*
```

the script uses:

```bash
find "$CACHE_DIR" -maxdepth 1 -type d -name 'packages*'
```

This matters because shell globs expand before the command runs.

In Bash, patterns like `*`, `?` and `[...]` are expanded **by the shell itself**, _before_ any command is executed.

Example:

```shell
ls /var/cache/packages*
```

what actually happens is that Bash looks at the filesystem, replaces `/var/cache/packages*` with the list of matching paths and only then it runs `ls` with those paths as arguments.

If the filesystem contains:

```shell
/var/cache/packages20251229
/var/cache/packages20251230
```

the command becomes:

```shell
ls /var/cache/packages20251229 /var/cache/packages20251230
```

The command never sees the wildcard. So if _no_ path matches `/var/cache/packages*` Bash can left it unchanged ([no nullglob](https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html)):

```shell
ls /var/cache/packages*
```

`ls` is now invoked with a literal argument that does not exist, so it fails:

```shell
ls: cannot access '/var/cache/packages*': No such file or directory
```

Exit status is non-zero.

Bash could also expand to nothing (nullglob):

```shell
ls /var/cache/packages*
# becomes:
ls
```

This avoids the immediate failure, but introduces a different risk: commands may now run with missing argument and behaviour changes silently.

In system scripts, silent changes can be more dangerous than hard failures.

Letting `find` do the matching

```bash
find /var/cache -maxdepth 1 -type d -name 'packages*'
```

is better than the glob-based approach:

```bash
find /var/cache/packages* -maxdepth 1 -type d
```

The practical rule of thumb to remember is using shell globs interactively and try to avoid them in non-interactive scripts.

## Process substitution vs pipelines

One of the most instructive changes involves this pattern (our first implementation):

```bash
printf "%s\n" "${sortable_list[@]}" | while read -r line; do
    to_remove+=("$line")
done
```

At first glance this looks fine, but it doesn't behave as intended. In Bash each element of a pipeline runs in a subshell and variables modified inside the loop are lost.

The correct, explicit solution uses process substitution:

```bash
while read -r line; do
    to_remove+=("$line")
done < <(printf "%s\n" "${sortable_list[@]}" | sort | awk ...)
```

**Key lesson**: never modify variables you need later inside a loop fed by a pipe.

Process substitution keeps the loop in the current shell, preserving state.

## `set -e` and controlled failure

The final script enables:

```bash
set -euo pipefail
```

This ensures the script stops on unexpected errors but only because all commands that may legitimately produce no output are structured safely.

Moreover diagnostics make it clear what failed.

## Diagnostics over silence

Every major step prints what it's doing:

```bash
echo "==> Scanning package archives"
echo "==> Selecting old package versions"
echo "==> Removing old packages"
```

This turns the script into documentation, progress report and debugging aid.

Especially for system scripts, silence is not a virtue.

## Longer, clearer, safer

The final script is longer than the originals, deliberately so.

It loses clever compactness but gains:

- safety (dry run, root check),
- robustness (no globbing traps, no subshell surprises),
- clarity (linear flow, named phases),
- maintainability.

For scripts that run as root and manage system state, that's a very good trade.

**The original scripts did exactly what they were designed to do; this evolution simply reflects changing requirements, increased caution and the desire to make future maintenance easier and safer.
**
