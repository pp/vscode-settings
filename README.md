# vscode-settings

To sync settings:

Copy `settings.json`:

```bash
cp ~/.config/Code/User/settings.json .
```

Create list of extensions:

```bash
code --list-extensions > extensions
```

Install extensions from file:

```bash
for line in $(cat extensions); do code --install-extension $line; done
```
