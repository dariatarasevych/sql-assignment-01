--створення таблиць для Бібліотеки
create table genres(
	genre_id serial primary key,
	genre_name varchar(255) not null
);

create table books(
	book_id serial primary key,
	title varchar(255) not null,
	author varchar(255),
	genre_id int,
	foreign key (genre_id) references genres(genre_id)
);

create table clients (
	client_id serial primary key,
	client_name varchar(255) not null,
	email varchar(255)
);

create table library_passes (
	pass_id serial primary key,
	client_id int,
	issue_date date not null,
	status varchar(100),
	foreign key (client_id) references clients(client_id)
);

create table loan_jornal (
	loan_id serial primary key,
	pass_id int,
	book_id int,
	loan_date date not null,
	return_date date,
	foreign key (pass_id) references library_passes (pass_id),
	foreign key (book_id) references books (book_id)
);

--Використала Gemini, щоб написати код для генерації даних в таблицях

-- 1. жанри
INSERT INTO genres (genre_name) VALUES 
('Fantasy'), ('Crime'), ('Romance'), ('Sci-Fi');

-- 2. книги
INSERT INTO books (title, author, genre_id)
SELECT 
    'Book Title №' || i,
    'Author Writer ' || (1 + FLOOR(RANDOM() * 50)),
    (SELECT genre_id FROM genres ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1, 2000) AS i;

-- 3. клієнти 10 тис.
INSERT INTO clients (client_name, email)
SELECT 
    'Library Reader ' || i,
    'reader_' || i || '@kse.ua'
FROM generate_series(1, 10000) AS i;

-- 4. пропуски
INSERT INTO library_passes (client_id, issue_date, status)
SELECT 
    client_id,
    '2026-01-01'::DATE + (RANDOM() * 100)::INT,
    CASE WHEN RANDOM() > 0.15 THEN 'Active' ELSE 'Expired' END
FROM clients;

-- 5. журнал видачі
INSERT INTO loan_jornal (pass_id, book_id, loan_date, return_date)
SELECT 
    (1 + FLOOR(RANDOM() * 10000)),
    (1 + FLOOR(RANDOM() * 2000)),
    '2026-03-01'::DATE + (RANDOM() * 90)::INT,
    CASE WHEN RANDOM() > 0.4 THEN '2026-03-01'::DATE + (RANDOM() * 90)::INT + 14 ELSE NULL END
FROM generate_series(1, 15000) AS i;



/*
 * Цей запит повертає топ-100 найпопулярніших книг за 2026 рік,
 * відсортованих за найбільшою кількістю видач у бібліотеці.
 */

--через CTE
--сортування where бере результати за 2026 рік
--limit : перші 100 книг

with top_popular_books_cte as (
	select 
		b.title,
		lj.loan_date 
	from loan_jornal lj 
	join library_passes lp on lj.pass_id = lp.pass_id 
	join clients c on lp.client_id = c.client_id 
	join books b on lj.book_id  = b.book_id 
	join genres g on b.genre_id  = g.genre_id 
)
select 
	title,
	count(*) as total_loans_per_book
from top_popular_books_cte 
where loan_date >= '2026-01-01' AND loan_date <= '2026-12-31'
group by title 
order by total_loans_per_book desc
limit 100;
