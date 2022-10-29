#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to the Unicorn Beauty Salon ~~~~~\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nWe offer these services:\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME" | sed 's/ |//'
    done
  PICK_SERVICE
}

PICK_SERVICE() {
  echo -e "\n Enter a service id:\n"
  read SERVICE_ID_SELECTED 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$  ]]
  then
    SERVICES_MENU "Select one of the available services"
  else
    echo -e "\nEnter your phone number:\n"
    read CUSTOMER_PHONE
    #check if phone number exists
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
          # get new customer name
          echo -e "\nEnter your name:\n"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #get service time
    echo -e "\nEnter time of appointment:\n"
    read SERVICE_TIME
    
    #create appointment
    INSERT_APT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi


}

SERVICES_MENU