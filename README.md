docker版ciox_exa
================

docker版[ciox_exa](https://github.com/tanupoo/ciox_exa)

## build

```
sh build.sh (TAG)
```

TAGはciox_exaの[タグ](https://github.com/tanupoo/ciox_exa/tags)を指定する。

例
```
sh build.sh ver0.91
```

## config

configにある。

docker自体のコンフィグファイル
iox-am.json
iox-mm.json
iox-pm.json
iox-redis0.json
iox-redis1.json

am,mm,pmのコンフィグファイル
app-config.json

## ioxman

```
Usage: ioxman (command)

    ## initialize

        ioxman clean
        ioxman install_dbs
        ioxman install_apps
        ioxman list

    ## in operations.

        ioxman start_all
        ioxman list
        ioxman shutdown

    ## cleanup

        ioxman shutdown
        ioxman clean

    ## developpment

        ioxman install (app) [app ...]
        ioxman activate (app) [app ...]
        ioxman start (app) [app ...]
        ioxman stop (app) [app ...]
        ioxman uninstall (app) [app ...]
```
