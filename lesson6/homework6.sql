# Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным 
# пользователем (написал ему сообщений).

SELECT firstname, lastname, id 
FROM users
WHERE id = (
	SELECT from_user_id 
	FROM messages 
	WHERE to_user_id = 1 
	GROUP BY from_user_id 
	HAVING COUNT(*) = (SELECT MAX(y.TIMES) 
					   FROM (SELECT COUNT(*) as TIMES
							FROM messages
							WHERE to_user_id = 1
							GROUP BY from_user_id ) as y ));

# Подсчитать общее количество лайков, которые получили пользователи младше 10 лет.

SELECT COUNT(*) as likes_under_10 from likes
WHERE user_id IN (SELECT user_id
FROM profiles
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 10);
								
# Определить кто больше поставил лайков (всего): мужчины или женщины.

SELECT gender, count(gender) as number_of_likes
FROM profiles
WHERE user_id IN (SELECT user_id FROM likes)
GROUP BY gender;


