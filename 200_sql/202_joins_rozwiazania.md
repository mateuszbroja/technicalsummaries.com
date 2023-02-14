# SQL ćwiczenia - JOINS
---
## JOINS - podstawowe

1. Dla każdego produktu, wyświetl jego kategorię.

2. Dla każdego produktu, wyświetl jego kategorię nawet jeśli jej nie ma. Zamiast pustej nazwy działu, wpisz słowo 'BRAK'.

```
ISNULL(Name, 'BRAK')
```

3. Dla każdego produktu, napisz jakie ma zapasy w każdym ze sklepów. Ogranicz wyniki tylko dla produktów z kategorii *Children Bicycles*. Wyświetl nazwę produktu, nazwę sklepu oraz ilość.

4. Wyświetl wszystkich klientów, którzy mieszkają w tym samym mieście, w którym są zlokalizowane sklepy.

5. Czy są takie lokalizacje sklepów, w których nie ma żadnych klientów?

6. Wyświetl pracowników, którzy mogą być również klientami sklepu. Zweryfikuj to po imieniu i nazwisku.

7. Wyświetl pracowników, którzy mogą być również klientami sklepu oraz klientów, którzy mogą być pracownikami. Zweryfikuj to po imieniu i nazwisku. Jeżeli pracownik nie jest klientem napisz w kolumnie z danymi klientami *BRAK* i tak samo zrób dla klientów.

8. Wyświetl wszystkich klientów, którzy złożyli zamówienia w 2016 roku.

9. Wyświetl nazwę klienta, który złożył zamówienie z najwyższą ceną pojedynczego produktu (z tabeli products).

10. Wyświetl imię, nazwisko, zarobki oraz nazwę działu dla pracownika, którego zarobki są najwyższe spośród wszystkich zatrudnionych.

```
SELECT TOP 1 FirstName, LastName, Salary, Name
FROM Employee
INNER JOIN Department ON Employee.DepartmentId = Department.Id
ORDER BY Salary DESC
```

11. Wyświetl nazwy wszystkich sklepów, w których przyjęto przynajmniej jedno zamówienie.

```
SELECT DISTINCT Name
FROM Employee
INNER JOIN Department ON Employee.DepartmentId = Department.Id
```