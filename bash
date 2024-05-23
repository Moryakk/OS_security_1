#!/bin/bash


exit_err()
{
        echo "Use $0 -h or $0 --help" >&2
        exit 1
}

users()
{
        cat /etc/passwd | cut -d: -f1,6 | sort >&1
}

processes()
{
        ps aux >&1
}

help()
{
        echo "-u и --users выводит перечень пользователей и их домашних директорий на экран, отсортированных по алфавиту" >&1
        echo "-p и --processes выводит перечень запущенных процессов, отсортированных по их идентификатору" >&1
        echo "-h и --help выводит справку с перечнем и описанием аргументов и останавливает работу" >&1
        echo "-l PATH и --log PATH замещает вывод на экран выводом в файл по заданному пути PATH" >&1
        echo "-e PATH и --errors PATH замещает вывод ошибок из потока stderr в файл по заданному пути PATH" >&1
        exit 0
}

log()
{
        if [ ! -e "$1" ]
        then
                echo "Unknown File: $1" >&2
                exit_err
        fi
        echo "Log path is $1 now" >&1
        exec 1>$1
}

errors()
{
        if [ ! -w "$1" ]
        then
                echo "Unknown File: $1" >&2
                exit_err
        fi
        echo "Error path is $1 now"
        exec 2>$1
}

# main
if [[ $# -eq 0 ]]
then
        exit_err
fi

while getopts ":uphl:e:-:" option
do
        case $option in
        u)
                users
                ;;
        p)
                processes
                ;;
        h)
                help
                ;;
        l)
                log $OPTARG
                ;;
        e)
                errors $OPTARG
                ;;
        -)
                case "${OPTARG}" in
                users)
                        users
                        ;;
                processes)
                        processes
                        ;;
                help)
                        help
                        ;;
                log)
                        log ${!OPTIND}
                        OPTIND=$(( OPTIND + 1 ))
                        ;;
                errors)
                        errors ${!OPTIND}
                        OPTIND=$(( OPTIND + 1 ))
                        ;;
                *)
                        exit_err
                        ;;
                esac
                ;;
        *)
                exit_err
                ;;

        esac

done
