#!/bin/bash
#
#  Copyright (c) 2016 Jeong Han Lee
#  Copyright (c) 2016 European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author : Jeong Han Lee
# email  : jeonghan.lee@gmail.com
# Date   : 
# version : 0.0.3
#


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_DATE="$(date +%Y%m%d-%H%M)"


set -a
. ${SC_TOP}/env.conf
set +a

. ${SC_TOP}/functions


# Notice! 
# No root password of MySQL or MariaDB in localhost is assumed.
#
declare -g root_pwd=""
declare -g SQL_ROOT_CMD="mysql --user=root --password=${root_pwd}"
declare -g SQL_DBUSER_CMD="mysql --user=${DB_USER_NAME} --password=${DB_USER_PWD} ${DB_NAME}"
declare -g SQL_BACKUP_CMD="mysqldump --user=${DB_USER_NAME} --password=${DB_USER_PWD} ${DB_NAME}"
declare -g SQL_CMD_OPTIONS="--skip-column-names --execute"


function no_db_msg() {

    printf "\nThere is no >> %s << in the dababase, please check your SQL enviornment.\n\n" "${DB_NAME}"
}


function db_secure_setup() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    
    # MariaDB Secure Installation without MariaDB root password
    # the same as mysql_secure_installation, but skip to setup
    # the root password in the script. The reference of the sql commands
    # is https://goo.gl/DnyijD
        
    printf "Setup mysql_secure_installation...\n";
    
    # UPDATE mysql.user SET Password=PASSWORD('$passwd') WHERE User='root';
    
    ${SQL_ROOT_CMD} <<EOF
-- DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
    __end_func ${func_name};
}



function db_create() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local db_name=${DB_NAME}
    local db_user_name= ${DB_USER_NAME}
    local db_user_pwd=${DB_USER_PWD}
    
    printf "Create the Database %s if not exists...\n" "${db_name}";

    ${SQL_ROOT_CMD} <<EOF
CREATE DATABASE IF NOT EXISTS ${db_name}; GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user_name}'@'localhost' IDENTIFIED BY '${db_user_pwd}';
EOF
    __end_func ${func_name};
}



function db_drop() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local db_name=${DB_NAME}
    
    printf "Drop the Database %s if not exists...\n" "${db_name}";

    ${SQL_ROOT_CMD} <<EOF
DROP DATABASE IF EXISTS ${db_name};
EOF
    __end_func ${func_name};
}


function show_dbs() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local dBs=$(${SQL_ROOT_CMD} ${SQL_CMD_OPTIONS} 'SHOW DATABASES' | awk '{print $1}')

    printf "\n";

    for db in $dBs
    do
	printf ">>>>> %24s was found.\n" "${db}"
    done
    
    __end_func ${func_name};

}


function show_tables () {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local tables=""
    local db_exist=$(isDb);
    
    if [[ $db_exist -ne "$EXIST" ]]; then
	no_db_msg;
	exit;
    else
	tables=$(${SQL_DBUSER_CMD} ${SQL_CMD_OPTIONS} "SHOW TABLES" | awk '{print $1}' )
	printf "\n";
	for table in $tables
	do
	    printf ">>>>> %24s was found.\n" "${table}"
	done
    fi

    __end_func ${func_name};

}



function drop_tables () {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local tables="";
    local db_exist=$(isDb);
    
    if [[ $db_exist -ne "$EXIST" ]]; then
	no_db_msg;
	exit;
    else
	tables=$(${SQL_DBUSER_CMD} ${SQL_CMD_OPTIONS} 'SHOW TABLES' | awk '{print $1}' )
	printf "\n";
	for table in $tables
	do
	    printf ". %24s was found. Dropping .... \n" "${table}"
	    ${SQL_DBUSER_CMD} -e "DROP TABLE ${table}"
	done
    fi
    __end_func ${func_name};

}
			  


function fill_db() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local aa_deploy_db_tables=${SC_TOP}/${AA_GIT_NAME}/src/main/org/epics/archiverappliance/config/persistence/archappl_mysql.sql
    local aa_deploy_db_tables_new=${aa_deploy_db_tables}_dbmanager.sql
    
    # DB setup is done when we execute it at the very first time, after this, if we run this script again,
    # I would like to add the logic to check whether DB exists or not. So create a new db sql file with 
    # CREATE TABLE IF NOT EXISTS.
    local db_exist=$(isDb);
    
    if [[ $db_exist -ne "$EXIST" ]]; then
	no_db_msg;
	exit;
    else
	sed "s/CREATE TABLE /CREATE TABLE IF NOT EXISTS /g" ${aa_deploy_db_tables} > ${aa_deploy_db_tables_new};
	${SQL_DBUSER_CMD} < ${aa_deploy_db_tables_new};
    fi

    __end_func ${func_name};
    
}


