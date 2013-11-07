#!/bin/bash
# Creates a new "blank" python file with the proper header comments
# for submission to Doctor Wilson

SCRIPT_NAME=newprogram

STUDENT_NAME="Shamus Taylor"
COURSE_NAME="CSCI 238"

HELP_STRING="
    $SCRIPT_NAME help:

This tool is designed to assist the user in writing programs.
When supplied with the correct information, it will generate the proper header
comments for submission to Doctor Wilson.

usage: $SCRIPT_NAME [flags] file_name work_number problem_number

Any arguments are optional, but the user will be prompted for
any unspecified and undetermined arguments.

This program will do its best to determine if an assignment is a lab or
homework, as well as the assignment's number, based on the name of your current
working directory.  To disable this, use the \"-w\" flag or specify an
assignment number when executing the command.

Flags:

    -h

        Displays this help dialogue.

    -l

        Specifies that the assignment being created is a lab.
        (will be homework by default)

    -e

        Specifies that the assignment being created is for extra credit.
        This replaces the \"Problem #\" part of the header.

    -w

        Disable automatic discovery of work type and number.

    -p

        Prepend the header instead of creating a new file.

    -n STUDENT_NAME

        Adds a name to the header.  Can be used for multiple names.
        For use in collaboration projects.

    -c COURSE_NAME

        Specifies a different course name.
"

# parse arguments
while getopts ":hlen:c:wp" opt; do
    case $opt in
        h)
            echo "$help_string"
            exit 0
            ;;
        l)
            work_type=Lab
            ;;
        e)
            problem_string="Extra Credit"
            ;;
        n)
            STUDENT_NAME="$STUDENT_NAME, $OPTARG"
            ;;
        c)
            COURSE_NAME=$OPTARG
            ;;
        w)
            disable_auto_info=true
            ;;
        p)
            prepend=true
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

# determines if the assigment is a lab based on folder name
folder_name=`basename $PWD`
if [ -z "$work_type" ]; then
    if [[ "$folder_name" == *lab* ]] && ! [ $disable_auto_info ]; then
        work_type=Lab
    else
        work_type=Homework
    fi
fi

# prompts for file name if not specified in arguments
if [ -z "$file_name" ]; then
    file_name=$1
    while [ -z "$file_name" ]; do
        read -p "File name: " -e file_name
    done
fi

folder_name_number=`echo "$folder_name" | tr -d '[:alpha:][:punct:]'`
work_number=$2

# gets number of assignment based on folder name
if [ -z "$work_number" ]; then
    if [ ! -z "$folder_name_number" ] && ! [ $disable_auto_info ]; then
            work_number=$folder_name_number
    fi
fi

# prompts for work bumber if not specified in arguments and not determined
# from folder name
while [ -z "$work_number" ]; do
    read -p "$work_type #" -e work_number
done
work_string="$work_type #$work_number"


# creates problem string to allow for special cases like the "Extra Credit" flag
if [ -z "$problem_string" ]; then
    problem_number=$3
    while [ -z "$problem_number" ]; do
        read -p "Problem #" -e problem_number
    done
    problem_string="Problem #$problem_number"
fi

# get date, create header, and edit file
DATE=$(date "+%m/%d/%y")

# if the -p option was supplied, save the file to append after the header
if [ $prepend ]; then
    content=`cat $file_name`
fi

echo -n "\
# $STUDENT_NAME
# $COURSE_NAME  $work_string $problem_string
# $file_name
# $DATE

$content" > $file_name

dos2unix $file_name

vi +5 $file_name

exit 0
