#!/usr/bin/env bash

# $1 - tmux target pane

# create a global per-pane variable that holds the pane's PWD
# add to .bashrc
#export PS1=$PS1'$( [ -n $TMUX ] && tmux setenv -g TMUX_PWD_$(tmux display -p "#D" | tr -d %) $PWD)'

targetpane=$1

while [[ 1 ]];
do
    clear

    # get WD of target pane
    P=$(tmux showenv -g "TMUX_PWD_${targetpane}"  | sed 's/^.*=//')

    # get working tree with full path specs
    T=$(tree -f -i "${P}")

    # get same working tree, but user-friendly view; add line numbers
    PRINTTREE=$(tree "${P}" | sed -n '/^/{=;p;}'| sed '{N;s/\n/ /}')

    LINES=$(printf "${PRINTTREE}" | wc -l)

    # print tree
    printf "${PRINTTREE}"

    # wait some time for user to select path
    read -t 5 goto

    # if user selected path, send cd to target pane
    if [[ ${goto} -le ${LINES} && ${goto} -ge 1 ]]
    then
        gotopath=$(printf "${T}" | sed "${goto}q;d" | sed 's/->.*//g')
        tmux send-keys -t "${targetpane}" "cd ${gotopath}" Enter
    fi
done