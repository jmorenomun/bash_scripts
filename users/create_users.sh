#!/bin/bash

list_users=$(cat users.json)

for user_data in $(echo "$list_users" | jq -c .[]); do

	user_name=$(echo $user_data | jq -r '.user')
	user_psw=$(echo $user_data | jq -r '.psw')
	user_group=$(echo $user_data | jq -r '.group')

	# Comprueba que existe el grupo o lo crea
	grep -q "$user_group" /etc/group >/dev/null
	if [ $? -ne 0 ];then
		groupadd "$user_group"
	fi

	# Comprueba que no exista previamente el usuario
	egrep -c "^$user_name" /etc/passwd >/dev/null
	if [ $? -eq 0 ];then
		echo "ERR: $user_name ya existe"
		continue
	else
		# Crea usuario asignando grupo primario
		useradd -g "$user_group" -p "$user_psw" "$user_name"
		if [ $? -eq 0 ];then
			echo "$user_name creado correctamente"
			echo $(groups "$user_name")
			echo ""
		fi
	fi
done
