#!/usr/bin/env bash

function create_table {
#    please check if two cols have same name
    cd ../database/students/metadate/;      # look
    fields=($@);
    number_fields=${#fields[@]};
    if [ -f ${fields[2]} ];
    then
        echo "this table already exist";
        cd ../..                            # look
        return 1;
    fi
    touch ${fields[2]};
    touch ../database/${fields[2]};
    colName="";
    colType="";
    for (( i = 4; i < ${number_fields}-1; ++i )); do
        IFS=',' read -r -a array <<< "${fields[${i}]}";
        colName=$colName${array[0]};
        colName=$colName":";
        colType=$colType${array[1]};
        colType=$colType":";
    done
    echo $colName >> ${fields[2]}
    echo $colType >> ${fields[2]}
    cd ../..                                    # look
    return 0;
}

function insert_into {

    cd ../database/students/database/;
    fields=($@);
    number_fields=${#fields[@]};
    if [ ! -f ${fields[2]} ];
    then
        echo "this table not exist";
        cd ..                            # look
        return 1;
    fi
    row="";
    stringFlag=0;
    colVal=""
    IFS=':' read -r -a colNames <<< `sed -n '1p' ../metadate/${fields[2]}`;
    IFS=':' read -r -a colTypes <<< `sed -n '2p' ../metadate/${fields[2]}`;
    typeset -i colNumber=-1
    for (( i = 4; i < ${number_fields}-1; ++i )); do
        if [ $stringFlag -eq 0 ]
        then

            colVal=""
            colNumber=$colNumber+1;
            IFS='=' read -r -a array <<< "${fields[${i}]}";
            if [ ${colNumber} -ge ${#colNames[@]} ]
            then
                echo "many columns exist";
                return 1;
            fi

            if [ ${array[0]} != ${colNames[${colNumber}]} ]
            then
                echo "this column not exist";
                return 1;
            fi

        fi
        if [[ ${array[1]} =~ ^\" && $stringFlag -eq 0 ]]
        then
            if [ ${colTypes[${colNumber}]} != "text" ]
            then
                echo "wrong datatype";
                return 1;
            fi
            colVal=$colVal${array[1]}
            if  [[ ${array[1]} =~ \"$ ]]
            then
                row=$row":"$colVal
                continue;
            fi
            stringFlag=1;
            continue;
        fi

        if [ $stringFlag -eq 1 ]
        then
            colVal=$colVal" "${fields[${i}]}
            if [[ ${fields[${i}]} =~ \"$ ]]
            then
                row=$row":"$colVal
                stringFlag=0;
            fi
            continue;
        fi

        if [ ${colTypes[${colNumber}]} != "int" ]
        then
            echo "wrong datatype";
            return 1;
        fi
        colVal=${array[1]}
        row=$row":"$colVal
    done
    if [[ ${colNumber}+1 -ne ${#colNames[@]} ]]
    then
        echo "few columns"
        return 1;
    fi
    echo $row | sed -r 's/\"//g' >> ${fields[2]}
    return 0
}

function delete_from_table {
    cd ../database/students/database/;
    fields=($@);
    number_fields=${#fields[@]};
    if [ ! -f ${fields[2]} ];
    then
        echo "this table not exist";
        cd ..                            # look
        return 1;
    fi
    IFS=':' read -r -a colNames <<< `sed -n '1p' ../metadate/${fields[2]}`;
    IFS=':' read -r -a colTypes <<< `sed -n '2p' ../metadate/${fields[2]}`;

    IFS='=' read -r -a arr <<< "${fields[4]}";
    colName=${arr[0]};
    colVal=${arr[1]};
    colType=int;
    lineNum=0;
    for (( i = 5; i < ${number_fields}-1; ++i )); do
        colVal=$colVal" "${fields[${i}]}
        colType=text;
    done
    for (( i = 0; i < ${#colNames[@]}; ++i )); do
        if [[ ${colNames[${i}]} = $colName && ${colTypes[${i}]} = $colType ]]
        then
            read lineNum <<< $(awk -F: -v colNum="${i}" -v colName="$colName" -v colVal="$colVal" 'BEGIN{lineNum=-1}{
                gsub("\"","",colVal);
                colNum+=2;
                for(j=2;j<=NF;++j)
                {
                    if(colVal == $j) {
                        lineNum=NR;
                    }
                }

            } END{
                print lineNum
            }' ${fields[2]})
            if [ $lineNum -eq 0 ]
            then
                echo "0 Rows Deleted"
                return 1;
            else
                sed -i "$lineNum d" ${fields[2]};
                echo "1 Row Deleted"
            fi
            break;
        fi
    done
}

dbName="";
dbs=($(ls database/)); #initializing

function listDatabases {
   dbs=($(ls database/)); #for updating
   for(( i=0; i<${#dbs[@]}; i++ ))
   do
   echo "  -- ${dbs[$i]}"
   done
}

function createDatabase {
   read -p "Enter DB Name: " dbName;
   mkdir -p database/$dbName/database #for data itself
   mkdir database/$dbName/metadata    #for metadata
   dbs=($(ls database/)); #for updating
   echo '********************************'
   echo '   DB is Created Successfully!  '
   echo '********************************'
}

function connectToDatabase {
   read -p "Enter DB Name: " dbName;
   isFound=false;
   for(( i=0; i<${#dbs[@]}; i++ ))
   do
   if [ "${dbs[$i]}" == "$dbName" ] ; then
     #cd database/$dbName
     isFound=true;
     break;
   fi
   done
   if [ "$isFound" = true ] ; then
     echo '********************************'
     echo "       $dbName is Selected      "
     echo '********************************'
     redirectToDBSystem
   else
     echo '**********************************************'
     echo "$dbName is not Found, Please Select a Valid DB"
     echo '**********************************************'
     mainMenu
   fi
}

function redirectToDBSystem {
  echo '*****************************************************'
  echo "  You can now:     "
  echo "           1) List Tables in DB"
  echo "           2) Create Tables in DB"
  echo "           3) Insert Rows into Tables in DB"
  echo "           4) Delete Rows from DB"
  echo "           5) Select All Rows form a Table in DB"
  echo "           6) Go Back to Main Menu          " #Needs to be handled???
  echo '*****************************************************'
  read_query
}

function listTables {  ##Needs to be handled in Regex
 database=$1 
 if [ "$(ls -A)" ] ; then
   #tables=($(find * -not -name "*.meta" -type f))
  tables=($(ls database/$database/database)) 
  for(( i=0; i<${#tables[@]}; i++ ))
   do
    echo "  -- ${tables[$i]}"
   done
 else
  echo '**************************************************'
  echo 'Database is Empty. Create New Tables to Save :)'
  echo '**************************************************'
 fi
}

function selectAll { ##Needs to be handled in Regex
  tableName=$1;
  sed -n '1p' database/$dbName/metadate/$tableName | tr ":" "\t"; #header
  cat database/$dbName/database/$tableName | tr ":" "\t";         #data, I modified in database table structure ":" at the beginning
}

echo '***********************'
echo '  Welcome to EngineX   '
echo '***********************'

PS3="Enter Your Choice> "

function mainMenu {
 while true
 do
  select choice in 'List DBs' 'Create DB' 'Connect to DB' 'Exit'
  do
   case $choice in
    'List DBs')
    listDatabases
    break;
    ;;
    'Create DB') 
    createDatabase
    break;
    ;;
    'Connect to DB') 
    connectToDatabase
    break 2;
    ;;
    Exit)
    echo '************'
    echo '    bye!    '
    echo '************'   
    exit
    break 2;
    ;;
   esac
  done
 done
}

