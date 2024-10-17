---
title: "MsDyn365.Code.History Updates"
date: 2024-10-17T06:07:34+02:00
draft: false
---

You might have noticed already that I made some changes to the https://github.com/StefanMaron/MSDyn365BC.Code.History repository.

I want to use this blog to explain a little the what, and the why :)

# The what

I started this with the other repository, the MSDyn365BC.**Sandbox**.Code.History repository.
I modified my old Commit generation script a little bit so it can be used in Github Actions.

With the GitHub actions, I am able to run each country seprately and in parallel, which saves a TON of time. 

![CodeHistoryActionOverview](/images/CodeHistoryActionOverview.png)

Without that, I would not be albe to keep the Sandbox history Repository up to date. Each day, there a are new atifacts being released and each day the Actions runs.

This would be the total Runtime if it would not run in parrallel:

![TotalSandboxActionRuntime](/images/TotalSandboxActionRuntime.png)

Thats right, almost 48 h! And thats only the current releases.
I run a second Action which also pulls the vNext, meaning all NextMinor and NextMajor versions. Which runs about the same time as well.

So the Sandbox repository would not have been possible to run manually, but the OnPrem repo does not update that frequently.
It would be, and it was manageble to run manually. But now that I have the scripts already done, there was no point in not automating it as well.

# The Scripts

You can have a look at the scripts yourself if you want to, its all open source after all:

https://github.com/StefanMaron/MSDyn365BC.Code.History/blob/master/.github/workflows/BuildNewCommits.yml

https://github.com/StefanMaron/MSDyn365BC.Code.History/tree/master/scripts

But there are a few parts I want to highlight:

GetAllCountries.ps1

``` powershell
$countries = [System.Collections.ArrayList]::new()
Get-BCArtifactUrl -select All -Type OnPrem | % {
    [System.Uri]$Url = $_
    [version]$Version = $Url.AbsolutePath.Split('/')[2]
    if ($Version -ge [version]::Parse('15.0.0.0')) {
        $Url.AbsolutePath.Split('/')[3]
    } 
}| Sort-object -unique | % { $countries.Add($_)}
Write-Output "countries={""countries"":$($countries | ConvertTo-Json -Compress)}" >> $Env:GITHUB_OUTPUT
```

This script is responsible to automatically find all the countries there are artifacts for. If you want to run this on your own fork (later I will explain why you might want to) you can limit the countries here in the second line, or in the loop.


Auto_load_versions.ps1

``` powershell
Get-BCArtifactUrl -select All -Type OnPrem -country $country -after ([DateTime]::Today.AddDays(-2)) | % {
```

Since the pipeline runs every day, I can reduce the artifacts that get loaded every day. There is no need to check every day if all the versions are already commited to the Repo.
You might want to remove the `-after ` parameter or extend it a bit if you are rebuilding the Repo.

``` powershell
if ($Version -ge [version]::Parse('15.0.0.0')) {
    $Versions.Add($ourObject)
}
```

It is also possible to limit the commits by limiting the version, I did this in the Sandbox history to limit the repopository size.

After that the script does some automatic branch handling and generates the commit message and stuff.
And for simplicity I just hardcoded my git mail and user name here, you definately want to change that part as well.

UpdateALRepo.ps1

``` powershell
if (-not $SourcePath) {
    $SourcePath = "~/.bcartifacts.cache/sandbox/$Version/$Localization/Applications.DE/"
}
```

If you should the scripts locally, which is absolutely possible as well, you might want to adjust this path if you are not running Linux ;)


# The Why

And now to the last part, and the reason for this explaination: I decided to not commit the .xlf files, the translation files to the repo.
I know that a few of you are using them, but they are just too large.

I had run into issues where the GitHub Runners ran out of spaces while trying to clone the Repository. I also tried to use git LFS which resulted in this:

![GitLFSLimitReached](/images/GitLFSLimitReached.png)

It is possible to include them without using LFS, but I strongly recomend you limit either the countries you pull in, or at least cut off the version at some point.

All you need to do is to remove this line in the Auto_load_versions.ps1 script

``` powershell
Get-ChildItem -Recurse -Filter "*.xlf" | Remove-Item
```

# The README.md

I tried to explain all the rest in the Readme of both repositories.

https://raw.githubusercontent.com/StefanMaron/MSDyn365BC.Code.History/refs/heads/master/README.md

Here are some parts I want to highlight again:

### Differences to the old Repository

Main differences between the old version of the repo:
- the commits are added by pipelines to reduce runtime
- the pipelines will be scheduled to run daily once the initial load is done.
- the **main branch is just holding the scripts, switch branch to see the BC Code**
- to keep the size of this repo at least in some boundaries, I decided to not include any translation files.

### Partial Clone (Subset of Branches)
To reduce the size of the local clone you can use those commands to clone only the branches you need:

First, clone with those parameters and set it to whatever branch you need:
```
git clone -b w1-24 --single-branch https://github.com/StefanMaron/MSDyn365BC.Code.History
```
if you want to add additional branches you can do it like this
```
git remote set-branches --add origin de-24
git remote set-branches --add origin de-23
git fetch
```
You can also use wildcards for [remote-branch], e.g.
```
git remote set-branches --add origin us-*
git fetch
```

Removing tracking branches is a little more complicated.
First you need to manually edit the `.git/config` file and remove the branches in the `[remote "origin"]` section
```
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = https://github.com/StefanMaron/MSDyn365BC.Code.History
	fetch = +refs/heads/w1-23:refs/remotes/origin/w1-23
	fetch = +refs/heads/de-24:refs/remotes/origin/de-24
	fetch = +refs/heads/us-*:refs/remotes/origin/us-*
[branch "w1-23"]
	remote = origin
	merge = refs/heads/w1-23
```
once thats done you need to delete the local reference of the remote branches like this
```
git branch -d -r origin/us-23
git branch -d -r origin/us-24
```
if you had one of those branches checked out locally (a local copy of the branch) you want to delete those as well
```
git branch -D us-23
git branch -D us-24
```

and thats it, now `git fetch` should not pull the branches anymore
