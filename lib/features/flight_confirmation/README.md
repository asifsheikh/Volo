# Flight Confirmation Feature

This feature package handles the final confirmation screen in the user flow where users confirm their flight details and selected contacts.

## Structure

```
flight_confirmation/
├── screens/
│   └── confirmation_screen.dart      # Main confirmation screen
├── models/
│   └── confirmation_args.dart        # Data model for confirmation arguments
├── widgets/                          # Reusable widgets (future use)
├── flight_confirmation.dart          # Feature exports
└── README.md                         # This file
```

## Usage

The confirmation screen is typically navigated to from the add contacts screen after users have selected their contacts. It displays:

- Flight route (departure → arrival)
- Success message and explanation
- List of contacts who will be notified
- Confirmation button to complete the flow

## Data Flow

1. User completes add contacts screen
2. `ConfirmationArgs` is created with flight and contact data
3. User is navigated to confirmation screen
4. User sees final confirmation and can complete the flow

## Models

### ConfirmationArgs
Contains all the data needed for the confirmation screen:
- `fromCity`: Departure city
- `toCity`: Arrival city  
- `contactNames`: List of contact names
- `contactAvatars`: List of contact avatar URLs
- `selectedFlight`: Flight data (future use) 