# Invoke-WslCommand

Run WSL commands from PowerShell — like `cat`, `grep`, `ls`, and more.

## ⚙️ Setup

1. Save the script as `Invoke-WslCommand.ps1`.

2. Add it to your PowerShell profile so it loads automatically:

```powershell
. "path-to/Invoke-WslCommand.ps1"
```

> 💡 You can check your PowerShell profile path with:
>
> ```powershell
> $PROFILE
> ```

## Example Usage

To define wrapper functions for common Linux commands, add something like this to your PowerShell profile:

```powershell
function global:cat {
    Invoke-WslCommand -Command "cat" -Arguments $args
}

function global:grep {
    Invoke-WslCommand -Command "grep" -Arguments $args
}
```

### Replacing Aliases

If you're replacing existing PowerShell aliases (like `ls`), make sure to remove them first:

```powershell
Remove-Item alias:ls -Force -ErrorAction SilentlyContinue

function global:ls {
    Invoke-WslCommand -Command "ls" -Arguments $args
}
```

### Piping commands

You can pipe your commands with ->
```bash
cat README.md -> grep "hello world"
```

## 📦 Benefits

- Run Linux tools directly from PowerShell
- Easily integrate WSL into your Windows workflow
- Customize and expand with your own command wrappers

---

## 🧠 Tip

Use this setup to unify your dev environment — best of both worlds: Windows + Linux!
