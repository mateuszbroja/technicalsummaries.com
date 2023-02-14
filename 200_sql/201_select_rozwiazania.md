# 201. SQL rozwiązania
---

## SELECT podstawowe

1. Wyświetl dane wszystkich klientów.

```sql
SELECT *
FROM sales.customers;
```

2. Wyświetl wszystkie produkty, które kosztują więcej niż 1000 PLN.

```sql
SELECT *
FROM sales.products
WHERE price > 1000;
```

3. Wyświetl wszystkie zamówienia, które zostały złożone po dniu 23 marca 2016 roku.

```sql
SELECT *
FROM sales.orders
WHERE order_date > '2016-03-23';
```

4. Wyświetl produkty marki 'Apple' laptopy, które kosztują pomiędzy 600 PLN, a 1200 PLN.

```sql
SELECT *
FROM sales.products
WHERE (price BETWEEN 600 AND 1000) AND brand = 'Apple';
```

5. Dla każdego z produktów wyświetl aktualną cenę oraz cenę po podwyżce o 100 PLN. Zamień nazwę obu kolumn na `aktualna_cena` oraz `cena_po_podwyzce`.

```sql
SELECT product_name, price as 'aktualna_cena', price + 100 as 'cena_po_podwyzce'
FROM sales.products;
```

6. Wyświetl dane wszystkich produktów, które po podwyżce 15% będą kosztować więcej niż 6500 PLN.

```sql
SELECT *, price * 1.15 as 'cena_po_podwyzce'
FROM sales.products
WHERE price * 1.15 > 6500;
```

7. Wyświetl dane z tabeli `sales.categories`, które mają nazwę kategorii 'Laptops', 'Smartphones' lub 'Speakers'.

```sql
SELECT *
FROM sales.categories
WHERE category_name IN ('Laptops', 'Smartphones', 'Speakers');
```

8. Znajdź wszystkich klientów, których nazwiska kończą się na literę 'n'. Posortuj ich alfabetycznie po imieniu.

```sql
SELECT *
FROM sales.customers
WHERE last_name LIKE '%n'
ORDER BY first_name;
```

9. Znajdź trzy produkty o najwyższej cenie.

```sql
SELECT TOP(3) *
FROM sales.products
ORDER BY price DESC;
```

10. Wyświetl dane 10% ze wszystkich produktów, które kosztują najmniej.

```sql
SELECT TOP(10) PERCENT *
FROM sales.products
ORDER BY price;
```

11. Wyświetl wszystkie unikalne nazwiska klientów.

```sql
SELECT DISTINCT last_name
FROM sales.customers;
```

12. Wyświetl wszystkich klientów, którzy nie mają numeru telefonu.

```sql
SELECT *
FROM sales.customers
WHERE phone_number IS NULL;
```

13. Dla każdego klienta wyświetl jego pierwsze imię i nazwisko, ale wyświetl je w jednej kolumnie.

```sql
SELECT first_name + ' ' + last_name as full_name
FROM sales.customers;
```
---

## SELECT - funkcje wbudowane

1. Dla każdego zamówienia wyświetl `order_id` oraz rok, w którym zamówienie zostało złożone (`order_date`) i podpisz je jako *order_year*.

```sql
SELECT order_id, YEAR(order_date) as 'order_year'
FROM sales.orders
```

2. Dla każdego zamówienia wyświetl order_date oraz dzień tygodnia w którym zostało złożone (order_date). Wyświetl tylko aktywne zamówienia.

3. Wyświetl wszystkich pracowników urodzonych w 1990 roku. Napisz podane zapytania na 3 różne sposoby.

```sql
SELECT *
FROM Employee
WHERE YEAR(BirthDate) = 1990
SELECT *
FROM Employee
WHERE BirthDate >= '1990-1-1'
AND BirthDate < '1991-1-1'
```


4. Wyświetl bieżącą datę i godzinę.

```sql
SELECT GETDATE() as 'Teraz'
```

5. Wyświetl, ile lat minęło od daty 1 stycznia 1990 roku.

```sql
SELECT DATEDIFF(year, '1990-01-01', GETDATE()) as IleLat
```

6. Dla każdego zamówienia wyświetl `order_id` oraz ile dni temu zostało zamówione.

```sql
SELECT
FirstName,
LastName,
DATEDIFF(yy, BirthDate, GETDATE()) as Wiek
FROM Employee
```

7. Dla każdego pracownika wyświetl imię, nazwisko oraz inicjały.

```sql
SELECT
FirstName as 'Imię',
LastName as 'Nazwisko',
SUBSTRING(FirstName, 1, 1) as 'Pierwsza litera imienia',
SUBSTRING(LastName, 1, 1) as 'Pierwsza litera nazwiska'
FROM Employee
```


8. Wypisz wszystkie zamówienia, które zostały złożone w styczniu lub w lutym.

```sql
SELECT *
FROM Company
WHERE MONTH(StartDate) IN (1,2)
AND Active = 1
```

9. Wypisz nazwę oraz liczbę liter w nazwie dla tych produktów, których nazwa ma 7 lub więcej znaków.

```sql
SELECT Name, LEN(Name) as LiczbaLiter
FROM Company
WHERE LEN(Name) >= 8
```

10. Wyświetl nazwy oraz długość tych nazw dla dwóch produktów, których nazwy są najdłuższe. Jeśli istnieje więcej produktów, które mają długość nazwy taką samą, jak tego produktu na drugim miejscu, również je uwzględnij.

```sql
SELECT TOP 2 WITH TIES Name, LEN(Name) as Dlugosc
FROM Company
ORDER BY LEN(Name) DESC
```


11. Wyświetl wszystkie unikalne wartości długości połączonego imienia i nazwiska (razem z odstępem) klientów. Wyniki posortuj rosnąco według tych wartości.

```sql
SELECT DISTINCT LEN(Name) as Dlugosc
FROM Company
ORDER BY LEN(Name)
```


12. Wyświetl produkty, które zostały już wysłane i dodaj kolumnę, która pokazuje ile dni zajęło pomiędzy złożeniem zamówienia, a wysłaniem produktów.