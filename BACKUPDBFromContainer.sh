#!/bin/bash

read -p "Select your option number:
(1) BACKUP DB From Container
(2) RESTORE DB From Container
(3) BACKUP DB local
(4) RESTORE DB local
Enter your option: " option

read -p "Enter your database Name: " DATABASE
read -p "Enter your Host: " HOST
read -p "Enter your Port: " PORT
read -p "Enter your Username: " USERNAME
read -p "Enter your Password: " PASSWORD

MY_SQL_DUMP=/usr/bin/mysqldump

if [ "$option" == "1" ]; then
read -p "Enter your Container Name or ID: " Container
docker exec "$Container" "$MY_SQL_DUMP" -u "$USERNAME" --password="$PASSWORD" "$DATABASE" > "$DATABASE.sql"
elif [ "$option" == "2" ]; then
read -p "Enter your Container Name or ID: " Container
read -p "Enter your Restore-File-Path: " PATH
cat "$PATH.sql" | docker exec -i "$Container" "$MY_SQL_DUMP" -u "$USERNAME" --password="$PASSWORD" "$DATABASE"
elif [ "$option" == "3" ]; then
sudo "$MY_SQL_DUMP" -u "$USERNAME" -p"$PASSWORD" -P "$PORT" --host="$HOST" "$DATABASE" > "$DATABASE.sql"
elif [ "$option" == "4" ]; then
read -p "Enter your Restore-File-Path: " PATH
sudo "$MY_SQL_DUMP" -u "$USERNAME" -P "$PORT" -p"$PASSWORD" "$DATABASE" < "$PATH.sql"
else
echo "Invalid option selected."
fi