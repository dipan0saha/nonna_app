# Implementation Plan: Complete Spanish Localization for Custom Tiles (Gap Item #5)

## Goal Description
The Nonna application supports bilingual localization (English and Spanish) via standard ARB templates under `lib/l10n/` with automated code generation (`generate: true` in `pubspec.yaml`). However, three recently added custom smart tiles contain hardcoded English strings, breaking the user experience for Spanish-speaking users:
1. **NewBabyWelcomeTile** (`lib/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart`): Hardcoded titles, day-counters ("Born today!", "days old"), and "Retry" labels.
2. **PredictionVotesSmartTile** (`lib/tiles/prediction_votes/widgets/prediction_votes_tile.dart`): Hardcoded gender buttons ("Boy", "Girl"), titles, help texts, and pluralized status summaries ("gender vote(s)", "birthdate vote(s)").
3. **ActivityListTile** (`lib/tiles/activity_list/widgets/activity_list_tile.dart`): Hardcoded titles, metric labels ("Squishes", "Comments", "RSVPs", "Total"), and empty state messages.
4. **Gender Enum** (`lib/core/enums/gender.dart`): Hardcoded display names ("Male", "Female", "Neutral").

This plan extracts all hardcoded values into dynamic locale lookups via `AppLocalizations.of(context)`, updates ARB templates for both locales, handles dynamic plurals using ICU format, and adds localized date formatters.

---

## User Review Required
No breaking changes or system-wide disruptions. 

> [!TIP]
> **Key Translation Choices**:
> - We translate **"Squish"** (the cute, grandma-themed post reaction) as **"Apachurrón" / "Apachurrones"** in Spanish. This preserves the warm, cute, grandmotherly theme (Nonna = Grandma) of the application.
> - We map database-persisted prediction strings (`"Boy"`, `"Girl"`) to localized displays (`"Niño"`, `"Niña"`) while keeping database filters operating on raw strings.

---

## Open Questions
There are no open questions. All translation keys and localized string maps are detailed below.

---

## Proposed Changes

### Localization Resources

We will append the new keys and their respective descriptions at the end of the JSON object in both `app_en.arb` and `app_es.arb`.

