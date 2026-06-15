Analiza opcji egzotycznej i porównanie metod
================

## 1.1. Wstęp i cel

Faktycznym celem projektu było praktyczne zderzenie teoretycznego modelu
wyceny z surowymi danymi rynkowymi dla instrumentu o ekstremalnej
zmienności. Zamiast opierać się na wyidealizowanych założeniach i
sztucznie wygenerowanych parametrach, wykonaliśmy następujący,
czteroetapowy proces weryfikacyjny:

- Ekstrakcja i kalibracja danych: Pobraliśmy rzeczywiste szeregi czasowe
  z ostatnich dwóch lat dla akcji Tesla (TSLA) i na ich podstawie
  wyestymowaliśmy historyczną zmienność logarytmicznych stóp zwrotu,
  która stanowiła główny parametr wejściowy symulacji.

- Implementacja silnika Monte Carlo: Zaprogramowaliśmy od podstaw
  generator trajektorii cen oparty na stochastycznym modelu
  Geometrycznego Ruchu Browna (GBM). W celu optymalizacji i zmniejszenia
  błędu standardowego, zastosowaliśmy technikę redukcji wariancji
  (zmienne antytetyczne).

- Modelowanie struktury wypłaty: Zdefiniowaliśmy warunki brzegowe dla
  europejskiej opcji korytarzowej typu Asset-or-Nothing (z barierą dolną
  na poziomie 85% i górną 115% bieżącej ceny akcji), która wygasa bez
  wartości, jeśli cena końcowa znajdzie się poza tym przedziałem.

- Walidacja krzyżowa (Cross-validation): Skonfrontowaliśmy wynik
  uzyskany na drodze symulacji numerycznej ze ścisłym rozwiązaniem
  analitycznym, bazującym na rozszerzeniach modelu Blacka-Scholesa dla
  opcji egzotycznych.

## 1.2. Dla kogo?

- **Analityków finansowych**: **Quants** - Najważniejsza grupa, która
  charakteryzuje się budową modeli matematycznych, które dzięki pomocy
  R/Python wyceniają instrumenty finansowe. Wymagane umiejętnośći to:
  Implementacja wzorów, stworzenie symulacji i techniki optymalizacji.
  Podobnie projket ma zastosowanie dla specjalistów zarządzania
  ryzykiem, którzy muszą rozumieć co sie stanie z portfelem gdy rynek
  oszaleje. Dodatkowo badanie dla ryzyka ma za zadanie wykazanie
  trudności w Hedingu opcji “All or nothing” Projekt również może
  pasować dla Traderów (wycena) oraz studentów (nauka)

## 1.3. Dlaczego Tesla?

Tesla charakteryzuje się wysoką zmiennością historyczną i brakiem wypłat
dywidendy. Stanowi to doskonałe środowisko do testowania wrażliwości
modelu korytarzowego. Wysoka dynamika zmian cen drastycznie zwiększa
prawdopodobieństwo wyjścia kursu poza ustalony przedział, co z kolei
powinno znaleźć odzwierciedlenie w relatywnie niskiej premii za opcję.

**Charakterystyka opcji**

- **Instrument bazowy:** Akcje Tesla (TSLA).
- **Warunek wypłaty:** Opcja wypłaca wartość ceny akcji ($S_T$) w dacie
  wygaśnięcia $T$, jeżeli $X_L < S_T < X_U$.
- **Wypłata zerowa:** W przypadku wyjścia ceny poza ustalony korytarz,
  opcja wygasa bez wartośći.

# 2. Pobieanie danych i estymacja parametrów.

W tej sekcji skrypt automatycznie pobiera dane historyczne dla spółki
Tesla.

**Zestawienie parametrów na dzień 2026-05-05**

- Cena instrumentu ($S_0$): 389.37 USD
- Stopa proc.(r): 5.28%
- Zmienność ($\sigma$): 60.32%
- Przedział korytarza: \[330.96, 447.78\] USD -

# 3. Symulacja Monte Carlo

