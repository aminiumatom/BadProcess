#!/bin/bash

malware_pid=$1
path_to_proc=$2

#get userid
user_id=$(cat $2/$malware_pid/status | grep -w "Uid" | awk '{print $2}')
echo $user_id

#get child processes
child_id=""
PPid=""
for dir in $path_to_proc/*
do
  if [[ -d $dir ]];
  then
    if [[ -f $dir/status ]];
    then
      PPid=$(cat $dir/status | grep -w "PPid" | awk '{print $2}')
    fi
    if [[ $PPid == $malware_pid ]];
    then
      ELEMENT=$(cat $dir/status | grep -w "Pid" | awk '{print $2}')
      child_id+="${ELEMENT} "
    fi
  fi
done

if [[ $child_id == "" ]];
then
  echo "not-found"
else
  echo $child_id
fi

#get parent id
parent_id=$(cat $2/$malware_pid/status | grep -w "PPid" | awk '{print $2}')
echo $parent_id

other_process=""
for dir in $path_to_proc/*
do
  check=0
  if [[ -d $dir ]];
  then
    if [[ -d $dir/fd/ ]];
    then
      if [[ $(ls $dir/fd/ | wc -l ) -ne 0 ]];
      then
        for file in $dir/fd/*
        do
          if [[ "$(ls -l $file | awk '{print $11}')" == *".txt" ]];
          then
            for malware_file in $path_to_proc/$malware_pid/fd/*
            do
              if [[ "$(ls -l $file | awk '{print $11}')" == "$(ls -l $malware_file | awk '{print $11}')" && $(echo ${dir} | tr "/" " " | rev | awk '{print $1}' | rev) -ne $malware_pid ]];
              then
                check=$(($check + 1))
              fi
            done
          fi
        done
      fi
    fi
    if [[ $check -ne 0 ]];
    then
      other_process+=" $(echo ${dir} | tr "/" " " | rev | awk '{print $1}' | rev)"
    fi
  fi
done

if [[ $other_process == "" ]];
then
  echo "not-found"
else
  echo $other_process
fi