#### [MODIFY] [app_en.arb](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/l10n/app_en.arb)
Add the following keys before the closing brace `}`:
```json
  "gender_male": "Male",
  "@gender_male": {
    "description": "Male gender display name"
  },
  "gender_female": "Female",
  "@gender_female": {
    "description": "Female gender display name"
  },
  "gender_neutral": "Neutral",
  "@gender_neutral": {
    "description": "Neutral/unknown gender display name"
  },
  "tile_welcome_title": "Welcome, Little One!",
  "@tile_welcome_title": {
    "description": "Title of the new baby welcome tile"
  },
  "tile_welcome_born_today": "🎉 Born today!",
  "@tile_welcome_born_today": {
    "description": "Label when the baby is born today"
  },
  "tile_welcome_days_old": "{count, plural, =1{🎉 1 day old} other{🎉 {count} days old}}",
  "@tile_welcome_days_old": {
    "description": "Label displaying how many days old the baby is",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  },
  "tile_predictions_title": "Prediction Votes",
  "@tile_predictions_title": {
    "description": "Title of the prediction votes tile"
  },
  "tile_predictions_help_text": "When do you think the baby will arrive?",
  "@tile_predictions_help_text": {
    "description": "Help text inside birthdate prediction date picker dialog"
  },
  "tile_predictions_gender_title": "Gender Prediction",
  "@tile_predictions_gender_title": {
    "description": "Subheading for gender prediction section"
  },
  "tile_predictions_gender_your_vote": "Your vote: {gender}",
  "@tile_predictions_gender_your_vote": {
    "description": "Displays the user's gender prediction vote",
    "placeholders": {
      "gender": {
        "type": "String",
        "example": "Boy"
      }
    }
  },
  "tile_predictions_gender_boy": "Boy",
  "@tile_predictions_gender_boy": {
    "description": "Label for Boy gender option"
  },
  "tile_predictions_gender_girl": "Girl",
  "@tile_predictions_gender_girl": {
    "description": "Label for Girl gender option"
  },
  "tile_predictions_birthdate_title": "Birthdate Prediction",
  "@tile_predictions_birthdate_title": {
    "description": "Subheading for birthdate prediction section"
  },
  "tile_predictions_birthdate_your_vote": "Your vote: {date}",
  "@tile_predictions_birthdate_your_vote": {
    "description": "Displays the user's birthdate prediction vote",
    "placeholders": {
      "date": {
        "type": "String",
        "example": "May 25, 2026"
      }
    }
  },
  "tile_predictions_birthdate_change": "Change your prediction",
  "@tile_predictions_birthdate_change": {
    "description": "Button label to change birthdate prediction"
  },
  "tile_predictions_birthdate_pick": "Pick a date",
  "@tile_predictions_birthdate_pick": {
    "description": "Button label to pick a birthdate prediction"
  },
  "tile_predictions_summary": "Total: {genderCount, plural, =1{1 gender vote} other{{genderCount} gender votes}}, {birthdateCount, plural, =1{1 birthdate vote} other{{birthdateCount} birthdate votes}}",
  "@tile_predictions_summary": {
    "description": "Summary string of total votes cast",
    "placeholders": {
      "genderCount": {
        "type": "int",
        "example": "5"
      },
      "birthdateCount": {
        "type": "int",
        "example": "3"
      }
    }
  },
  "tile_activity_title": "Engagement Recap",
  "@tile_activity_title": {
    "description": "Title of the activity list/engagement recap tile"
  },
  "tile_activity_period": "{count}d",
  "@tile_activity_period": {
    "description": "Displays lookback period options (e.g. 7d, 30d, 90d)",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "30"
      }
    }
  },
  "tile_activity_squishes": "Squishes",
  "@tile_activity_squishes": {
    "description": "Label for photo squish reactions metric"
  },
  "tile_activity_comments": "Comments",
  "@tile_activity_comments": {
    "description": "Label for comments metric"
  },
  "tile_activity_rsvps": "RSVPs",
  "@tile_activity_rsvps": {
    "description": "Label for event RSVPs metric"
  },
  "tile_activity_total": "Total",
  "@tile_activity_total": {
    "description": "Label for total engagement metrics"
  },
  "tile_activity_empty": "No engagement data yet",
  "@tile_activity_empty": {
    "description": "Empty state label when no activity exists"
  }
```

