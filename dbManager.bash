#!/bin/bash
#
#  Copyright (c) 2016 Jeong Han Lee
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
# version : 0.0.1
#


declare -gr SC_SCRIPT="$(realpath "$0")"
#declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
#declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"


set -a
. ${SC_TOP}/env.conf
set +a

. ${SC_TOP}/functions


# Notice! 
# No root password of MySQL or MariaDB in localhost is assumed.
#
declare -g root_pwd=""
declare -g SQL_ROOT_CMD="mysql --user=root --password=${root_pwd}"
declare -g SQL_DBUSER_CMD="mysql --user=${DB_USER_NAME} --password=${DB_USER_PWD} --database=${DB_NAME}"

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

    local db_name=$1
    local db_user_name=$2
    local db_user_pwd=$3
    
    printf "Create the Database %s if not exists...\n" "${DB_NAME}";

    ${SQL_ROOT_CMD} <<EOF
CREATE DATABASE IF NOT EXISTS ${db_name}; GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user_name}'@'localhost' IDENTIFIED BY '${db_user_pwd}';
EOF
    __end_func ${func_name};
}



function db_drop() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local db_name=$1
    
    printf "Drop the Database %s if not exists...\n" "${db_name}";

    ${SQL_ROOT_CMD} <<EOF
DROP DATABASE IF EXISTS ${db_name};
EOF
    __end_func ${func_name};
}


function show_dbs() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local dbs=""
    
    dbs=$(${SQL_ROOT_CMD} -e 'SHOW DATABASES' | awk '{print $1}' | grep -v '^Database')

    printf "\n";
    
    for db in $dbs
    do
	printf ">>>>> %24s was found.\n" "${db}"
    done
    
    __end_func ${func_name};

}


function show_tables () {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local tables=""
    tables=$(${SQL_DBUSER_CMD} -e "SHOW TABLES" | awk '{print $1}' | grep -v '^Tables' )
    printf "\n";
    for table in $tables
    do
	printf ">>>>> %24s was found.\n" "${table}"
    done

    __end_func ${func_name};

}



function drop_tables () {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local tables=""
    tables=$(${SQL_DBUSER_CMD} -e 'SHOW TABLES' | awk '{print $1}' | grep -v '^Tables' )
    printf "\n";
    for table in $tables
    do
	printf ". %24s was found. Dropping .... \n" "${table}"
	${SQL_DBUSER_CMD} -e "DROP TABLE ${table}"
    done

       __end_func ${func_name};

}
			  


function fill_db() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local aa_deploy_db_tables=${SC_TOP}/${AA_GIT_NAME}/src/main/org/epics/archiverappliance/config/persistence/archappl_mysql.sql
    local aa_deploy_db_tables_new=${aa_deploy_db_tables}_dbmanager.sql
    
    # DB setup is done when we execute it at the very first time, after this, if we run this script again,
    # I would like to add the logic to check whether DB exists or not. So create a new db sql file with 
    # CREATE TABLE IF NOT EXISTS.
    
    sed "s/CREATE TABLE /CREATE TABLE IF NOT EXISTS /g" ${aa_deploy_db_tables} > ${aa_deploy_db_tables_new};
    
    ${SQL_DBUSER_CMD} < ${aa_deploy_db_tables_new};

    __end_func ${func_name};
    
}


function select_all_from_table_in_db() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local tables=""
    tables=$(${SQL_DBUSER_CMD} -e 'SHOW TABLES' | awk '{print $1}' | grep -v '^Tables' )
    printf "\n";
    for table in $tables
    do
	printf ". %24s was found. Selecting all .... \n" "${table}"
	${SQL_DBUSER_CMD} -e "SELECT * from ${table}"
    done


    __end_func ${func_name};
    
}



case "$1" in
    ssetup_db)
	db_secure_setup
	;;
    create_db)
	db_create ${DB_NAME} ${DB_USER_NAME} ${DB_USER_PWD}
	show_dbs
	;;
    show_dbs)
	show_dbs
	;;
    drop_db)
	db_drop ${DB_NAME}
	show_dbs
	;;
    fill_db)
	# Should be ${DB_NAME} already in DB
	fill_db
	show_tables
	;;
    show_tables)
	# Should be ${DB_NAME} already in DB
	show_tables
	;;
    drop_tables)
	# Should be ${DB_NAME} already in DB
	drop_tables
	show_tables
	;;
    select_all_from_tables)
	select_all_from_table_in_db
	;;
    *)

	echo "">&2
        echo " DB >> ${DB_NAME} << Manager for EPICS Archiver Applance ">&2
	echo ""
	echo " Usage: $0 <arg>">&2 
	echo ""
        echo "          <arg>       : info">&2 
	echo ""
	echo "          show_dbs    : show DBs in    >> ${HOSTNAME} << ">&2
	echo "          create_db   : create         >> ${DB_NAME} << ">&2
	echo "          drop_db     : drop           >> ${DB_NAME} << ">&2
	echo "          fill_db     : fill tables in >> ${DB_NAME} << ">&2
	echo "          show_tables : show tables in >> ${DB_NAME} << ">&2
	echo "          drop_tables : drop tables in >> ${DB_NAME} << ">&2
	echo "">&2 	
	exit 0
esac



