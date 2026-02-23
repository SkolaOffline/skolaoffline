import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en')
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logging_loading.
  ///
  /// In en, this message translates to:
  /// **'Logging...'**
  String get logging_loading;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @no_lessons_for_today.
  ///
  /// In en, this message translates to:
  /// **'There are no lessons left for today'**
  String get no_lessons_for_today;

  /// No description provided for @timetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetable;

  /// No description provided for @current_lesson.
  ///
  /// In en, this message translates to:
  /// **'Current Lesson'**
  String get current_lesson;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @success_message.
  ///
  /// In en, this message translates to:
  /// **'You have been logged in.'**
  String get success_message;

  /// No description provided for @dummy_enabled.
  ///
  /// In en, this message translates to:
  /// **'Dummy data mode enabled!'**
  String get dummy_enabled;

  /// No description provided for @dummy_info.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an aplikace.skolaonline.cz account, you can use dummy mode by logging in as:\nusername: dummy\npassword: mode'**
  String get dummy_info;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @error_message.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while logging in.'**
  String get error_message;

  /// No description provided for @error_info.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occured'**
  String get error_info;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'Github (Issues, Code, etc.)'**
  String get github;

  /// No description provided for @email_us.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get email_us;

  /// No description provided for @unknown_subject.
  ///
  /// In en, this message translates to:
  /// **'Unknown subject'**
  String get unknown_subject;

  /// No description provided for @absence.
  ///
  /// In en, this message translates to:
  /// **'Absence'**
  String get absence;

  /// No description provided for @marks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get marks;

  /// No description provided for @marks_by_subjects.
  ///
  /// In en, this message translates to:
  /// **'Marks By Subjects'**
  String get marks_by_subjects;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @change_user.
  ///
  /// In en, this message translates to:
  /// **'Change profile'**
  String get change_user;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get dark_mode;

  /// No description provided for @dark_marks.
  ///
  /// In en, this message translates to:
  /// **'Dark marks'**
  String get dark_marks;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @default_timetable.
  ///
  /// In en, this message translates to:
  /// **'Default timetable'**
  String get default_timetable;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get report;

  /// No description provided for @wrong_credentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials'**
  String get wrong_credentials;

  /// No description provided for @wrong_credentials_message.
  ///
  /// In en, this message translates to:
  /// **'Please check your username and password. If you don\'t have a skola online account you may try this app using dummy mode by loging in as \'dummy:mode\'.'**
  String get wrong_credentials_message;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer:\nWe are not in any way asociated with Škola Online, skolaonline.cz, BAKALÁŘI software s.r.o. or any other related subjects. This project is for educational purposes only.'**
  String get disclaimer;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @mark.
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mark;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @type_note.
  ///
  /// In en, this message translates to:
  /// **'Type note'**
  String get type_note;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @verbal_evaluation.
  ///
  /// In en, this message translates to:
  /// **'Verbal evaluation'**
  String get verbal_evaluation;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @class_rank.
  ///
  /// In en, this message translates to:
  /// **'Class rank'**
  String get class_rank;

  /// No description provided for @class_average.
  ///
  /// In en, this message translates to:
  /// **'Class average'**
  String get class_average;

  /// No description provided for @school_year.
  ///
  /// In en, this message translates to:
  /// **'School year'**
  String get school_year;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievement;

  /// No description provided for @marks_average.
  ///
  /// In en, this message translates to:
  /// **'Marks average'**
  String get marks_average;

  /// No description provided for @absent_hours.
  ///
  /// In en, this message translates to:
  /// **'Absent hours'**
  String get absent_hours;

  /// No description provided for @excused_hours.
  ///
  /// In en, this message translates to:
  /// **'Excused hours'**
  String get excused_hours;

  /// No description provided for @not_excused_hours.
  ///
  /// In en, this message translates to:
  /// **'Not Excused hours'**
  String get not_excused_hours;

  /// No description provided for @edit_date.
  ///
  /// In en, this message translates to:
  /// **'Edit date'**
  String get edit_date;

  /// No description provided for @released.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get released;

  /// No description provided for @unclassified.
  ///
  /// In en, this message translates to:
  /// **'Unclassified'**
  String get unclassified;

  /// No description provided for @unevaluated.
  ///
  /// In en, this message translates to:
  /// **'Unevaluated'**
  String get unevaluated;

  /// No description provided for @recognized.
  ///
  /// In en, this message translates to:
  /// **'Recognized'**
  String get recognized;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
