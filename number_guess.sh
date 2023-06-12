#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

echo -e "\nEnter your username:"

while read ENTER_NAME
do 
  if [[ ${#ENTER_NAME} -gt 22 ]]
  then 
    echo "A username cannot have more than 22 characters."
  else
    break
  fi
done

USERNAME=$($PSQL "SELECT username FROM users WHERE username='$ENTER_NAME'")

if [[ -z $USERNAME ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$ENTER_NAME')")
  USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$ENTER_NAME'")
  echo "Welcome, $ENTER_NAME! It looks like this is your first time here."
  echo "Guess the secret number between 1 and 1000"
else
  USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  echo "Guess the secret number between 1 and 1000:"
fi

SECRET=$(( 1 + $RANDOM % 1000 ))
COUNT=1

while read GUESS
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $SECRET ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -eq $SECRET ]]
    then
      break
    fi
  fi  
  COUNT=$(( $COUNT + 1 ))
done

NEW_GAME=$($PSQL "INSERT INTO games(number_guesses, user_id) VALUES($COUNT, $USERNAME_ID)")

echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"






