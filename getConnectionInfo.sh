#!/bin/bash
clear
#Initialise parameters
tailNumber=$1
showAllLinesYN=$2
userPickYN=$3
dataList=$4
userInput=$5

#create functions:
#Make user pick YN
function getYorN {
    while true; do
    read -p "Pick yes or no (y/n): " yn
    case $yn in
        [Yy]* ) userPickYN="1"; break;;
        [Nn]* ) userPickYN="2"; break;;
        * ) echo -e "\nPlease answer yes or no (y/n) \n";;
    esac
done
}

#Get and check input and return error if it is wrong:
function checkInput {
    while true; do
    read userInput
        for data in $dataList; do
            if [ "$data" == "$userInput" ]; then
                process=$userInput
                break
            else
                echo -e "Invalid input $userInput. Please enter valid data."
            fi
        done
    if ! [ -z "$process" ]; then
        break
    fi
    done
}

#Ask how many lines user wants to get and check if it is correct:
function getTail {
    while true; do
    echo -e "How many lines you want to be displayed?"
    read userInput
    int='^[0-9]+$'
    if ! [[ $userInput =~ $int ]] ; then
        echo -e "Please enter number \n"
    else
        tailNumber=$userInput
        break
    fi
done
}

#Ask if user want to see all lines:
function showAllLinesYN {
    echo -e "\nDo you want to see all lines?"
    getYorN
    if [ "$userPickYN" -eq "1" ]; then
        tailNumber="999999"
    else
        getTail
    fi
}


#Print result:
function printResults {
    echo -e "\n \nProcess $process is connected to: \n"
    netstat -tunapl |
    awk '/'"$process"'/ {print $5}' |
    cut -d: -f1 | sort |
    uniq -c | sort |
    tail -n"$tailNumber" |
    grep -oP '(\d+\.){3}\d+' |
    while read -r IP; do whois "$IP" |
        awk -F':' '/^Organization/ {print $2}' ; done |
    sort | uniq -c
}


#print question about process PID or name user is interested in

#Check if user wants to enter PID or process name:
function pickPIDorName {
    if [ "$userPickYN" -eq "1" ]; then
        dataList=$(netstat -tunapl | awk '{print $7}' | grep -oP '/\K.*' | sort | uniq)
        echo -e "\nPlease enter name of the process\n"
        checkInput
        showAllLinesYN
        printResults
    else
        dataList=$(netstat -tunapl | awk '{print $7}' | awk -F '/' '{print $1}' | sed s/[^0-9]//g | sort | uniq)
        echo -e "\nPlease enter PID of the process\n"
        checkInput
        showAllLinesYN
        printResults
    fi
}


#Runing the script:
function startScript {
    echo -e "\nHello, do you want to enter process name? \n"
    getYorN
    pickPIDorName
}

startScript