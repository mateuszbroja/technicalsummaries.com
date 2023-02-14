# 201. SQL ćwiczenia
---

## SELECT - podstawowe

1. Wyświetl dane wszystkich klientów.

2. Wyświetl wszystkie produkty, które kosztują więcej niż 1000 PLN.

3. Wyświetl wszystkie zamówienia, które zostały złożone po dniu 23 marca 2016 roku.

4. Wyświetl produkty marki 'Apple' laptopy, które kosztują pomiędzy 600 PLN, a 1200 PLN.

5. Dla każdego z produktów wyświetl aktualną cenę oraz cenę po podwyżce o 100 zł. Zamień nazwę obu kolumn na `aktualna_cena` oraz `cena_po_podwyzce`.

6. Wyświetl dane wszystkich produktów, które po podwyżce 15% będą kosztować więcej niż 6500 PLN.

7. Wyświetl produkty, które mają kategorię 'Laptops', 'Smartphones' lub 'Speakers'.

8. Znajdź wszystkich klientów, których nazwiska kończą się na literę 'n'. Posortuj ich alfabetycznie po imieniu.

9. Znajdź trzy produkty o najwyższej cenie.

10. Wyświetl dane 10% ze wszystkich produktów, które kosztują najmniej.

11. Wyświetl wszystkie unikalne nazwiska klientów.

12. Wyświetl wszystkich klientów, którzy nie mają numeru telefonu.

13. Dla każdego klienta wyświetl jego pierwsze imię i nazwisko, ale wyświetl je w jednej kolumnie.
---

## SELECT - funkcje wbudowane

Funkcje potrzebne do wykonania zadań:
- **YEAR** - zwracająca rok z podanej daty.
- **MONTH** — zwracająca miesiąc z podanej daty,
- **DAY** — zwracająca dzień z podanej daty,
- **DATEPART** — zwracająca wybrany składnik daty, w zależności od pierwszego parametru funkcji. Ten parametr może mieć następujące wartości:
	- year — zwraca rok, np. DATEPART(year, '2000-12-15') zwróci wartość 2000;
	- month — zwraca miesiąc, np. DATEPART(year, '2000-12-15') zwróci wartość 12;
	- day — zwraca dzień, np. DATEPART(year, '2000-12-15') zwróci wartość 15.
- **DATENAME** — zwracająca nazwę wybranego składnika daty, np.
	- DATENAME(month, '2000-12-15') — zwróci nazwę miesiąca z podanej daty, czyli grudnia (Nazwy zwracane są po angielsku! W tym wypadku będzie to więc December).
	- DATENAME(weekday, '2000-12-15') — zwróci nazwę dnia tygodnia z podanej daty, czyli piątku (ang. Friday).
- **GETDATE()** - wyświetla datę i godzinę teraźniejszą.
- **DATEDIFF** - oblicza, ile czasu minęło pomiędzy dwiema podanymi datami. Obliczany przedział czasu zależy od składnika czasu, który należy podać jako parametr funkcji:
	- year — liczy liczbę lat,
	- month — liczy liczbę miesięcy,
	- day — liczy liczbę dni,
	- hour — liczy liczbę godzin,
	- minute — liczy liczbę minut,
	- second — liczy liczbę sekund.
- **SUBSTRING** - zwraca podciąg danego ciągu (czyli łańcuch znaków zawarty w tym ciągu). Jako argumenty przyjmuje:
	- ciąg, którego część chcemy zwrócić,
	- liczbę oznaczającą początkowy znak, od którego ma się zaczynać podciąg,
	- liczbę znaków podciągu.
- **LEN** - zwraca liczbę znaków

1. Dla każdego zamówienia wyświetl `order_id` oraz rok, w którym zamówienie zostało złożone (`order_date`) i podpisz je jako *order_year*.

2. Dla każdego zamówienia wyświetl order_date oraz dzień tygodnia w którym zostało złożone (order_date). Wyświetl tylko aktywne zamówienia.

3. Wyświetl wszystkich pracowników urodzonych w 1990 roku. Napisz podane zapytania na 3 różne sposoby.

4. Wyświetl bieżącą datę i godzinę.

5. Wyświetl, ile lat minęło od daty 1 stycznia 1990 roku.

6. Dla każdego zamówienia wyświetl `order_id` oraz ile dni temu zostało zamówione.

7. Dla każdego pracownika wyświetl imię, nazwisko oraz inicjały.

8. Wypisz wszystkie zamówienia, które zostały złożone w styczniu lub w lutym.

9. Wypisz nazwę oraz liczbę liter w nazwie dla tych produktów, których nazwa ma 7 lub więcej znaków.

10. Wyświetl nazwy oraz długość tych nazw dla dwóch produktów, których nazwy są najdłuższe. Jeśli istnieje więcej produktów, które mają długość nazwy taką samą, jak tego produktu na drugim miejscu, również je uwzględnij.

11. Wyświetl wszystkie unikalne wartości długości połączonego imienia i nazwiska (razem z odstępem) klientów. Wyniki posortuj rosnąco według tych wartości.

12. Wyświetl produkty, które zostały już wysłane i dodaj kolumnę, która pokazuje ile dni zajęło pomiędzy złożeniem zamówienia, a wysłaniem produktów.
