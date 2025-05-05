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

## BLoC (Business Logic Component) – Arkitektur & Tester

Projektet är uppdelat i **BLoC-moduler** för varje funktionalitet:

### Struktur:
- **BLoC-filer** hanterar logiken (t.ex. `AuthBloc`, `ParkingBloc`, `VehicleBloc`, `ParkingPlaceBloc`)
- **Events** triggar logiken (ex: `LoginEvent`, `AddVehicleEvent`)
- **States** representerar appens aktuella tillstånd (ex: `AuthenticatedState`, `ParkingPlaceLoadedState`)

### Fördelar med BLoC:
- Separering av UI och logik (clean architecture)
- Enkel testning (med `bloc_test` och `mocktail`)
- Enkel felsökning: varje tillstånd är tydligt

### Nackdelar:
- Mycket boilerplate-kod (events, states, BLoC)
- Kan kännas överkomplicerat för små appar

### Tester:
- Varje BLoC har enhetstester som kontrollerar:
  - Rätt tillstånd efter lyckade/felaktiga anrop
  - Användning av mockade repository-klasser
- Användning av `bloc_test` och `mocktail`

---
## ⚠️ Kända begränsningar

- Det finns ingen validering av formulärinmatning (t.ex. tomma fält vid registrering)
- Inloggning sker enbart via namn/personnummer utan säkerhetsåtgärder
- Ingen sessionhantering (användaren är ”inloggad” tills appen startas om)
- Karta visar bara en statisk plats (Stockholm)

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

4. Hämta api nyckel
```
Skapa konto i https://manage.thunderforest.com/dashboard och hämta din nyckel och url från atlas map och klistra in det i MapScreen filen där det står urlTemplate

```
5. kör projektet
```
flutter run
```