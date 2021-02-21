---
title: Create a new Git Repo
tags:
  - Git
---

## Create a new repo from scratch

```s
# Create a directory to contain the project.
mkdir my_new_project
# Go into the new directory.
cd my_new_project
# Init repo
git init
# connect to your remote repo, note that repo name can be different than local directory
git remote add origin git@github.com:username/new_repo
# Write some code
"#hello repo" > hello.md
# Add the files (all file in directory with '.')
git add .
# Commit
git commit
# Push your changes to the remote repo
git push origin master
```
