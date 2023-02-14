# SQL ćwiczenia - JOINS
---
## JOINS

1. Dla każdego produktu, wyświetl jego kategorię.

2. Dla każdego produktu, wyświetl jego kategorię nawet jeśli jej nie ma. Zamiast pustej nazwy działu, wpisz słowo 'BRAK'. Użyj `ISNULL(Name, 'BRAK')`.

3. Dla każdego produktu, napisz jakie ma zapasy w każdym ze sklepów. Ogranicz wyniki tylko dla produktów z kategorii *Children Bicycles*. Wyświetl nazwę produktu, nazwę sklepu oraz ilość.

4. Wyświetl wszystkich klientów, którzy mieszkają w tym samym mieście, w którym są zlokalizowane sklepy.

5. Czy są takie lokalizacje sklepów, w których nie ma żadnych klientów?

6. Wyświetl pracowników, którzy mogą być również klientami sklepu. Zweryfikuj to po imieniu i nazwisku.

7. Wyświetl pracowników, którzy mogą być również klientami sklepu oraz klientów, którzy mogą być pracownikami. Zweryfikuj to po imieniu i nazwisku. Jeżeli pracownik nie jest klientem napisz w kolumnie z danymi klientami *BRAK* i tak samo zrób dla klientów.

8. Wyświetl wszystkich klientów, którzy złożyli zamówienia w 2016 roku.

9. Wyświetl nazwę klienta, który złożył zamówienie z najwyższą ceną pojedynczego produktu (z tabeli products).

10. Wyświetl imię, nazwisko, zarobki oraz nazwę działu dla pracownika, którego zarobki są najwyższe spośród wszystkich zatrudnionych.

11. Wyświetl nazwy wszystkich sklepów, w których przyjęto przynajmniej jedno zamówienie.

12. Wyświetl order_id oraz kategorię produktów, które zostały zawarte w danym zamówieniu. Pokaż to zamówienie, które zostało najszybciej wysłane przez sklep. Ogranicz wyniki tylko dla zamówień w sklepie o nazwie *Santa Cruz Bikes*.

13. Znajdź pracowników, których pierwsza litera imienia jest taka sama jak nazwa miasta, w którym znajduje się sklep, w którym przyjęli zamówienia.

14. Wyświetl wszystkie możliwe kombinacje imion i nazwisk, które można wygenerować dla danych znajdujących się w tabeli `staff`.

15. Dla każdego miasta z tabeli `sales.stores` wyświetl te miasta, które w kolejności alfabetycznej znajdują się za danym miastem (niełatwe).