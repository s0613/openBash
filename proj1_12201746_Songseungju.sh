#!/bin/bash

    clear
    echo "---------------------------"
    echo "User name: SongSeungJu"
    echo "Student Number: 12201746"
    echo "[ Menu ]"
    echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
    echo "2. Get the data of action genre movies from 'u.item'"
    echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
    echo "4. Delete the 'IMDb URL' from 'u.item'"
    echo "5. Get the data about users from 'u.user'"
    echo "6. Modify the format of 'release date' in 'u.item'"
    echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
    echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 'occupation' as 'programmer'"
    echo "9. Exit"
    echo "---------------------------"
    
stop="N"
until [ "$stop" = "Y" ]
do
    read -p  "Enter your choice [ 1 - 9 ] " num

    case "$num" in

        1)
            read -p "Please enter 'movie id' (1~1682): " inum
            echo ""
            data=$(awk -F'|' -v movie_id="$inum" '$1 == movie_id { print $0 }' u.item)
            
            echo "$data"
            echo 
            ;;
        2)
            echo ""
            read -p "Do you want to get data of 'action' genre movies from 'u.item'?(y/n): " ans
            if [ "$ans" = "y" ]; then
                echo " "
                action_movies=$(awk -F'|' '$7 == 1' u.item | sort -t'|' -k1,1n | head -n 10)

                echo "Top 10 Action Genre Movies:"
                echo "$action_movies"  
            fi       
            ;;
        3)
            echo ""
            read -p "Please enter the 'movie id'( 1 ~ 1682 ):" sam
            echo ""
            rating=$(awk -v movie_id="$sam" '$2 == movie_id { sum += $3; count++ } END { if (count > 0) print sum / count }' u.data)

            if [ -n "$rating" ]; then
                round=$(printf "%.5f" $rating)
                echo "average rating of $sam: $round"
                echo ""
            fi
            ;;
        4)
            read -p "Do you want to delete the 'IMDb URL' from 'u.item'? (y/n)" ans
            if [ "$ans" = "y" ]; then
                head -n 10 u.item | sed 's/\(.*\)http[^|]*\(.*\)/\1\2/'
            fi
            ;;
        5)
            read -p "Do yor want to get the data about users from 'u.user'?(y/n)" ans
            if [ "$ans" = "y" ]; then
                head -n 10 u.user | awk -F'|' '{ printf "User %s is %s years old %s %s\n", $1, $2, $3, $4 }'

            fi
            ;;
        6)
            read -p "Do yor want to Modify the format of 'release data' in 'u.item'?(y/n)" ans
            if [ "$ans" = "y" ]; then
                sed -E 's/([0-9]+)-([A-Za-z]+)-([0-9]+)/\3\2\1/' u.item | sed -E 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | tail -n 10

            fi
            ;;
        7)
            read -p "Please enter the 'user id' (1~943): " user_id

            movies=$(awk -F'\t' -v user_id="$user_id" '$1 == user_id { print $2 }' u.data | sort -n)
            echo "$movies" | tr '\n' '|' | sed 's/|$//'
            echo
            top_10_movies=$(echo "$movies" | head -n 10)

            for movie_id in $top_10_movies; do
            movie_title=$(awk -F'|' -v movie_id="$movie_id" '$1 == movie_id { print $2 }' u.item)
            echo "$movie_id | $movie_title"
            done
            

            ;;
        8)
            read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n) " ans

            if [ "$ans" = "y" ]; then
                for movie_id in {1..1682}; do
                    user_ratings=$(awk -F'\t' -v movie_id="$movie_id" '$2 == movie_id { print $3 }' u.data)

                    if [ -n "$user_ratings" ]; then
                        user_ids=$(awk -F'\t' -v movie_id="$movie_id" '$2 == movie_id { print $1 }' u.data)
                        
                        total_rating=0
                        num_ratings=0

                        for user_id in $user_ids; do
                            user_age=$(awk -F'|' -v user_id="$user_id" '$1 == user_id { print $2 }' u.user)
                            user_occupation=$(awk -F'|' -v user_id="$user_id" '$1 == user_id { print $4 }' u.user)
                            
                            if [ "$user_age" -ge 20 ] && [ "$user_age" -le 29 ] && [ "$user_occupation" == "programmer" ]; then
                                user_rating=$(awk -F'\t' -v movie_id="$movie_id" -v user_id="$user_id" '$2 == movie_id && $1 == user_id { print $3 }' u.data)
                                total_rating=$(echo "scale=6; $total_rating + $user_rating" | bc)
                                num_ratings=$((num_ratings + 1))
                            fi
                        done
                        
                        if [ "$num_ratings" -gt 0 ]; then
                            average_rating=$(echo "scale=6; $total_rating / $num_ratings" | bc) 
                            
                            average_rating=$(printf "%.6f" "$average_rating")
                            
                            echo "$movie_id $average_rating"
                        fi
                    fi
                done
            fi
            ;;
        9) stop="Y"
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
done
