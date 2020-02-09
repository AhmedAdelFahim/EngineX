#!/usr/bin/env bash

. ./database_functions.sh
function read_query {
    input="";
    while [ 1 -eq 1 ]
    do
        read input;
        if [[ $input =~ ^CREATE\ +TABLE\ +[A-Za-z_]+\ +COLUMNS\ +([A-Za-z_]+,(int|text)\ +)+\;$ ]]
        then
            create_table $input
            if [ $? -eq 1 ]
            then
                continue;
            fi
        elif [[ $input =~ ^INSERT\ +INTO\ +[A-Za-z_]+\ +ROW\ +([A-Za-z_]+=(\"[A-Za-z_0-9@\. ]+\"|([0-9])+)\ +)+\;$ ]]
        then
            insert_into $input
            if [ $? -eq 1 ]
            then
                continue;
            fi
        elif [[ $input =~ ^DELETE\ +FROM\ +[A-Za-z_]+\ +WHERE\ +([A-Za-z_]+=(\"[A-Za-z_0-9 ]+\"|([0-9])+)\ +)\;$ ]]
        then
            delete_from_table $input
            if [ $? -eq 1 ]
            then
                continue;
            fi
        elif [[ $input =~ ^LIST\ +[A-Za-z_]+\ +\;$ ]] ##DONE
        then
            listTables $input
            if [ $? -eq 1 ]
            then
                continue;
            fi
        elif [[ $input =~ ^SELECT\ +ALL\ +FROM\ +[A-Za-z_]+\ +\;$ ]] ##DONE
        then
            selectAll $input
            if [ $? -eq 1 ]
            then
                continue;
            fi
        elif [[ $input =~ ^BACK\ +\;$ ]] ##DONE
        then
            mainMenu
            if [ $? -eq 1 ]
            then
                continue;
            fi
        elif [[ $input =~ ^HELP\ +\;$ ]] ##DONE
        then
            showHelpInstructions
            if [ $? -eq 1 ]
            then
                continue;
            fi
        else
            echo "wrong query please enter correct query";
            continue;
        fi

    done
}
#clear;
#read_query
#clear;
mainMenu