function select_all_from_tables_in_db() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local tables="";
    local db_exist=$(isDb);
    
    if [[ $db_exist -ne "$EXIST" ]]; then
	no_db_msg;
	exit;
    else
	tables=$(${SQL_DBUSER_CMD} ${SQL_CMD_OPTIONS} 'SHOW TABLES' | awk '{print $1}' )
	printf "\n";
	for table in $tables
	do
	    printf ". %24s was found. Selecting all .... \n" "${table}"
	    ${SQL_DBUSER_CMD} --execute "SELECT * from ${table}"
	done
    fi

    __end_func ${func_name};
    
}


function backup_db() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local dbDir="";
    local db_exist=$(isDb);
    
    if [[ $db_exist -ne "$EXIST" ]]; then
	no_db_msg;
	exit;
    else
	dbDir=$(checkIfDir ${DB_BACKUP_PATH})
	if [[ $dbDir -ne "$EXIST" ]]; then
	    mkdir -p ${SC_TOP}/${DB_BACKUP_PATH}
	fi
	${SQL_BACKUP_CMD} | gzip -9 > "${DB_BACKUP_PATH}/${DB_NAME}_${SC_DATE}.sql.gz"
    fi
    __end_func ${func_name};
}


function backup_db_list() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local dbDir=$(checkIfDir ${DB_BACKUP_PATH})
    if [[ $dbDir -ne "$EXIST" ]]; then
	printf "\nThere is no >> %s << directory, please check your enviornment.\n\n" "${DB_BACKUP_PATH}"
	exit;
    fi

    ls -lta ${SC_TOP}/${DB_BACKUP_PATH}

    __end_func ${func_name};

}



function restore_db() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local date=$1;

    gunzip < "${DB_BACKUP_PATH}/${DB_NAME}_${date}.sql.gz" | ${SQL_DBUSER_CMD} ;

    __end_func ${func_name};

}  

function isDb {

  local dbname=${DB_NAME};
  local output=$(${SQL_ROOT_CMD} ${SQL_CMD_OPTIONS} "SELECT schema_name FROM information_schema.schemata WHERE schema_name=\"${dbname}\"")

  local result=""
  if [[ -z "${output}" ]]; then
      result=${NON_EXIST} # does not exist
  else
      result=${EXIST}     # exists
  fi

  echo "${result}"

}   


db_date=$2

case "$1" in
    ssetup_db)
	db_secure_setup
	;;
    create_db)
	db_create 
	show_dbs
	;;
    show_dbs)
	show_dbs
	;;
    drop_db)
	db_drop 
	show_dbs
	;;
    fill_db)
	fill_db
	show_tables
	;;
    show_tables)
	show_tables
	;;
    drop_tables)
	drop_tables
	show_tables
	;;
    select_all_from_tables)
	select_all_from_tables_in_db
	;;
    backup_db)
	backup_db
	;;
    backup_db_list)
	backup_db_list
	;;
    restore_db)
	restore_db ${db_date}
	;;
    isDb)
	isDb
	;;
    *)

	echo "">&2
        echo " DB >> ${DB_NAME} << Manager for the EPICS Archiver Applance ">&2
	echo ""
	echo " Usage: $0 <arg>">&2 
	echo ""
        echo "          <arg>             : info">&2 
	echo ""
	echo "          show_dbs          : show DBs in    >> ${HOSTNAME} << ">&2
	echo "          create_db         : create         >> ${DB_NAME}  << ">&2
	echo "          drop_db           : drop           >> ${DB_NAME}  << ">&2
	echo "          fill_db           : fill tables in >> ${DB_NAME}  << ">&2
	echo "          show_tables       : show tables in >> ${DB_NAME}  << ">&2
	echo "          drop_tables       : drop tables in >> ${DB_NAME}  << ">&2
	echo "          backup_db         : backup         >> ${DB_NAME}  << in ${DB_BACKUP_PATH}">&2
	echo "          backup_db_list    : backup db list >> ${DB_NAME}  << in ${DB_BACKUP_PATH}">&2
	echo "          restore_db <date> : restore db     >> ${DB_NAME}  << ">&2
	echo "          select_all_from_tables_in_db       >> ${DB_NAME}  << ">&2
	echo "">&2 	
	exit 0
esac



