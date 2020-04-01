#!/bin/bash

list_users=$(cat users.json)

for user_data in $(echo "$list_users" | jq -c .[]); do

	user_name=$(echo $user_data | jq -r '.user')
	user_psw=$(echo $user_data | jq -r '.psw')
	user_group=$(echo $user_data | jq -r '.group')

	egrep -c "^$user_name" /etc/passwd >/dev/null
	if [ $? -eq 0 ];then
		echo "ERR: $user_name ya existe"
		continue
	else
		useradd -m -p "$user_psw" "$user_name"
		if [ $? -eq 0 ];then
			echo "$user_name creado correctamente"

			grep -q "$user_group" /etc/group >/dev/null
			if [ $? -ne 0 ];then
				groupadd "$user_group"
			fi

			usermod -a -G "$user_group" "$user_name"
			if [ $? -eq 0 ];then
				echo "$user_name añadido correctamente a $user_group \n"
			fi

		fi

	fi
done
