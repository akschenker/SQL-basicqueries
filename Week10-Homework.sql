-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT (first_name, " ", last_name) AS `Actor Name`
FROM actor;

	-- NOTE: if wanting to then update the actor table to add this column: 
		-- ALTER TABLE actor
		-- ADD `Actor Name` VARCHAR(100);

		-- UPDATE actor
		-- SET `Actor Name` = CONCAT(first_name, " ", last_name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT *
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT *
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT *
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS name_count
FROM actor 
GROUP BY last_name
ORDER BY last_name ASC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS name_count
FROM actor 
GROUP BY last_name
HAVING COUNT(last_name) >= 2
ORDER BY last_name ASC;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html



-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.staff_id, first_name, last_name, SUM(amount) AS total
FROM staff
JOIN (SELECT * 
	  FROM payment
      WHERE payment_date LIKE "2005-08%"
      ) AS aug_payments
 ON staff.staff_id = aug_payments.staff_id
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.film_id, title, COUNT(*) AS num_actors
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id
ORDER BY title ASC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) AS hunch_copies
FROM inventory
WHERE film_id = 
	(SELECT film_id
	FROM film
	WHERE title = "HUNCHBACK IMPOSSIBLE"
	);

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) AS total_paid
FROM payment
JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY last_name ASC;

--     ![Total amount paid](Images/total_payment.png)

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM (
	SELECT *
	FROM film
	WHERE language_id = (
		SELECT language_id
		FROM language
		WHERE name = "English"
		)
	) AS english_films
WHERE (title LIKE "K%") OR (title LIKE "Q%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id = (
		SELECT film_id
		FROM film
		WHERE title = "ALONE TRIP"
		)
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
	SELECT address_id
	FROM address
	WHERE city_id IN (
		SELECT city_id
		FROM city
		WHERE country_id = (
			SELECT country_id
			FROM country
			WHERE country = "Canada")
		)
	);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id = (
		SELECT category_id
		FROM category
		WHERE name = "Family")
	);

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, rental_agg.num_rentals
FROM film
JOIN (
	SELECT inventory_rental.film_id, 
		   COUNT(inventory_rental.rental_id) AS num_rentals
	FROM (
		SELECT rental.rental_id, rental.inventory_id, inventory.film_id
		FROM rental
		JOIN inventory ON inventory.inventory_id = rental.inventory_id
		) AS inventory_rental
	GROUP BY inventory_rental.film_id
	) AS rental_agg
ON film.film_id = rental_agg.film_id
ORDER BY rental_agg.num_rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id AS store_num, 
	   CONCAT("$", FORMAT(SUM(amount), 2)) AS total_profit
FROM payment
WHERE staff_id IN (
	SELECT staff.staff_id
	FROM store
	JOIN staff ON staff.store_id = store.store_id
	)
GROUP BY staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT cities.address_id AS store_id, cities.city, country.country
FROM (
	SELECT stores.address_id, stores.city_id, city, country_id
	FROM (
		SELECT store.address_id, address.city_id
		FROM store
		LEFT JOIN address ON store.address_id = address.address_id
		) AS stores
	LEFT JOIN city ON stores.city_id = city.city_id
	) AS cities
JOIN country ON country.country_id = cities.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, 
	   CONCAT("$", FORMAT(SUM(payment.amount), 2)) AS revenue
FROM category, film_category, inventory, rental, payment
WHERE (category.category_id = film_category.category_id) AND
	  (film_category.film_id = inventory.film_id) AND
	  (inventory.inventory_id = rental.inventory_id) AND
	  (rental.rental_id = payment.rental_id)
GROUP BY category.name
ORDER BY revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT category.name, 
	   CONCAT("$", FORMAT(SUM(payment.amount), 2)) AS revenue
FROM category, film_category, inventory, rental, payment
WHERE (category.category_id = film_category.category_id) AND
	  (film_category.film_id = inventory.film_id) AND
	  (inventory.inventory_id = rental.inventory_id) AND
	  (rental.rental_id = payment.rental_id)
GROUP BY category.name
ORDER BY revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS sakila.top_five_genres;

