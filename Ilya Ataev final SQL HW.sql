-- Создаем БД и пользователя
CREATE USER eliataev WITH PASSWORD 'netology';
CREATE DATABASE finalsql;
GRANT ALL PRIVILEGES ON DATABASE finalsql TO eliataev;

-- Создаем таблицы
CREATE TABLE vendors(id INT PRIMARY KEY UNIQUE, vendorname VARCHAR, vendorcity VARCHAR);
CREATE TABLE articles(id BIGINT PRIMARY KEY UNIQUE, vendorid INT references vendors(id), commdir VARCHAR, artweight REAL, artcost REAL);
CREATE TABLE stores(id INT PRIMARY KEY UNIQUE, stcity VARCHAR, staddr VARCHAR);
CREATE TABLE sales(id BIGINT PRIMARY KEY UNIQUE, artid INT references articles(id), gain REAL, storeid INT references stores(id), saledate DATE);

-- Импортируем данные в таблицы из csv файлов.

-- SQL ЗАПРОСЫ

-- 1 Посчитаем количество продаж на 1 октября.
SELECT COUNT(id) FROM sales WHERE saledate = '2018-10-01';

-- 2 Посчитаем количество товаров с весом больше 5 грамм.
SELECT COUNT(id) as HIGHWEIGHT FROM articles WHERE artweight > 5;

-- 3 10 самых прибыльных товаров.
SELECT artid, AVG(gain) AS Overall FROM sales GROUP BY artid ORDER BY Overall DESC LIMIT 10;

-- 4 Найдем поставщика с максимальным количеством позиций в справочнике товаров.
SELECT vendorid, COUNT(id) AS Positions FROM articles GROUP BY vendorid ORDER BY Positions DESC LIMIT 1;

-- 5 Высяним самое продаваемое товарное направление.
WITH tmptbl AS (SELECT * FROM sales JOIN articles ON sales.artid = articles.id) SELECT DISTINCT commdir, COUNT(gain) AS Overall FROM tmptbl GROUP BY commdir ORDER BY Overall LIMIT 1;

-- 6 Посмотрим, есть ли товары с суммарной выручкой больше 100000.
SELECT DISTINCT artid, SUM(gain) as Totalgain FROM sales GROUP BY artid HAVING SUM(gain) > 100000;

-- 7 Отcортируем города по средней выручке.
WITH tmptbl AS (SELECT gain, storeid, stcity FROM sales JOIN stores ON sales.storeid = stores.id) SELECT DISTINCT stcity, AVG(gain) as AverageGAin FROM tmptbl GROUP BY stcity ORDER BY AverageGAin;

-- 8 Отранжируем товары по выручке
SELECT artid, SUM(gain) AS SuperSum, DENSE_RANK() OVER (PARTITION BY artid ORDER BY SUM(gain)) simplerank FROM sales GROUP BY artid ORDER BY SuperSum DESC;

-- 9 Посчитаем среднюю цену за грамм для каждого товара по всем продажам
WITH tmptbl AS (SELECT artid, AVG(gain) OVER (PARTITION BY artid) as AVGGAIN, artweight FROM sales JOIN articles ON sales.artid=articles.id) SELECT artid, AVGGAIN / artweight as AVGCOST FROM tmptbl ORDER BY AVGCOST DESC;

-- 10 Найдем самыe дорогие товары проданные в каждом магазине
SELECT artid, storeid, MAX(gain) OVER (PARTITION BY storeid) TOPGAIN FROM (SELECT DISTINCT artid, storeid, gain FROM sales) as finaltable ORDER BY storeid ASC;