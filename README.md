# backup-data

This backup tool was developed to keep the database and files safe.

Backup files are saved in the `/backup` directory by default.

## Configuration

1. First of all, edit database configuration in the `config/mysql.conf` file following [this documentation](https://dev.mysql.com/doc/refman/8.0/en/option-files.html).
2. List directories and files that need to be save in `config/files.list`.
3. Edit `backup.sh` and edit configuration variables in the head of the file.

## Manual backup

To start a backup just run :

```bash
cd path-to/.../backup-data/
sh backup.sh
```

## Automatic backup

**cron** is perfect for your job. Just a simple example (at 04:00 on Monday) :

```crontab
0 6 * * *   root    /usr/bin/bash /path-to/.../backup.sh
```
