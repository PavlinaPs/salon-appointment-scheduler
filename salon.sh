#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n*** Beauty Salon ***\n"
echo "Hello! Welcome."

MAIN_MENU() {
# if the functin has an argument, print it
if [[ $1 ]]
  then
  echo -e "\n$1\n"
fi

echo -e "What can we do for you today?\n"

# get a list of available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

# display available services
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
do
  echo "$SERVICE_ID) $SERVICE"
done

# ask to select a service
read SERVICE_ID_SELECTED

# selected service doesn't exist
# TODO create array of service_id s and check if present
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  # show the list again
  MAIN_MENU "Ops, please enter a valid service number."
else
  # service name selected
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  # get customer's info
  echo -e "\nPlease enter your phone number."
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if customer doesn't exist in the database
  if [[ -z $CUSTOMER_NAME ]]
  then
  # get the name of the new customer
  echo -e "\nEnter your name please."
  read CUSTOMER_NAME

  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  

  # get time of the appointment
  echo -e "\nPlease enter desired time of your appointment.\nWe are in from 10AM, last appointment at 6PM."
  read SERVICE_TIME

  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  # inform customer
  SERVICE_NAME_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g')
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
fi
}

MAIN_MENU