# PRIMARY SOLUTION

```shell
git checkout --orphan newBranch
git add -A                        # add all files and commit them
git commit
git branch -D master              # delete the master branch
git branch -m master              # rename the current branch to master
git push -f origin master         # force push master branch
git gc --aggressive --prune=all   # remove the old files
```

# ALTERNATIVE SOLUTION

1. Remove the history from the local repository (make sure you have backup, this cannot be reverted)

     ```shell
     rm -rf .git/
     ```

2. Recreate the repository from the current content only

     ```shell
	 git init
	 git add .
	 git commit -m "Initial commit"
	 ```

3. Push to remote repository ensuring history overwriting

     ```shell
	 git remote add origin git@github.com:<ACCOUNT>/<REPOSITORY>.git
	 git push -u --force origin master
	 ```

# REFERENCES

- [Make the current commit the only (initial) commit in a Git repository?](https://stackoverflow.com/q/9683279/3235496)