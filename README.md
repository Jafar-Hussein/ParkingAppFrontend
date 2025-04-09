# 🚗 Parkeringsapplikation – Flutter Frontend

Detta är en Flutter-baserad mobilapplikation som fungerar som frontend för [ParkingAppCliDb](https://github.com/Jafar-Hussein/ParkingAppCliDb) – ett backendprojekt med REST API:er för hantering av användare, fordon och parkeringar. Applikationen är byggd för att användas av slutanvändare som vill:

- Registrera sig och logga in
- Lägga till och hantera fordon
- Se lediga parkeringsplatser
- Starta och avsluta parkering
- Se parkeringshistorik

---

## 🧭 Funktionalitet

### 1. Användarhantering
- Registrering av nya användare med namn och personnummer
- Inloggning för befintliga användare
- Automatisk identifiering av användare vid alla operationer

### 2. Fordonshantering
- Visa användarens egna fordon
- Lägga till och ta bort fordon

### 3. Parkeringsfunktioner
- Visa lediga parkeringsplatser (med pris)
- Starta en parkering genom att välja fordon
- Avsluta pågående parkeringar
- Se historik över avslutade parkeringar

---

## 🧩 Extra funktioner (för högre betyg)

- 🌗 Mörkt/Ljust tema som kan växlas via meny
- 📄 Pagination för:
  - Parkeringshistorik
  - Lediga parkeringsplatser
  - Fordonslistor
- 📍 Karta (via `flutter_map`) på startsidan

---

## 🛠️ Installation & Körning

1. Klona projektet:
   ```bash
   git clone https://github.com/Jafar-Hussein/ParkingAppFlutter.git
   ``` 
2. Navigera in i projektmappen
```
   cd parkingAppFlutter
```

3. Installera beroende
```
flutter pub get
```

4. kör projektet
```
flutter run
```