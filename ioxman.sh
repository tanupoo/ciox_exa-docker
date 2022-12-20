#!/bin/sh

profile=${IOX_PROFILE:="ir1101@int"}

runtime_options_am='--entrypoint="/opt/ciox/ciox_exa/agent_man.py -l syslog -d"'
runtime_options_mm='--entrypoint="/opt/ciox/ciox_exa/mid_man.py -l syslog -d"'
runtime_options_pm='--entrypoint="/opt/ciox/ciox_exa/post_man.py -l syslog -d"'
runtime_options_redis0=""
runtime_options_redis1=""
package_tarball_am="ciox_exa.tar"
package_tarball_mm="ciox_exa.tar"
package_tarball_pm="ciox_exa.tar"
package_tarball_redis0="redis.tar"
package_tarball_redis1="redis.tar"

# Check the work directory.
app_dir="./build"
if [ ! -d "$app_dir" ] ; then
    echo "$app_dir doesn't exist."
    echo "This script must be launched the top directory."
    exit 1
fi

Usage()
{
    echo "Usage: ioxman (command)"
cat <<EOD

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

EOD
    exit 0
}

get_app_list()
{
    echo ""
    echo "## app list"
    ioxclient --profile ${profile} app li
    if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi
}

multi()
{
    prog=$1
    shift
    if [ -z "$*" ] ; then Usage ; fi
    for app_name in $*
    do
        $prog ${app_name}
    done
}

activate_one()
{
    app_name=$1
    eval "runtime_options=\$runtime_options_${app_name}"
    echo ""
    echo "## activate ${app_name}"

    ioxclient --profile ${profile} app act ${app_name} \
        --payload config/iox-${app_name}.json \
        --docker-opts "${runtime_options}"
    if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi

    ioxclient --profile ${profile} app setconf ${app_name} \
        config/app-config.json
    if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi
}

install_one()
{
    app_name=$1
    eval "package_tarball=\$package_tarball_${app_name}"
    echo ""
    echo "## install ${app_name}"

    ioxclient --profile ${profile} app in ${app_name} \
        ${app_dir}/${package_tarball}
    if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi
}

start_one()
{
    app_name=$1
    echo ""
    echo "## start ${app_name}"
    ioxclient --profile ${profile} app start ${app_name}
    if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi
}

stop_one()
{
    app_name=$1
    echo ""
    echo "## stop ${app_name}"
    ioxclient --profile ${profile} app stop ${app_name}
    if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi
}

uninstall_one()
{
    if [ -z "$1" ] ; then
        Usage
    fi
    for app_name in $1
    do
        echo ""
        echo "## uninstall ${app_name}"

        ioxclient --profile ${profile} app deact ${app_name}
        if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi

        ioxclient --profile ${profile} app unin ${app_name}
        if [ $? != 0 ] ; then echo "ERROR" ; exit 1 ; fi
    done
}

#
# main
#
mode=$1
case "$mode" in
    #
    # in operations
    start_all)
        multi activate_one redis0 redis1
        multi activate_one am mm pm
        multi start_one redis0 redis1
        multi start_one am mm pm
        ;;
    shutdown)
        multi stop_one am mm pm
        stop_one redis0
        stop_one redis1
        ;;
    list)
        # throught
        ;;
    #
    # preparation
    install_dbs)
        multi install_one redis0 redis1
        #multi activate_one redis0 redis1
        ;;
    install_apps)
        multi install_one am mm pm
        #multi activate_one am mm pm
        ;;
    #
    # for dev
    install)
        shift
        multi install_one $*
        multi activate_one $*
        ;;
    start) shift
        multi activate_one $*
        multi start_one $*
        ;;
    stop) shift ; multi stop_one $* ;;
    uninstall) shift; multi uninstall_one $* ;;
    activate) shift ; multi activate_one $* ;;
    clean)
        multi uninstall_one am mm pm
        uninstall_one redis1
        uninstall_one redis0
        ;;
    #
    *) Usage ;;
esac

sleep 2
get_app_list

exit 0
