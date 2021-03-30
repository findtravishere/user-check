#!/bin/bash
PATH=$PATH:/usr/sbin

LINE_NUM=0    # initializing line count
user="travis" # set [YOUR NAME] as username

if [ ! -f monitor.log ]; then # if monitor log does not exist, create monitor.log file in current directory
    touch monitor.log
    echo -e "I created a monitor.log file for you :D!\n"
fi

while true; do                                                                # while loop to reprompt
    read -p "Enter the path of the password file or press q/Q to quit: " FILE # reading input
    if [ -f "$FILE" ]; then                                                   # condition to check if input was correct and /etc/passwd exists
        echo -e "\n$FILE exists, retrieving your information!\n"              # shows that files exists
        while IFS=: read -r f1 f2 f3 f4 f5 f6 f7; do                          # read from /etc/passwd
            if [ "$f1" = "$user" ]; then
                found=true # if user was found, set state to true
                break
            else
                found=false # else state is false
            fi
        done <$FILE
    elif [ "$FILE" = "q" ] || [ "$FILE" = "Q" ]; then # if user enters q, it terminates the program
        echo "You quit the program!"
        break
    else
        echo "$FILE does not exist. Reprompting, please try again!" # prompts and restart user input if input is not /etc/passwd
        continue
    fi

    if [ -f "$FILE" ]; then
        echo "Current date and time: $(date +"%d-%m-%y:%H-%M")" >monitor.log                  # overwrites current date and time in log file, WILL NOT BE displayed on screen. use cat monitor.log to access it.
        if [ "$found" = true ]; then                                                          # if found state was true, user already exists
            echo -e "\nUser $user existed\n"                                                  # user existed is displayed if user already exists
        else                                                                                  # we create a new user
            adduser $user --disabled-password --shell /bin/bash --home /home/$user --gecos "" # create a new user and account
            password="123456"                                                                 # set default password
            echo "$user:$password" | chpasswd                                                 # change new user password
            echo -e "User $user successfully added with password set to $password!\n"
        fi
        while IFS=: read -r f1 f2 f3 f4 f5 f6 f7; do                      # read the fields in the file
            if [ "$f7" = "/bin/bash" ]; then                              # checks if user account is having shell of /bin/bash
                echo "Username: ${f1} | Home Folder: ${f6}"               # if true, display username and home folder
                echo "Username: ${f1} | Home Folder: ${f6}" >>monitor.log # appends output into log file
                ((LINE_NUM++))                                            # increase line count
            fi
        done <$FILE # run the program using file /etc/passwd as its stdin

        echo -e "\nNumber of users: ${LINE_NUM}"
        largest=$(cat $FILE | grep "/bin/bash" | cut -d : -f 3 | sort -nr | head -n 1) # sorts to get the largest user ID
        echo -e "\nLargest User ID: ${largest}\n"

        chown $user monitor.log # change ownership of log file to [YOUR NAME]
        chgrp $user monitor.log # change group to [YOUR NAME]
        chmod 640 monitor.log   # change permissions for user to read, write, group read, and others no permissions
        echo "Terminating program ... Goodbye!"
        break # exit the while loop
    fi
done
