#!/usr/bin/env bash

###############################################################################
# Display functions
###############################################################################

if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
fi

if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
   RED="$(tput setaf 1)"
   GREEN="$(tput setaf 2)"
   YELLOW="$(tput setaf 3)"
   BLUE="$(tput setaf 4)"
   BOLD="$(tput bold)"
   NORMAL="$(tput sgr0)"
else
   RED=""
   GREEN=""
   YELLOW=""
   BLUE=""
   BOLD=""
   NORMAL=""
fi

tell() {
  echo "${BLUE}|-- ${*}${NORMAL}"
  $* || {
    echo "${RED}Fail !" 1>&2 ;
    exit 1 ;
  }
}

explain() {
  echo "${YELLOW}${1}${NORMAL}"
}

success() {
  echo "${GREEN}${1}${NORMAL}"
}

error() {
  echo "${RED}${1}${NORMAL}"
}


###############################################################################
# Help function
###############################################################################
display_help() {
    explain "Usage: mysqldump_by_prefix.sh [OPTIONS] database prefix"
    echo ""
    explain "The following options may be given as the first argument:"
    echo "  --defaults-extra-file #   Read this file after the global files are read."
    #  echo "  --gzip-bin #              Gzip binary path."
    echo "  --help                    Display this help message and exit."
    echo "  -h, --host #              Connect to host."
    echo "  --mysql-bin #             MySQL  binary path. (mysql default)"
    echo "  --mysqldump-bin #         MySQLDump binary path. (mysqldump default)"
    echo "  -u, --user #              User for login if not current user."
    echo "  -p, --password #          Password to use when connecting to server.
                            If password is not given it's solicited on the tty."
}


###############################################################################
# VARIABLES
###############################################################################
MYSQL=mysql
MYSQLDUMP=mysqldump
GZIP=gzip

# OPTIONS
MYSQLOPTIONS=""
MYSQLDUMPOPTIONS=""

###############################################################################
# OPTIONS
###############################################################################
while :
do
    case "$1" in
      --defaults-extra-file)
        # EXTRA FILE LIKE ~/my.cnf
        MYSQLOPTIONS="$MYSQLOPTIONS --defaults-extra-file=$2"
        MYSQLDUMPOPTIONS="$MYSQLDUMPOPTIONS --defaults-extra-file=$2"
        shift 2
        ;;
      --gzip-bin)
        GZIP="$2"
        shift 2
        ;;
      --help)
        # DISPLAY HELP
        display_help
        exit 0
        ;;
      -h | --host)
        MYSQLOPTIONS="$MYSQLOPTIONS -h $2"
        MYSQLDUMPOPTIONS="$MYSQLDUMPOPTIONS -h $2"
        shift 2
        ;;
      --mysql-bin)
        MYSQL="$2"
        shift 2
        ;;
      --mysqldump-bin)
        MYSQLDUMP="$2"
        shift 2
        ;;
      -u | --user)
        MYSQLOPTIONS="$MYSQLOPTIONS -u $2"
        MYSQLDUMPOPTIONS="$MYSQLDUMPOPTIONS -u $2"
        shift 2
        ;;
      -p | --password)
        MYSQLOPTIONS="$MYSQLOPTIONS -p$2"
        MYSQLDUMPOPTIONS="$MYSQLDUMPOPTIONS -p$2"
        shift 2
        ;;
      --) # End of all options
        shift
        break
        ;;
      -*)
        error "Error: Unknown option: $1" >&2
        display_help
        exit 1
        ;;
      *)  # No more options
        break
        ;;
    esac
done

###############################################################################
# CHECK ARGS
###############################################################################
if test -z "$1" -o -z "$2"
then
    error "Usage: mysqldump_by_prefix.sh [OPTIONS] database prefix"  >&2
    echo "For more options, use $0 --help" >&2
    exit
fi

###############################################################################
# DUMP TABLES
###############################################################################
$MYSQLDUMP $MYSQLDUMPOPTIONS $1 $(
     $MYSQL $MYSQLOPTIONS -N information_schema -e \
         "SELECT \`table_name\`
         FROM INFORMATION_SCHEMA.TABLES
         WHERE \`table_schema\` = '$1'
         AND \`table_name\` LIKE '$2%'"
)
