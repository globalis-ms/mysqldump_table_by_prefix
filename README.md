# MYSQLDUMP TABLE BY PREFIX

## Initialisation

### Configuration générale

> ``` sh
> # Fichier de config du Logrotate
> LOGROTATECONFIGFILE="$CONFIGDIR/logrotate.cnf"
>
> # Fichier de config de la database
> DATABASECONFIGFILE="$CONFIGDIR/my.cnf"
>
> # Backup directory
> BACKUPDIR="$BASEDIR/backups"
>
> # Log file format %s = prefix
> LOGFILE="$BACKUPDIR/backup_%s.sql.gz"
>
> # Database
> DATABASE="database"
>
> # Préfixes des tables dumper, 1 prefix = 1 dump
> PREFIXES="toto tata titi tutu"
>
> ```
> ./config/config.sh


### Configuration de la database
> ```
> [client]
> user=username
> password=password
> host=database_host
> port=3306
> ```
> ./config/my.cnf

### Configuration du Logrotate
> ```
> /absolute/path/backup/backups/backup_*.sql.gz {
>     daily
>     missingok
>     rotate 30
>     nocompress
>     nomail
>     notifempty
> }
> ```
> ./config/logrotate.cnf


## Commande

Exemple :
```
{ABSOLUT_PATH}/script/log.sh
```

Crontab, tous les jours à deux heures :
```
0 2 * * *  {ABSOLUT_PATH}/script/log.sh > /dev/null
```
