# Migrating from `virtualenv` to Python's native `venv`

## Goal

Minimise external tooling dependencies by replacing the third-party `virtualenv` tool with Python's standard-library `venv` module, while preserving the project's Python packages.

> **Note:** The activation command `source env/bin/activate` does not identify how the environment was created. Both `venv` and `virtualenv` use it.

## Identify the existing environment

```bash
cat env/pyvenv.cfg
```

Look for a `command` entry mentioning `python -m venv` or entries identifying `virtualenv`. If the environment already uses `venv`, there is no need to migrate.

## Export installed packages

From the project directory:

```sh
source env/bin/activate
python -m pip freeze > requirements.txt
deactivate
```

Review `requirements.txt`: `pip freeze` captures the installed package set, including transitive dependencies, rather than just your project's direct dependencies. If the project already maintains a dependency specification, prefer that as the source of truth.

## Create a native environment

Keep the old `env` directory until the new environment has been tested:

```sh
python3 -m venv .venv
source .venv/bin/activate
```
(you may first need to install the `python3-venv` system package)

Verify the interpreter:

```bash
python --version
python -c 'import sys; print(sys.executable)'
```

## Restore packages and test

```bash
python -m pip install -r requirements.txt
```

Run your application's tests, and update editor settings, scripts and service definitions that still reference `env/bin/python`.

## Remove the old environment

After confirming that the application works:

```bash
deactivate
rm -rf env
```

## Remove unnecessary tooling

If `virtualenv` was installed solely for this project, and nothing else uses it, uninstall it from the *installation where it was originally installed*. For example:

```bash
python3 -m pip uninstall virtualenv
```

Do not run this blindly against an OS-managed Python installation; use the relevant system package manager instead. Removing the old project's environment does **not** require uninstalling `virtualenv` system-wide.

## Dependency-minimisation notes

- `venv` is in the Python standard library: no separate `virtualenv` installation is needed.
- `pip` is usually bootstrapped into new environments, although it is a separate package from the standard library.
- If you genuinely need an environment without `pip`, create one with `python3 -m venv --without-pip .venv`; you will then need another way to install packages.
- Since Python 3.12, `setuptools` is no longer installed by default when creating a `venv`.
- Replacing `virtualenv` with `venv` **does not reduce the application's runtime dependencies**; it reduces environment-management tooling dependencies.

**Recommendation:** For a straightforward project, use `venv`, `pip` and a maintained dependency specification (`requirements.txt` or `pyproject.toml`). If your existing environment already uses `venv` and works correctly, no migration is necessary.

Reference: [Python `venv` documentation](https://docs.python.org/3/library/venv.html).
