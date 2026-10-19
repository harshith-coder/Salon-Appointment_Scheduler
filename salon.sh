#! /bin/bash

PSQL="psql -X --username=postgres --dbname=salon --tuples-only --no-align --quiet"

sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"
echo

SERVICES="1) cut
2) color
3) perm"

display_services() {
  printf "%s\n" "$SERVICES"
}

display_services
read SERVICE_ID_SELECTED

while true; do
  SERVICE_NAME=$(printf "%s\n" "$SERVICES" | awk -F') ' -v service_id="$SERVICE_ID_SELECTED" '$1 == service_id {print $2}')

  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  echo
  echo "I could not find that service. What would you like today?"
  display_services
  read SERVICE_ID_SELECTED
done

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_PHONE_SQL=$(sql_escape "$CUSTOMER_PHONE")
CUSTOMER_RECORD=$($PSQL -c "SELECT customer_id || '|' || name FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL';")
IFS='|' read -r CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_RECORD"

if [[ -z "$CUSTOMER_ID" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME_SQL=$(sql_escape "$CUSTOMER_NAME")
fi

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

SERVICE_TIME_SQL=$(sql_escape "$SERVICE_TIME")
if [[ -z "$CUSTOMER_ID" ]]; then
  $PSQL -c "WITH new_customer AS (INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE_SQL', '$CUSTOMER_NAME_SQL') RETURNING customer_id) INSERT INTO appointments(customer_id, service_id, time) SELECT customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL' FROM new_customer;"
else
  $PSQL -c "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL');"
fi

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
