import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'VYBE'**
  String get appName;

  /// No description provided for @startTagline.
  ///
  /// In en, this message translates to:
  /// **'Meet new people, safely'**
  String get startTagline;

  /// Tag on the decorative map on the first screen.
  ///
  /// In en, this message translates to:
  /// **'Verified public spots only'**
  String get mapHeroTag;

  /// No description provided for @startLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready'**
  String get startLoading;

  /// No description provided for @bootstrapErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'VYBE could not start'**
  String get bootstrapErrorTitle;

  /// No description provided for @bootstrapNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get bootstrapNoConnection;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// No description provided for @stateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmptyTitle;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @stateOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get stateOfflineTitle;

  /// No description provided for @stateOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection. This screen updates when you are back online.'**
  String get stateOfflineMessage;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some info may be out of date.'**
  String get offlineBanner;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'We could not reach VYBE. Check your connection and try again.'**
  String get failureNetwork;

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Connect to the internet and try again.'**
  String get failureOffline;

  /// No description provided for @failureUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get failureUnauthenticated;

  /// No description provided for @failurePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this.'**
  String get failurePermissionDenied;

  /// No description provided for @failureNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Finish verification to do this.'**
  String get failureNotVerified;

  /// No description provided for @failureInsufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'You do not have enough credits for this.'**
  String get failureInsufficientCredits;

  /// No description provided for @failureSlotFull.
  ///
  /// In en, this message translates to:
  /// **'That time slot just filled up. Pick another one.'**
  String get failureSlotFull;

  /// No description provided for @failureBlocked.
  ///
  /// In en, this message translates to:
  /// **'This person is not available.'**
  String get failureBlocked;

  /// No description provided for @failureModerationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers, emails, social handles and links cannot be shared in chat.'**
  String get failureModerationBlocked;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find that.'**
  String get failureNotFound;

  /// No description provided for @failureRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Please wait a moment and try again.'**
  String get failureRateLimited;

  /// No description provided for @failureInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please check what you entered.'**
  String get failureInvalidInput;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get failureUnknown;

  /// No description provided for @failureWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Check the SMS and try again.'**
  String get failureWrongCode;

  /// No description provided for @failureCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Tap Resend code to get a new one.'**
  String get failureCodeExpired;

  /// No description provided for @failurePurchaseInvalid.
  ///
  /// In en, this message translates to:
  /// **'The store could not confirm this purchase. You have not been charged credits.'**
  String get failurePurchaseInvalid;

  /// No description provided for @failureStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available on this device right now.'**
  String get failureStoreUnavailable;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not find that page'**
  String get notFoundTitle;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Go to start'**
  String get notFoundAction;

  /// No description provided for @badgeVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get badgeVerified;

  /// No description provided for @badgeFreeNow.
  ///
  /// In en, this message translates to:
  /// **'Free now'**
  String get badgeFreeNow;

  /// No description provided for @creditsPillSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}}. Open credits and plans'**
  String creditsPillSemantics(int count);

  /// No description provided for @stepSemanticsDone.
  ///
  /// In en, this message translates to:
  /// **'Step {number}, done'**
  String stepSemanticsDone(int number);

  /// No description provided for @stepSemanticsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Step {number}, in progress'**
  String stepSemanticsCurrent(int number);

  /// No description provided for @stepSemanticsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Step {number}, not started'**
  String stepSemanticsUpcoming(int number);

  /// No description provided for @planCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get planCoffee;

  /// No description provided for @planMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get planMovie;

  /// No description provided for @planEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get planEvent;

  /// No description provided for @planWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get planWalk;

  /// No description provided for @planDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get planDinner;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// No description provided for @statMeetups.
  ///
  /// In en, this message translates to:
  /// **'Meetups'**
  String get statMeetups;

  /// No description provided for @statAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get statAge;

  /// No description provided for @safetyNotePublicSpots.
  ///
  /// In en, this message translates to:
  /// **'Meet only at verified public spots within {km} km.'**
  String safetyNotePublicSpots(int km);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile, photos, ID images, preferences, saved people and credits are deleted for good. Open bookings are cancelled and your chats close. This cannot be undone.\n\nTo stop a Plus or Premium plan from renewing, cancel it in Google Play too.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get deleteAccountConfirm;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @rulesForTitle.
  ///
  /// In en, this message translates to:
  /// **'This app is for'**
  String get rulesForTitle;

  /// No description provided for @rulesFor1.
  ///
  /// In en, this message translates to:
  /// **'Coffee, movies, walks, dinners and events'**
  String get rulesFor1;

  /// No description provided for @rulesFor2.
  ///
  /// In en, this message translates to:
  /// **'Meeting at verified public venues only'**
  String get rulesFor2;

  /// No description provided for @rulesFor3.
  ///
  /// In en, this message translates to:
  /// **'Respectful, friendly company'**
  String get rulesFor3;

  /// No description provided for @rulesNotForTitle.
  ///
  /// In en, this message translates to:
  /// **'Not for'**
  String get rulesNotForTitle;

  /// No description provided for @rulesNotFor1.
  ///
  /// In en, this message translates to:
  /// **'Sexual services or any kind of solicitation'**
  String get rulesNotFor1;

  /// No description provided for @rulesNotFor2.
  ///
  /// In en, this message translates to:
  /// **'Meeting at private homes, hotels or rooms'**
  String get rulesNotFor2;

  /// No description provided for @rulesNotFor3.
  ///
  /// In en, this message translates to:
  /// **'Sharing phone numbers or taking chats off the app'**
  String get rulesNotFor3;

  /// No description provided for @rulesConsent.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older and I agree to these rules. Breaking them means a permanent ban.'**
  String get rulesConsent;

  /// No description provided for @rulesContinue.
  ///
  /// In en, this message translates to:
  /// **'I agree, continue'**
  String get rulesContinue;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify it is you'**
  String get verifyTitle;

  /// No description provided for @verifySelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Selfie check'**
  String get verifySelfieTitle;

  /// No description provided for @verifySelfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Takes about 20 seconds'**
  String get verifySelfieSubtitle;

  /// No description provided for @verifyIdTitle.
  ///
  /// In en, this message translates to:
  /// **'ID check'**
  String get verifyIdTitle;

  /// No description provided for @verifyIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar, passport or licence'**
  String get verifyIdSubtitle;

  /// No description provided for @verifyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get verifyPhoneLabel;

  /// No description provided for @verifyPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'98765 43210'**
  String get verifyPhoneHint;

  /// No description provided for @verifyPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid {length}-digit mobile number.'**
  String verifyPhoneInvalid(int length);

  /// No description provided for @verifySendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get verifySendCode;

  /// No description provided for @verifyOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'{length}-digit code'**
  String verifyOtpLabel(int length);

  /// No description provided for @verifyOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}.'**
  String verifyOtpSentTo(String phone);

  /// No description provided for @verifyOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the {length}-digit code.'**
  String verifyOtpInvalid(int length);

  /// No description provided for @verifyConfirmCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyConfirmCode;

  /// No description provided for @verifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String verifyResendIn(int seconds);

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyResend;

  /// No description provided for @verifyChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get verifyChangeNumber;

  /// No description provided for @verifyUseDifferentNumber.
  ///
  /// In en, this message translates to:
  /// **'Use a different number'**
  String get verifyUseDifferentNumber;

  /// No description provided for @verifyFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your account'**
  String get verifyFinishTitle;

  /// No description provided for @verifyFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Your number is verified. Tap continue to create your account.'**
  String get verifyFinishBody;

  /// No description provided for @verifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get verifyContinue;

  /// No description provided for @verifySelfieFrame.
  ///
  /// In en, this message translates to:
  /// **'Fit your face in the frame'**
  String get verifySelfieFrame;

  /// No description provided for @verifyTakeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take selfie'**
  String get verifyTakeSelfie;

  /// No description provided for @verifyIdPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your ID is encrypted and is never shown to other users.'**
  String get verifyIdPrivacy;

  /// No description provided for @verifyChooseId.
  ///
  /// In en, this message translates to:
  /// **'Which ID will you use?'**
  String get verifyChooseId;

  /// No description provided for @idAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar'**
  String get idAadhaar;

  /// No description provided for @idPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get idPassport;

  /// No description provided for @idDrivingLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence'**
  String get idDrivingLicence;

  /// No description provided for @verifyIdFrame.
  ///
  /// In en, this message translates to:
  /// **'Photograph the front of your ID in good light'**
  String get verifyIdFrame;

  /// No description provided for @verifyTakeIdPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take ID photo'**
  String get verifyTakeIdPhoto;

  /// No description provided for @verifyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'We are checking your photo'**
  String get verifyReviewTitle;

  /// No description provided for @verifyReviewBody.
  ///
  /// In en, this message translates to:
  /// **'This usually takes a few minutes. You can close the app and come back.'**
  String get verifyReviewBody;

  /// No description provided for @verifyRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not verify this photo'**
  String get verifyRejectedTitle;

  /// No description provided for @verifyRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Make sure it is clear, well lit and not cut off, then try again.'**
  String get verifyRejectedBody;

  /// No description provided for @verifyTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get verifyTryAgain;

  /// No description provided for @verifyUnderageTitle.
  ///
  /// In en, this message translates to:
  /// **'VYBE is for adults only'**
  String get verifyUnderageTitle;

  /// No description provided for @verifyUnderageBody.
  ///
  /// In en, this message translates to:
  /// **'Your ID shows you are under 18, so you cannot use VYBE.'**
  String get verifyUnderageBody;

  /// No description provided for @prefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to meet?'**
  String get prefsTitle;

  /// No description provided for @prefsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone is welcome here. You decide who you see.'**
  String get prefsSubtitle;

  /// No description provided for @prefsIAm.
  ///
  /// In en, this message translates to:
  /// **'I am'**
  String get prefsIAm;

  /// No description provided for @genderWoman.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get genderWoman;

  /// No description provided for @genderMan.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get genderMan;

  /// No description provided for @genderNonBinary.
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get genderNonBinary;

  /// No description provided for @genderUndisclosed.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderUndisclosed;

  /// No description provided for @prefsShowMe.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get prefsShowMe;

  /// No description provided for @showMeWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get showMeWomen;

  /// No description provided for @showMeMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get showMeMen;

  /// No description provided for @showMeEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get showMeEveryone;

  /// No description provided for @prefsAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get prefsAgeRange;

  /// No description provided for @prefsAgeRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{min} to {max}'**
  String prefsAgeRangeValue(int min, int max);

  /// No description provided for @prefsAgeMin.
  ///
  /// In en, this message translates to:
  /// **'Youngest age, {age}'**
  String prefsAgeMin(int age);

  /// No description provided for @prefsAgeMax.
  ///
  /// In en, this message translates to:
  /// **'Oldest age, {age}'**
  String prefsAgeMax(int age);

  /// No description provided for @prefsDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get prefsDistance;

  /// No description provided for @prefsDistanceValue.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String prefsDistanceValue(int km);

  /// No description provided for @prefsShowGender.
  ///
  /// In en, this message translates to:
  /// **'Show my gender on my profile'**
  String get prefsShowGender;

  /// No description provided for @prefsShowGenderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Only used to decide who sees you.'**
  String get prefsShowGenderSubtitle;

  /// No description provided for @prefsStart.
  ///
  /// In en, this message translates to:
  /// **'Start exploring'**
  String get prefsStart;

  /// No description provided for @suspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspended'**
  String get suspendedTitle;

  /// No description provided for @suspendedBody.
  ///
  /// In en, this message translates to:
  /// **'This account was suspended for breaking the VYBE rules.'**
  String get suspendedBody;

  /// No description provided for @creditsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}}'**
  String creditsCount(int count);

  /// No description provided for @failureLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Share your location to see people near you.'**
  String get failureLocationRequired;

  /// No description provided for @failureLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location is off or not allowed for VYBE.'**
  String get failureLocationDenied;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @discoverShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing: {who}'**
  String discoverShowing(String who);

  /// No description provided for @discoverMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get discoverMap;

  /// No description provided for @discoverFreeNowLink.
  ///
  /// In en, this message translates to:
  /// **'See who is free right now'**
  String get discoverFreeNowLink;

  /// No description provided for @discoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No one nearby for this plan yet'**
  String get discoverEmptyTitle;

  /// No description provided for @discoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another plan, or see who is free right now.'**
  String get discoverEmptyBody;

  /// No description provided for @discoverAllSeenTitle.
  ///
  /// In en, this message translates to:
  /// **'You have seen everyone for now'**
  String get discoverAllSeenTitle;

  /// No description provided for @discoverMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get discoverMessage;

  /// No description provided for @discoverSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get discoverSave;

  /// No description provided for @discoverUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get discoverUnsave;

  /// No description provided for @cardNameAge.
  ///
  /// In en, this message translates to:
  /// **'{name}, {age}'**
  String cardNameAge(String name, int age);

  /// No description provided for @cardAboutKmAway.
  ///
  /// In en, this message translates to:
  /// **'About {km} km away'**
  String cardAboutKmAway(int km);

  /// No description provided for @cardFreeUntil.
  ///
  /// In en, this message translates to:
  /// **'free until {time}'**
  String cardFreeUntil(String time);

  /// No description provided for @cardSpotsNearby.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No spots nearby} =1{1 spot nearby} other{{count} spots nearby}}'**
  String cardSpotsNearby(int count);

  /// No description provided for @voiceIntroPlay.
  ///
  /// In en, this message translates to:
  /// **'Play voice intro, {seconds} seconds'**
  String voiceIntroPlay(int seconds);

  /// No description provided for @voiceIntroStop.
  ///
  /// In en, this message translates to:
  /// **'Stop voice intro'**
  String get voiceIntroStop;

  /// No description provided for @voiceDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String voiceDuration(int minutes, String seconds);

  /// No description provided for @promptIdealSunday.
  ///
  /// In en, this message translates to:
  /// **'My ideal Sunday'**
  String get promptIdealSunday;

  /// No description provided for @tagCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee meetup'**
  String get tagCoffee;

  /// No description provided for @tagMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get tagMovie;

  /// No description provided for @tagEvent.
  ///
  /// In en, this message translates to:
  /// **'Event plus-one'**
  String get tagEvent;

  /// No description provided for @tagWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get tagWalk;

  /// No description provided for @tagDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get tagDinner;

  /// No description provided for @locationNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is needed'**
  String get locationNeededTitle;

  /// No description provided for @locationNeededBody.
  ///
  /// In en, this message translates to:
  /// **'VYBE uses your location to show verified companions and public spots within {km} km. Other people never see your exact location.'**
  String locationNeededBody(int km);

  /// No description provided for @locationAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get locationAllow;

  /// No description provided for @locationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get locationOpenSettings;

  /// No description provided for @nameBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first name'**
  String get nameBannerTitle;

  /// No description provided for @nameBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Companions see your first name when you ask to meet.'**
  String get nameBannerBody;

  /// No description provided for @nameBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Add name'**
  String get nameBannerAction;

  /// No description provided for @freeNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Free right now'**
  String get freeNowTitle;

  /// No description provided for @freeNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified companions within {km} km.'**
  String freeNowSubtitle(int km);

  /// No description provided for @freeNowNext2h.
  ///
  /// In en, this message translates to:
  /// **'Next 2 hrs'**
  String get freeNowNext2h;

  /// No description provided for @freeNowTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get freeNowTonight;

  /// No description provided for @freeNowTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get freeNowTomorrow;

  /// No description provided for @freeUntil.
  ///
  /// In en, this message translates to:
  /// **'Free until {time}'**
  String freeUntil(String time);

  /// No description provided for @freeBetween.
  ///
  /// In en, this message translates to:
  /// **'Free {from} to {until}'**
  String freeBetween(String from, String until);

  /// No description provided for @aboutKm.
  ///
  /// In en, this message translates to:
  /// **'About {km} km'**
  String aboutKm(int km);

  /// No description provided for @freeNowEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No one is free in this window'**
  String get freeNowEmptyTitle;

  /// No description provided for @freeNowEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try tonight or tomorrow.'**
  String get freeNowEmptyBody;

  /// No description provided for @instantTitle.
  ///
  /// In en, this message translates to:
  /// **'Request instantly'**
  String get instantTitle;

  /// No description provided for @instantBody.
  ///
  /// In en, this message translates to:
  /// **'Costs {credits} credits'**
  String instantBody(int credits);

  /// No description provided for @instantPickSpot.
  ///
  /// In en, this message translates to:
  /// **'Pick spot'**
  String get instantPickSpot;

  /// No description provided for @profileNewRating.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get profileNewRating;

  /// No description provided for @profileChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get profileChat;

  /// No description provided for @profileBookSpot.
  ///
  /// In en, this message translates to:
  /// **'Book your spot'**
  String get profileBookSpot;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get myProfileTitle;

  /// No description provided for @myProfileName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get myProfileName;

  /// No description provided for @myProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'How companions will see you'**
  String get myProfileNameHint;

  /// No description provided for @myProfileSaveName.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get myProfileSaveName;

  /// No description provided for @myProfileNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get myProfileNameSaved;

  /// No description provided for @myProfileNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name, up to {max} characters.'**
  String myProfileNameInvalid(int max);

  /// No description provided for @myProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get myProfilePhone;

  /// No description provided for @myProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved companions'**
  String get myProfileSaved;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved companions'**
  String get savedTitle;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved companions yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Save on a profile to keep it here.'**
  String get savedEmptyBody;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @chatsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get chatsEmptyTitle;

  /// No description provided for @chatsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your chats with companions will show here.'**
  String get chatsEmptyBody;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bookingsEmptyTitle;

  /// No description provided for @bookingsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your booked spots will show here.'**
  String get bookingsEmptyBody;

  /// No description provided for @failureCompanionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'They are not free at that time. Pick another time.'**
  String get failureCompanionUnavailable;

  /// No description provided for @mapWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String mapWithinKm(int km);

  /// No description provided for @mapSemantics.
  ///
  /// In en, this message translates to:
  /// **'Map of verified spots within {km} km of you'**
  String mapSemantics(int km);

  /// No description provided for @mapBestSpots.
  ///
  /// In en, this message translates to:
  /// **'Best spots to meet'**
  String get mapBestSpots;

  /// No description provided for @mapToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get mapToday;

  /// No description provided for @mapPick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get mapPick;

  /// No description provided for @mapPickSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pick {venue}'**
  String mapPickSemantics(String venue);

  /// No description provided for @mapNoVenuesTitle.
  ///
  /// In en, this message translates to:
  /// **'No verified spots nearby yet'**
  String get mapNoVenuesTitle;

  /// No description provided for @mapNoVenuesBody.
  ///
  /// In en, this message translates to:
  /// **'Try another plan.'**
  String get mapNoVenuesBody;

  /// No description provided for @venueLine.
  ///
  /// In en, this message translates to:
  /// **'{category} · {km} km · {busy}'**
  String venueLine(String category, String km, String busy);

  /// No description provided for @venueCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get venueCafe;

  /// No description provided for @venueFoodCourt.
  ///
  /// In en, this message translates to:
  /// **'Food court'**
  String get venueFoodCourt;

  /// No description provided for @venueOpenPark.
  ///
  /// In en, this message translates to:
  /// **'Open park'**
  String get venueOpenPark;

  /// No description provided for @venueCinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get venueCinema;

  /// No description provided for @venueRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get venueRestaurant;

  /// No description provided for @venueOther.
  ///
  /// In en, this message translates to:
  /// **'Public venue'**
  String get venueOther;

  /// No description provided for @busyHotNow.
  ///
  /// In en, this message translates to:
  /// **'Hot now'**
  String get busyHotNow;

  /// No description provided for @busyBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busyBusy;

  /// No description provided for @busyQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get busyQuiet;

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book your spot'**
  String get bookTitle;

  /// No description provided for @bookVenueLine.
  ///
  /// In en, this message translates to:
  /// **'{km} km · Verified public venue'**
  String bookVenueLine(String km);

  /// No description provided for @bookChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get bookChange;

  /// No description provided for @bookDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get bookDay;

  /// No description provided for @bookToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get bookToday;

  /// No description provided for @bookPickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get bookPickDay;

  /// No description provided for @bookTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time slot'**
  String get bookTimeSlot;

  /// No description provided for @bookNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No times left on this day. Try another day.'**
  String get bookNoSlots;

  /// No description provided for @bookSlotUnavailableSemantics.
  ///
  /// In en, this message translates to:
  /// **'{time}, not available'**
  String bookSlotUnavailableSemantics(String time);

  /// No description provided for @bookSafety.
  ///
  /// In en, this message translates to:
  /// **'Both of you get a reminder and live location sharing on the day.'**
  String get bookSafety;

  /// No description provided for @bookCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Spot booking'**
  String get bookCostLabel;

  /// No description provided for @bookInstantCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Instant request'**
  String get bookInstantCostLabel;

  /// No description provided for @bookNoRefund.
  ///
  /// In en, this message translates to:
  /// **'Credits are not refunded if the request is declined or cancelled.'**
  String get bookNoRefund;

  /// No description provided for @bookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm spot'**
  String get bookConfirm;

  /// No description provided for @bookSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {name}.'**
  String bookSent(String name);

  /// No description provided for @bookNoVenue.
  ///
  /// In en, this message translates to:
  /// **'There are no verified spots you can both reach for this plan.'**
  String get bookNoVenue;

  /// No description provided for @bookingsStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Waiting for reply'**
  String get bookingsStatusRequested;

  /// No description provided for @bookingsStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingsStatusAccepted;

  /// No description provided for @bookingsStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get bookingsStatusDeclined;

  /// No description provided for @bookingsStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingsStatusCancelled;

  /// No description provided for @bookingsStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get bookingsStatusCheckedIn;

  /// No description provided for @bookingsStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingsStatusCompleted;

  /// No description provided for @bookingsStatusDisputed.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get bookingsStatusDisputed;

  /// No description provided for @bookingsStatusTimePassed.
  ///
  /// In en, this message translates to:
  /// **'Time passed'**
  String get bookingsStatusTimePassed;

  /// No description provided for @bookingsWith.
  ///
  /// In en, this message translates to:
  /// **'{plan} with {name}'**
  String bookingsWith(String plan, String name);

  /// No description provided for @bookingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingsCancel;

  /// No description provided for @bookingsCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get bookingsCancelTitle;

  /// No description provided for @bookingsCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Your table is released. Credits are not refunded.'**
  String get bookingsCancelBody;

  /// No description provided for @bookingsCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bookingsCancelConfirm;

  /// No description provided for @bookingsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get bookingsKeep;

  /// No description provided for @bookingsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get bookingsCancelled;

  /// No description provided for @freeNowSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap someone to choose them, then pick a spot.'**
  String get freeNowSelectHint;

  /// No description provided for @freeNowViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get freeNowViewProfile;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @chatNotice.
  ///
  /// In en, this message translates to:
  /// **'Chat is for planning your meetup. Phone numbers and off-app contact are blocked.'**
  String get chatNotice;

  /// No description provided for @chatStartedCredits.
  ///
  /// In en, this message translates to:
  /// **'{credits, plural, =1{1 credit used to start this chat} other{{credits} credits used to start this chat}}'**
  String chatStartedCredits(int credits);

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chatInputHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSend;

  /// No description provided for @chatReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReport;

  /// No description provided for @chatClosed.
  ///
  /// In en, this message translates to:
  /// **'This chat is closed.'**
  String get chatClosed;

  /// No description provided for @chatBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book your spot with {name}'**
  String chatBookTitle(String name);

  /// No description provided for @chatBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get chatBook;

  /// No description provided for @chatBookingCardTitle.
  ///
  /// In en, this message translates to:
  /// **'{plan} meetup'**
  String chatBookingCardTitle(String plan);

  /// No description provided for @chatBookingCardLine.
  ///
  /// In en, this message translates to:
  /// **'{when} · {venue}'**
  String chatBookingCardLine(String when, String venue);

  /// No description provided for @chatPreviewBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking request'**
  String get chatPreviewBooking;

  /// No description provided for @chatPreviewStarted.
  ///
  /// In en, this message translates to:
  /// **'Chat started'**
  String get chatPreviewStarted;

  /// No description provided for @chatStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a chat with {name}?'**
  String chatStartTitle(String name);

  /// No description provided for @chatStartBody.
  ///
  /// In en, this message translates to:
  /// **'This uses {cost}. Credits are not refunded.'**
  String chatStartBody(String cost);

  /// No description provided for @chatStartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get chatStartConfirm;

  /// No description provided for @chatsUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String chatsUnread(int count);

  /// No description provided for @reportOrBlock.
  ///
  /// In en, this message translates to:
  /// **'Report or block'**
  String get reportOrBlock;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report {name}'**
  String reportTitle(String name);

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate messages'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonContact.
  ///
  /// In en, this message translates to:
  /// **'Asked for my number or other contact'**
  String get reportReasonContact;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or pressure'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonFake.
  ///
  /// In en, this message translates to:
  /// **'Fake profile'**
  String get reportReasonFake;

  /// No description provided for @reportReasonSafety.
  ///
  /// In en, this message translates to:
  /// **'I felt unsafe'**
  String get reportReasonSafety;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// No description provided for @reportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Anything else we should know (optional)'**
  String get reportDetailsHint;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSubmit;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Our safety team will review this.'**
  String get reportSent;

  /// No description provided for @blockAction.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String blockAction(String name);

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockTitle(String name);

  /// No description provided for @blockBody.
  ///
  /// In en, this message translates to:
  /// **'You will not see each other anywhere on VYBE. Your chat closes and open bookings are cancelled. Credits are not refunded.'**
  String get blockBody;

  /// No description provided for @blockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockConfirm;

  /// No description provided for @blockDone.
  ///
  /// In en, this message translates to:
  /// **'{name} is blocked.'**
  String blockDone(String name);

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Get more credits'**
  String get creditsTitle;

  /// No description provided for @creditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock chats and bookings.'**
  String get creditsSubtitle;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planPlus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get planPlus;

  /// No description provided for @planPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremium;

  /// No description provided for @creditsFreePrice.
  ///
  /// In en, this message translates to:
  /// **'₹0'**
  String get creditsFreePrice;

  /// No description provided for @creditsFreeDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}} when you join'**
  String creditsFreeDetail(int count);

  /// No description provided for @creditsPlanDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}} a month · unused credits stay'**
  String creditsPlanDetail(int count);

  /// No description provided for @creditsPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get creditsPopular;

  /// No description provided for @creditsYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get creditsYourPlan;

  /// No description provided for @creditsRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String creditsRenews(String date);

  /// No description provided for @creditsMovesTo.
  ///
  /// In en, this message translates to:
  /// **'Moves to {plan} on {date}'**
  String creditsMovesTo(String plan, String date);

  /// No description provided for @creditsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price}/mo'**
  String creditsPerMonth(String price);

  /// No description provided for @creditsTestPrice.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get creditsTestPrice;

  /// No description provided for @creditsPriceMissing.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get creditsPriceMissing;

  /// No description provided for @creditsTopUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Or top up credits'**
  String get creditsTopUpTitle;

  /// No description provided for @creditsPackSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}}, {price}'**
  String creditsPackSemantics(int count, String price);

  /// No description provided for @creditsPlanSemantics.
  ///
  /// In en, this message translates to:
  /// **'{plan} plan, {price}'**
  String creditsPlanSemantics(String plan, String price);

  /// No description provided for @creditsTestStoreNote.
  ///
  /// In en, this message translates to:
  /// **'Test store: nothing is charged. These purchases only work on test servers.'**
  String get creditsTestStoreNote;

  /// No description provided for @creditsContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {plan}'**
  String creditsContinueWith(String plan);

  /// No description provided for @creditsSwitchAtRenewal.
  ///
  /// In en, this message translates to:
  /// **'Switch to {plan} at renewal'**
  String creditsSwitchAtRenewal(String plan);

  /// No description provided for @creditsBuyPack.
  ///
  /// In en, this message translates to:
  /// **'Buy {count, plural, =1{1 credit} other{{count} credits}}'**
  String creditsBuyPack(int count);

  /// No description provided for @creditsCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'This is your plan'**
  String get creditsCurrentPlan;

  /// No description provided for @creditsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit added.} other{{count} credits added.}}'**
  String creditsAdded(int count);

  /// No description provided for @creditsPlanActive.
  ///
  /// In en, this message translates to:
  /// **'{plan} is active. {count, plural, =1{1 credit added.} other{{count} credits added.}}'**
  String creditsPlanActive(String plan, int count);

  /// No description provided for @creditsPlanAtRenewal.
  ///
  /// In en, this message translates to:
  /// **'You will move to {plan} when your current plan renews.'**
  String creditsPlanAtRenewal(String plan);

  /// No description provided for @creditsAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'This purchase was already added.'**
  String get creditsAlreadyAdded;

  /// No description provided for @creditsPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending. Credits are added once it clears.'**
  String get creditsPending;

  /// No description provided for @creditsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get creditsRetry;

  /// No description provided for @getCredits.
  ///
  /// In en, this message translates to:
  /// **'Get credits'**
  String get getCredits;

  /// No description provided for @failureOtpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not send the SMS. Try again in a moment.'**
  String get failureOtpSendFailed;

  /// No description provided for @verifySignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get verifySignInTitle;

  /// No description provided for @verifySignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'With your Google account'**
  String get verifySignInSubtitle;

  /// No description provided for @verifySignInSubtitleWithPhone.
  ///
  /// In en, this message translates to:
  /// **'With Google or your phone number'**
  String get verifySignInSubtitleWithPhone;

  /// No description provided for @verifySignInDone.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get verifySignInDone;

  /// No description provided for @verifySignInBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Google account to create your VYBE account. We never post anything to it.'**
  String get verifySignInBody;

  /// No description provided for @verifyContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get verifyContinueWithGoogle;

  /// No description provided for @verifyOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Or use your phone number'**
  String get verifyOrPhone;

  /// No description provided for @verifyTestAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a test account'**
  String get verifyTestAccount;

  /// No description provided for @verifyTestAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Test account email'**
  String get verifyTestAccountEmail;

  /// No description provided for @verifyTestAccountHint.
  ///
  /// In en, this message translates to:
  /// **'aarav@findx.test'**
  String get verifyTestAccountHint;

  /// No description provided for @verifyTestAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get verifyTestAccountSignIn;

  /// No description provided for @failureSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get failureSignInCanceled;

  /// No description provided for @failureGoogleSignInUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not set up on this build yet. Use a test account or try again later.'**
  String get failureGoogleSignInUnavailable;

  /// No description provided for @myProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get myProfileEmail;

  /// No description provided for @optLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get optLanguageEnglish;

  /// No description provided for @optLanguageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get optLanguageHindi;

  /// No description provided for @optLanguageMarathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get optLanguageMarathi;

  /// No description provided for @optLanguageGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get optLanguageGujarati;

  /// No description provided for @optLanguageTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get optLanguageTamil;

  /// No description provided for @optLanguageTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get optLanguageTelugu;

  /// No description provided for @optLanguageKannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get optLanguageKannada;

  /// No description provided for @optLanguageMalayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get optLanguageMalayalam;

  /// No description provided for @optLanguageBengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get optLanguageBengali;

  /// No description provided for @optLanguagePunjabi.
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get optLanguagePunjabi;

  /// No description provided for @optLanguageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get optLanguageUrdu;

  /// No description provided for @optLanguageOdia.
  ///
  /// In en, this message translates to:
  /// **'Odia'**
  String get optLanguageOdia;

  /// No description provided for @optEducationHighSchool.
  ///
  /// In en, this message translates to:
  /// **'High school'**
  String get optEducationHighSchool;

  /// No description provided for @optEducationDiploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get optEducationDiploma;

  /// No description provided for @optEducationBachelors.
  ///
  /// In en, this message translates to:
  /// **'Bachelor\'s degree'**
  String get optEducationBachelors;

  /// No description provided for @optEducationMasters.
  ///
  /// In en, this message translates to:
  /// **'Master\'s degree'**
  String get optEducationMasters;

  /// No description provided for @optEducationDoctorate.
  ///
  /// In en, this message translates to:
  /// **'Doctorate'**
  String get optEducationDoctorate;

  /// No description provided for @optEducationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get optEducationOther;

  /// No description provided for @optInterestMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get optInterestMusic;

  /// No description provided for @optInterestMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get optInterestMovies;

  /// No description provided for @optInterestTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get optInterestTravel;

  /// No description provided for @optInterestFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get optInterestFood;

  /// No description provided for @optInterestCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get optInterestCoffee;

  /// No description provided for @optInterestBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get optInterestBooks;

  /// No description provided for @optInterestFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get optInterestFitness;

  /// No description provided for @optInterestArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get optInterestArt;

  /// No description provided for @optInterestPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get optInterestPhotography;

  /// No description provided for @optInterestGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get optInterestGaming;

  /// No description provided for @optInterestCricket.
  ///
  /// In en, this message translates to:
  /// **'Cricket'**
  String get optInterestCricket;

  /// No description provided for @optInterestFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get optInterestFootball;

  /// No description provided for @optInterestDance.
  ///
  /// In en, this message translates to:
  /// **'Dance'**
  String get optInterestDance;

  /// No description provided for @optInterestTheatre.
  ///
  /// In en, this message translates to:
  /// **'Theatre'**
  String get optInterestTheatre;

  /// No description provided for @optInterestTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get optInterestTech;

  /// No description provided for @optInterestNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get optInterestNature;

  /// No description provided for @optInterestCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get optInterestCooking;

  /// No description provided for @optInterestFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get optInterestFashion;

  /// No description provided for @optPersonalityCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get optPersonalityCalm;

  /// No description provided for @optPersonalityCheerful.
  ///
  /// In en, this message translates to:
  /// **'Cheerful'**
  String get optPersonalityCheerful;

  /// No description provided for @optPersonalityCurious.
  ///
  /// In en, this message translates to:
  /// **'Curious'**
  String get optPersonalityCurious;

  /// No description provided for @optPersonalityAdventurous.
  ///
  /// In en, this message translates to:
  /// **'Adventurous'**
  String get optPersonalityAdventurous;

  /// No description provided for @optPersonalityThoughtful.
  ///
  /// In en, this message translates to:
  /// **'Thoughtful'**
  String get optPersonalityThoughtful;

  /// No description provided for @optPersonalityWitty.
  ///
  /// In en, this message translates to:
  /// **'Witty'**
  String get optPersonalityWitty;

  /// No description provided for @optPersonalityEasygoing.
  ///
  /// In en, this message translates to:
  /// **'Easygoing'**
  String get optPersonalityEasygoing;

  /// No description provided for @optPersonalityAmbitious.
  ///
  /// In en, this message translates to:
  /// **'Ambitious'**
  String get optPersonalityAmbitious;

  /// No description provided for @optSocialEnergyIntrovert.
  ///
  /// In en, this message translates to:
  /// **'Introvert'**
  String get optSocialEnergyIntrovert;

  /// No description provided for @optSocialEnergyAmbivert.
  ///
  /// In en, this message translates to:
  /// **'Somewhere in between'**
  String get optSocialEnergyAmbivert;

  /// No description provided for @optSocialEnergyExtrovert.
  ///
  /// In en, this message translates to:
  /// **'Extrovert'**
  String get optSocialEnergyExtrovert;

  /// No description provided for @optHabitNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get optHabitNever;

  /// No description provided for @optHabitSocially.
  ///
  /// In en, this message translates to:
  /// **'Socially'**
  String get optHabitSocially;

  /// No description provided for @optHabitRegularly.
  ///
  /// In en, this message translates to:
  /// **'Regularly'**
  String get optHabitRegularly;

  /// No description provided for @optFitnessRarely.
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get optFitnessRarely;

  /// No description provided for @optFitnessSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get optFitnessSometimes;

  /// No description provided for @optFitnessActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get optFitnessActive;

  /// No description provided for @optFitnessVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get optFitnessVeryActive;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @editProfilePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get editProfilePhotos;

  /// No description provided for @editProfilePhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Add up to {count} photos. Clear photos of your face get more meetups.'**
  String editProfilePhotosHint(int count);

  /// No description provided for @editProfileMainPhoto.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get editProfileMainPhoto;

  /// No description provided for @editProfileAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get editProfileAddPhoto;

  /// No description provided for @editProfileFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get editProfileFromGallery;

  /// No description provided for @editProfileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editProfileTakePhoto;

  /// No description provided for @editProfileMakeMain.
  ///
  /// In en, this message translates to:
  /// **'Make main photo'**
  String get editProfileMakeMain;

  /// No description provided for @editProfileRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get editProfileRemovePhoto;

  /// No description provided for @editProfileUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get editProfileUploading;

  /// No description provided for @editProfileBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get editProfileBasics;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get editProfileName;

  /// No description provided for @editProfileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get editProfileAge;

  /// No description provided for @editProfileAgeFromId.
  ///
  /// In en, this message translates to:
  /// **'From your ID check'**
  String get editProfileAgeFromId;

  /// No description provided for @editProfileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editProfileGender;

  /// No description provided for @editProfileAboutMe.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get editProfileAboutMe;

  /// No description provided for @editProfileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get editProfileCity;

  /// No description provided for @editProfileLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages I speak'**
  String get editProfileLanguages;

  /// No description provided for @editProfileWork.
  ///
  /// In en, this message translates to:
  /// **'What I do'**
  String get editProfileWork;

  /// No description provided for @editProfileEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get editProfileEducation;

  /// No description provided for @editProfileProfession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get editProfileProfession;

  /// No description provided for @editProfileStory.
  ///
  /// In en, this message translates to:
  /// **'My story'**
  String get editProfileStory;

  /// No description provided for @editProfileBioHint.
  ///
  /// In en, this message translates to:
  /// **'A few lines about you and the plans you enjoy'**
  String get editProfileBioHint;

  /// No description provided for @editProfilePersonality.
  ///
  /// In en, this message translates to:
  /// **'My personality'**
  String get editProfilePersonality;

  /// No description provided for @editProfileHowIAm.
  ///
  /// In en, this message translates to:
  /// **'How I am'**
  String get editProfileHowIAm;

  /// No description provided for @editProfileSocialEnergy.
  ///
  /// In en, this message translates to:
  /// **'Social energy'**
  String get editProfileSocialEnergy;

  /// No description provided for @editProfileLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get editProfileLifestyle;

  /// No description provided for @editProfileDrinking.
  ///
  /// In en, this message translates to:
  /// **'Drinking'**
  String get editProfileDrinking;

  /// No description provided for @editProfileSmoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get editProfileSmoking;

  /// No description provided for @editProfileFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get editProfileFitness;

  /// No description provided for @editProfileThingsILove.
  ///
  /// In en, this message translates to:
  /// **'Things I love'**
  String get editProfileThingsILove;

  /// No description provided for @editProfileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get editProfileNotSet;

  /// No description provided for @editProfilePickUpTo.
  ///
  /// In en, this message translates to:
  /// **'Pick up to {count}'**
  String editProfilePickUpTo(int count);

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSave;

  /// No description provided for @editProfileClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get editProfileClear;

  /// No description provided for @editProfileSelectedMore.
  ///
  /// In en, this message translates to:
  /// **'{first} + {count} more'**
  String editProfileSelectedMore(String first, int count);

  /// No description provided for @profileLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Speaks'**
  String get profileLanguagesTitle;

  /// No description provided for @profileInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loves'**
  String get profileInterestsTitle;

  /// No description provided for @profileLifestyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get profileLifestyleTitle;

  /// No description provided for @venueMall.
  ///
  /// In en, this message translates to:
  /// **'Mall'**
  String get venueMall;

  /// No description provided for @venueTheatre.
  ///
  /// In en, this message translates to:
  /// **'Theatre'**
  String get venueTheatre;

  /// No description provided for @feedViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View full profile'**
  String get feedViewProfile;

  /// No description provided for @feedPhotoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo {index} of {total} of {name}'**
  String feedPhotoOf(String name, int index, int total);

  /// No description provided for @feedEndBody.
  ///
  /// In en, this message translates to:
  /// **'New people join every day. Try another plan or check back soon.'**
  String get feedEndBody;

  /// No description provided for @mapRecenter.
  ///
  /// In en, this message translates to:
  /// **'Back to my location'**
  String get mapRecenter;

  /// No description provided for @sampleProfileTag.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sampleProfileTag;

  /// No description provided for @sampleProfileNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a sample profile. Real members near you will appear here as people join.'**
  String get sampleProfileNotice;

  /// No description provided for @reelProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get reelProfile;

  /// No description provided for @reelSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get reelSaved;

  /// No description provided for @reelStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get reelStartAgain;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