Podstawą symulacji numerycznej jest model Geometrycznego Ruchu Browna
(GBM), który zakłada log-normalny rozkład stóp zwrotu **Optymalizacja
obliczeń** Aby zmniejszyć błąd standardowy bez konieczności drastycznego
zwiększania liczby iteracji, zastosowano technikę zmiennych odbić
lustrzanych. Polega ona na tym, że dla każdego wylosowanej trajektori
Rstudio generuje jego dokładne przeciwieństwo (zmienia znak). Pozwala to
ustabilizować symetrię rozkładu i zwiększa dokładność estymatora.

# 4. Model Hakanssona

Aby zweryfikować poprawność symulacji MC, wykorzystano model Hakanssona.
Jest to ścisłe, matematyczne rozwiązanie, będące rozszerzeniem
klasycznego modelu Blacka-Scholesa dla opcji egzotycznych.

# 5. Wyniki i wnioski końcowe

| Metoda               | Cena opcji (USD) |
|:---------------------|:-----------------|
| **Monte Carlo**      | 145.8916         |
| **Model Hakanssona** | 145.7411         |

**Podsumowanie:**

- **Poprawność technologiczna** - Wynik uzyskany drogą symulacji Monte
  Carlo jest wysoce zbieżny z wynikiem analitycznym. Zbieżność ta
  potwierdza poprawne zaprogramowanie logiki opcji.
- **Wpływ zmienności na wycenę** - Matematyka modelu poprawnie
  odzwierciedla realia rynkowe. Inwestorzy oczekują silnych ruchów na
  walorze takim jak TSLA, co sprawia, że szansa na utrzymanie się ceny w
  wąskim korytarzu przez okres 3 miesięcy jest niska. W efekcie premia
  za taką opcję stanowi niewielki ułamek ceny akcji bazowej.
- **Analiza relacji ceny opcji do ceny rynkowej** - Cena akcji TSLA w
  dniu wyceny wyniosła 389.37 USD. Obliczona wartość naszej opcji jest
  od niej drastycznie mniejsza. Posiadanie samej akcji gwarantuje
  zachowanie kapitału na poziomie jej bieżącej wyceny. Opcja korytarzowa
  to struktura “wszystko albo nic” rynek bezlitośnie dyskontuje ryzyko
  przebicia barier, drastycznie obniżając jej cenę bieżącą.
- **Ograniczenia i słabości modelu** Główną słabością przeprowadzonego
  badania jest wykorzystanie założeń klasycznego modelu Blacka-Scholesa
  / Hakanssona. Zakładają one, że zmienność ($\sigma$) oraz stopa
  procentowa ($r$) są stałe w całym okresie życia opcji. W
  rzeczywistości rynkowej parametry te są dynamiczne. Co więcej, model
  Geometrycznego Ruchu Browna (GBM) zakłada ciągłość zmian cen, podczas
  gdy akcje z sektora technologicznego często doświadczają skoków (luk
  cenowych).
- **Cena teoretyczna a rzeczywisty rynek (OTC)** Wyliczona przez nas
  kwota r round(mc_price, 4) USD to wartość czysto teoretyczna (fair
  value). Opcje egzotyczne są notowane na rynku pozagiełdowym (OTC). W
  praktyce rynkowej cena zażądana przez bank inwestycyjny byłaby inna –
  instytucja doliczyłaby spread (marżę) oraz dodatkową premię za ryzyko
  nagłych skoków zmienności, co prawdopodobnie wyceniłoby opcję jeszcze
  niżej z perspektywy sprzedającego.

# Literatura

- Hull, J. C. (2021). Options, Futures, and Other Derivatives. Pearson.
  (Standard rynkowy definiujący matematykę wyceny dla opcji klasycznych
  i egzotycznych, w tym instrumentów binarnych).

- Glasserman, P. (2003). Monte Carlo Methods in Financial Engineering.
  Springer. (Kanoniczne źródło opisujące poprawne modelowanie procesów
  stochastycznych oraz stosowanie technik redukcji wariancji, takich jak
  zmienne antytetyczne).