#### [MODIFY] [app_es.arb](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/l10n/app_es.arb)
Add the corresponding Spanish translations before the closing brace `}`:
```json
  "gender_male": "Masculino",
  "@gender_male": {
    "description": "Nombre para mostrar del género masculino"
  },
  "gender_female": "Femenino",
  "@gender_female": {
    "description": "Nombre para mostrar del género femenino"
  },
  "gender_neutral": "Neutro",
  "@gender_neutral": {
    "description": "Nombre para mostrar del género neutro"
  },
  "tile_welcome_title": "¡Bienvenido, pequeño!",
  "@tile_welcome_title": {
    "description": "Título de la tarjeta de bienvenida del nuevo bebé"
  },
  "tile_welcome_born_today": "🎉 ¡Nació hoy!",
  "@tile_welcome_born_today": {
    "description": "Etiqueta cuando el bebé nace el día de hoy"
  },
  "tile_welcome_days_old": "{count, plural, =1{🎉 1 día de edad} other{🎉 {count} días de edad}}",
  "@tile_welcome_days_old": {
    "description": "Etiqueta que muestra cuántos días de edad tiene el bebé",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  },
  "tile_predictions_title": "Votos de Predicción",
  "@tile_predictions_title": {
    "description": "Título de la tarjeta de votos de predicción"
  },
  "tile_predictions_help_text": "¿Cuándo crees que llegará el bebé?",
  "@tile_predictions_help_text": {
    "description": "Texto de ayuda dentro del diálogo para elegir la fecha de predicción"
  },
  "tile_predictions_gender_title": "Predicción de Género",
  "@tile_predictions_gender_title": {
    "description": "Subtítulo para la sección de predicción de género"
  },
  "tile_predictions_gender_your_vote": "Tu voto: {gender}",
  "@tile_predictions_gender_your_vote": {
    "description": "Muestra el voto de predicción de género del usuario",
    "placeholders": {
      "gender": {
        "type": "String",
        "example": "Niño"
      }
    }
  },
  "tile_predictions_gender_boy": "Niño",
  "@tile_predictions_gender_boy": {
    "description": "Etiqueta para la opción de género Niño"
  },
  "tile_predictions_gender_girl": "Niña",
  "@tile_predictions_gender_girl": {
    "description": "Etiqueta para la opción de género Niña"
  },
  "tile_predictions_birthdate_title": "Predicción de Fecha de Nacimiento",
  "@tile_predictions_birthdate_title": {
    "description": "Subtítulo para la sección de predicción de fecha de nacimiento"
  },
  "tile_predictions_birthdate_your_vote": "Tu voto: {date}",
  "@tile_predictions_birthdate_your_vote": {
    "description": "Muestra el voto de predicción de fecha del usuario",
    "placeholders": {
      "date": {
        "type": "String",
        "example": "25 may 2026"
      }
    }
  },
  "tile_predictions_birthdate_change": "Cambiar tu predicción",
  "@tile_predictions_birthdate_change": {
    "description": "Etiqueta del botón para cambiar la predicción de fecha"
  },
  "tile_predictions_birthdate_pick": "Elige una fecha",
  "@tile_predictions_birthdate_pick": {
    "description": "Etiqueta del botón para elegir una predicción de fecha"
  },
  "tile_predictions_summary": "Total: {genderCount, plural, =1{1 voto de género} other{{genderCount} votos de género}}, {birthdateCount, plural, =1{1 voto de fecha} other{{birthdateCount} votos de fecha}}",
  "@tile_predictions_summary": {
    "description": "Resumen de los votos totales realizados",
    "placeholders": {
      "genderCount": {
        "type": "int",
        "example": "5"
      },
      "birthdateCount": {
        "type": "int",
        "example": "3"
      }
    }
  },
  "tile_activity_title": "Resumen de Interacción",
  "@tile_activity_title": {
    "description": "Título de la tarjeta de resumen de interacción"
  },
  "tile_activity_period": "{count}d",
  "@tile_activity_period": {
    "description": "Muestra las opciones de periodo de búsqueda (ej. 7d, 30d, 90d)",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "30"
      }
    }
  },
  "tile_activity_squishes": "Apachurrones",
  "@tile_activity_squishes": {
    "description": "Etiqueta para la métrica de reacciones de apachurrón/abrazo"
  },
  "tile_activity_comments": "Comentarios",
  "@tile_activity_comments": {
    "description": "Etiqueta para la métrica de comentarios"
  },
  "tile_activity_rsvps": "Confirmaciones",
  "@tile_activity_rsvps": {
    "description": "Etiqueta para la métrica de confirmaciones de eventos"
  },
  "tile_activity_total": "Total",
  "@tile_activity_total": {
    "description": "Etiqueta para la métrica total de interacciones"
  },
  "tile_activity_empty": "Aún no hay datos de interacción",
  "@tile_activity_empty": {
    "description": "Etiqueta de estado vacío cuando no hay interacciones"
  }
```

---

### Core Enums & Widgets

#### [MODIFY] [gender.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/enums/gender.dart)
Add `GenderL10n` extension to support build context localizations dynamically:
```dart
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

// ... (existing code remains intact)

/// Localized extension to resolve translations with BuildContext
extension GenderL10n on Gender {
  String localizedDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Gender.male:
        return l10n.gender_male;
      case Gender.female:
        return l10n.gender_female;
      case Gender.unknown:
        return l10n.gender_neutral;
    }
  }
}
```

