#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c "
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo -e "\nEnter your username:"
read USERNAME
USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "insert into users (name) values ('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "select count(*) from games where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select min(guesses) from games where user_id=$USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GUESS_NUMBER() {
  if [[ ! $1 ]]
  then
    echo -e "\nGuess the secret number between 1 and 1000:"
  else
    echo -e "\n$1"
  fi
  read GUESSED_NUMBER
}

GUESS_NUMBER
NUMBER_OF_GUESSES=1

until [[ $GUESSED_NUMBER == $SECRET_NUMBER ]]
do
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]*$ ]]
    then GUESS_NUMBER "That is not an integer, guess again:"
    elif (( $GUESSED_NUMBER > $SECRET_NUMBER ))
      then 
        (( NUMBER_OF_GUESSES++ ))
        GUESS_NUMBER "It's lower than that, guess again:"
      elif (( $GUESSED_NUMBER < $SECRET_NUMBER ))
        then 
          (( NUMBER_OF_GUESSES++ ))
          GUESS_NUMBER "It's higher than that, guess again:"
  fi
done

INSERT_GAME_RESULT=$($PSQL "insert into games (user_id, guesses) values ($USER_ID, $NUMBER_OF_GUESSES)")
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
