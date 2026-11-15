import '../core/prefs/app_prefs.dart';
import 'app_localizations.dart';

/// Frasa sebutan orang tua yang disisipkan ke kalimat, mis. "Ayah atau Bunda".
String panggilanTeks(PanggilanOrtu panggilan, AppLocalizations l10n) =>
    switch (panggilan) {
      PanggilanOrtu.ayahBunda => l10n.panggilanAyahBunda,
      PanggilanOrtu.bapakIbu => l10n.panggilanBapakIbu,
      PanggilanOrtu.papiMami => l10n.panggilanPapiMami,
      PanggilanOrtu.daddyMommy => l10n.panggilanDaddyMommy,
      PanggilanOrtu.orangTua => l10n.panggilanOrangTua,
    };

/// Label pil pilihan sebutan orang tua di kartu Pengaturan.
String panggilanLabel(PanggilanOrtu panggilan, AppLocalizations l10n) =>
    switch (panggilan) {
      PanggilanOrtu.ayahBunda => l10n.orangTuaPanggilanAyahBunda,
      PanggilanOrtu.bapakIbu => l10n.orangTuaPanggilanBapakIbu,
      PanggilanOrtu.papiMami => l10n.orangTuaPanggilanPapiMami,
      PanggilanOrtu.daddyMommy => l10n.orangTuaPanggilanDaddyMommy,
      PanggilanOrtu.orangTua => l10n.orangTuaPanggilanOrangTua,
    };
