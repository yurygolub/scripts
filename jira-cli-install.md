# Install jira-cli for Windows

## Contents

- [Install jira-cli for Windows](#install-jira-cli-for-windows)
  - [Contents](#contents)
  - [Install](#install)
  - [Configure](#configure)
  - [Test installation](#test-installation)
  - [Change default text editor for jira](#change-default-text-editor-for-jira)
  - [Commands](#commands)

This repository contains script to install [jira-cli](https://github.com/ankitpokhrel/jira-cli) on Windows

The script offers to install *jira-cli* for all users or for current user.

Also you will be prompted to add  jira-cli to Path and according to what you chose earlier, it will add it to system or local path. This script exports *JIRA_API_TOKEN* environment variable the same way if it is not already set. **And it does not modify registry**

## Install

* Create Personal Access Token in your jira account

* Set execution policy

    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```

* Run script

    ```powershell
    .\jira-cli-install.ps1
    ```

* Check installation

    ```sh
    jira
    ```

## Configure

Run this to generate config file

```sh
jira init
```

Installation type: **Local**

Authentication type: **bearer**

Link to Jira server: `your-link`

Login username: `your-username`

Then select default project and default board

## Test installation

You can view issues of your default project

```sh
jira issue list
```

## Change default text editor for jira

Set `JIRA_EDITOR` environment variable to editor you want to use

For example you can do it via powershell

```powershell
[System.Environment]::SetEnvironmentVariable('JIRA_EDITOR', 'nvim', [System.EnvironmentVariableTarget]::User)
```

## Commands

```sh
jira issue list -a $(jira me)
jira issue view someproj-39 --comments 10
```