#### [MODIFY] [new_baby_welcome_tile.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart)
- Import `app_localizations.dart`.
- Replace hardcoded welcome header string with `l10n.tile_welcome_title`.
- Use `gender.localizedDisplayName(context)` for the gender chip display.
- Format `formattedDate` utilizing context locale: `DateFormat('dd MMM yyyy', Localizations.localeOf(context).toString())`.
- Update `_DayCounterBadge` logic to leverage plurals key:
  ```dart
  final label = daysSince == 0
      ? l10n.tile_welcome_born_today
      : l10n.tile_welcome_days_old(daysSince);
  ```
- Replace `"Retry"` in `_ErrorView` with standard `l10n.common_retry`.

#### [MODIFY] [prediction_votes_tile.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/tiles/prediction_votes/widgets/prediction_votes_tile.dart)
- Import `app_localizations.dart`.
- Update static titles/subtitles using `tile_predictions_title`, `tile_predictions_gender_title`, `tile_predictions_birthdate_title`.
- Translate dynamic user vote displays:
  ```dart
  final translatedGenderValue = currentValue == 'Boy'
      ? l10n.tile_predictions_gender_boy
      : currentValue == 'Girl'
          ? l10n.tile_predictions_gender_girl
          : currentValue;
  
  final displayVoteText = l10n.tile_predictions_gender_your_vote(translatedGenderValue ?? '');
  ```
- Format the date picker `helpText` via `l10n.tile_predictions_help_text`.
- Format voter birthdate using context locale and display:
  ```dart
  final displayDateText = l10n.tile_predictions_birthdate_your_vote(
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(currentDate)
  );
  ```
- Update action buttons:
  ```dart
  label: Text(
    currentDate != null 
        ? l10n.tile_predictions_birthdate_change 
        : l10n.tile_predictions_birthdate_pick
  )
  ```
- Update vote count buttons and summary using ICU pluralized aggregates:
  ```dart
  l10n.tile_predictions_summary(genderVotes, birthdateVotes)
  ```

#### [MODIFY] [activity_list_tile.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/tiles/activity_list/widgets/activity_list_tile.dart)
- Import `app_localizations.dart`.
- Update tile header with `l10n.tile_activity_title`.
- Localize period options: `label: Text(l10n.tile_activity_period(d))` (e.g. `7d`, `30d`).
- Localize metrics chips (`Squishes`, `Comments`, `RSVPs`, `Total`):
  - `l10n.tile_activity_squishes`
  - `l10n.tile_activity_comments`
  - `l10n.tile_activity_rsvps`
  - `l10n.tile_activity_total`
- Replace `"No engagement data yet"` empty placeholder with `l10n.tile_activity_empty`.

---

## Verification Plan

### Automated Tests
Run the following local targets:
1. **Regenerate Localizations**:
   ```bash
   flutter gen-l10n
   ```
2. **Perform Static Analysis**:
   ```bash
   make analyze
   ```
3. **Execute Unit/Widget Test Suite**:
   ```bash
   make test
   ```

### Manual Verification
1. **Locale Switching**: Run the application in emulator/device, navigate to settings, switch from **English** to **Spanish**, and verify that:
   - The Welcome Card displays `"¡Bienvenido, pequeño!"` and correct age plurals (`🎉 1 día de edad` or `🎉 5 días de edad`).
   - The Prediction Votes card titles update to Spanish, gender options show `"Niño"`/`"Niña"`, and summaries use Spanish terms.
   - The Activity Card correctly renders `"Resumen de Interacción"`, period headers (`7d`, `30d`), and metrics labeled `"Apachurrones"`, `"Comentarios"`, `"Confirmaciones"`.
2. **Date Format Adaptation**: Confirm that picking a date on Spanish locale displays natively as e.g. `25 may 2026` rather than `May 25, 2026`.
