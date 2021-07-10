#!/usr/bin/bash


# Configuration
ROOT_DIR="$(dirname $(realpath $0))/"
TMP_BACKUP_DIR="/tmp/backup-services/"
DATABASES_FILENAME="databases.sql"
BACKUP_DIR="/backup/"
BACKUP_FILENAME_FORMAT="BACKUP_%d-%m-%Y_%HH%M"


# Colors
BLUE="\e[34m"
GREEN="\e[32m"
YELLOW="\e[33mY"
RED="\e[91m"
RESET="\e[39m"


# Clean temp directory
function clean {
    if [[ -e $TMP_BACKUP_DIR ]]; then
        rm -rf $TMP_BACKUP_DIR
    fi
}

# Save databases from mysql server
function backup_databases {
    printf "${BLUE}INFO${RESET}: Saving databases ..."
    # sleep 1
    mysqldump --defaults-file=${ROOT_DIR}config/mysql.conf --all-databases --lock-all-tables > ${TMP_BACKUP_DIR}${DATABASES_FILENAME}
    if [ ! $? -eq 0 ]; then
        printf "${RED}ERROR${RESET}: Cannot save databases (see error above).\n"
        return
    fi
    printf "\r${BLUE}INFO${RESET}: Databases saved.    \n"
}

# Save files from `config/data.list`
function backup_files {
    printf "${BLUE}INFO${RESET}: Saving data ..."
    for file in $(cat ${ROOT_DIR}config/files.list); do
        if [ -e $file ]; then
            filepath=$(realpath $file)
            mkdir -p $(dirname ${TMP_BACKUP_DIR}files${filepath})
            cp -rf ${file} ${TMP_BACKUP_DIR}files${filepath} 2>/dev/null
        fi
    done
    printf "\r${BLUE}INFO${RESET}: Data saved.    \n"
}

# Compress databases and files into a single compressed file
function compress_backup {
    printf "${BLUE}INFO${RESET}: Compressing files ... "

    mkdir -p $BACKUP_DIR
    if [[ ! -e $BACKUP_DIR ]]; then
        printf "${RED}ERROR${RESET}: Please check permission level (cannot create backup directory).\n"
        return
    fi

    filepath=$(realpath ${BACKUP_DIR}$(date +"${BACKUP_FILENAME_FORMAT}").zip)
    cd ${TMP_BACKUP_DIR} && zip -qr ${filepath} .

    printf "\r${BLUE}INFO${RESET}: Backup compressed.   \n"
}

# Create a zip backup file
function main {
    # Clean previous backup and prepare next backup
    clean
    mkdir -p $TMP_BACKUP_DIR
    if [[ ! -e $TMP_BACKUP_DIR ]]; then
        printf "${RED}ERROR${RESET}: Please check permission level (cannot create temporary directory).\n"
        return
    fi

    # Save data
    backup_databases
    backup_files

    # Copy and clean backup
    compress_backup
    clean

    printf "\n${GREEN}Backup successful !${RESET}\n"
}

main
