#!/bin/bash/
#read and check usernames
function usernames {
  for (( count=$(($count+1)) ; $count < $len; count++ )); do
    if [ "-g" = ${arr[$count]} ] || [ "-h" = ${arr[$count]} ]; then
	    count=$(($count-1))
      return
    fi
    local name=${arr[$count]}
    if [ `getent passwd $name` ]; then
      echo "the user $name has already been created."
    else
      arr2[${#arr2[*]}]=$name
    fi
  done
}
#read and then will be create groups
function usergroups {
  for (( count=$(($count+1)) ; $count < $len; count++ )); do
    if [ "-u" = ${arr[$count]} ] || [ "-h" = ${arr[$count]} ]; then
      count=$(($count-1))
      return
    fi
    local gr=${arr[$count]}
    if [ ! `getent group $gr` ]; then
      echo "will be cretaing group $gr."
      groupadd $gr
    fi
    local idx=${#arr3[*]}
    arr3[$idx]=$gr
  done
  return
}

if [ $# -le 1 ]; then
  echo "not have arguments..."
  echo "-u user1 [userN] -g group1 [groupN] -h hashpass"
  echo "OR"
  echo "-o filename"
  exit -1
fi
# newuser file.txt
if [ "-o" = $1 ]; then
  # newusers $2
  # if [ $? -eq 0 ]; then
  if [ newusers $2 ]; then
    exit 0
  else
    exit -2
  fi
fi

arr=( $@ )
len=${#arr[*]}
count=0;
for (( ; $count < $len; count++ )); do
  if [ "-u" = ${arr[$count]} ]; then
    usernames
  elif [ "-g" = ${arr[$count]} ]; then
    usergroups
  elif [ "-h" = ${arr[$count]} ]; then
   count=$(($count + 1))
   userhash=${arr[$count]}  
  fi
done

echo "${arr[*]}"
echo "Reads users:${arr2[*]}"
echo "Reads groups:${arr3[*]}"
echo "hash:$userhash"

for name in ${arr2[*]}; do
  `which useradd` -m -s /bin/bash -G `echo ${arr3[*]} | sed 's/ /,/g'` -c 'script created user on '`date +"%m-%d-%y"` $name 
  echo "useradd -m -s /bin/bash -G `echo ${arr3[*]} | sed 's/ /,/g'` -c 'scripted created user on date +%m-%d-%y' $name" 
  echo ">>>"
  #echo "2hash:$userhash" 

  #str="/$name/s/!!/"

  str=$(echo $userhash | sed 's/\$/\\$/g; s/\//\\\//g' )

  echo "/$name/s/!!/$str"

  echo ">>>"
  echo "/^${name}/s/${name}::/${name}:${str}:/"
  sed -i "/^${name}/s/!!/${str}/; /^${name}/s/${name}::/${name}:${str}:/" /etc/shadow
done
exit 0
