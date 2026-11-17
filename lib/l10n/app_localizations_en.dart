// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VYBE';

  @override
  String get startTagline => 'Meet new people, safely';

  @override
  String get mapHeroTag => 'Verified public spots only';

  @override
  String get startLoading => 'Getting things ready';

  @override
  String get bootstrapErrorTitle => 'VYBE could not start';

  @override
  String get bootstrapNoConnection =>
      'Check your internet connection and try again.';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonBack => 'Back';

  @override
  String get commonLoading => 'Loading';

  @override
  String get stateEmptyTitle => 'Nothing here yet';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateOfflineTitle => 'You are offline';

  @override
  String get stateOfflineMessage =>
      'Check your connection. This screen updates when you are back online.';

  @override
  String get offlineBanner => 'You are offline. Some info may be out of date.';

  @override
  String get failureNetwork =>
      'We could not reach VYBE. Check your connection and try again.';

  @override
  String get failureOffline =>
      'You are offline. Connect to the internet and try again.';

  @override
  String get failureUnauthenticated => 'Please sign in again.';

  @override
  String get failurePermissionDenied => 'You do not have access to this.';

  @override
  String get failureNotVerified => 'Finish verification to do this.';

  @override
  String get failureInsufficientCredits =>
      'You do not have enough credits for this.';

  @override
  String get failureSlotFull =>
      'That time slot just filled up. Pick another one.';

  @override
  String get failureBlocked => 'This person is not available.';

  @override
  String get failureModerationBlocked =>
      'Phone numbers, emails, social handles and links cannot be shared in chat.';

  @override
  String get failureNotFound => 'We could not find that.';

  @override
  String get failureRateLimited =>
      'Too many tries. Please wait a moment and try again.';

  @override
  String get failureInvalidInput => 'Please check what you entered.';

  @override
  String get failureUnknown => 'Something went wrong. Please try again.';

  @override
  String get failureWrongCode =>
      'That code is not right. Check the SMS and try again.';

  @override
  String get failureCodeExpired =>
      'This code has expired. Tap Resend code to get a new one.';

  @override
  String get failurePurchaseInvalid =>
      'The store could not confirm this purchase. You have not been charged credits.';

  @override
  String get failureStoreUnavailable =>
      'Purchases are not available on this device right now.';

  @override
  String get notFoundTitle => 'We could not find that page';

  @override
  String get notFoundAction => 'Go to start';

  @override
  String get badgeVerified => 'Verified';

  @override
  String get badgeFreeNow => 'Free now';

  @override
  String creditsPillSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0. Open credits and plans';
  }

  @override
  String stepSemanticsDone(int number) {
    return 'Step $number, done';
  }

  @override
  String stepSemanticsCurrent(int number) {
    return 'Step $number, in progress';
  }

  @override
  String stepSemanticsUpcoming(int number) {
    return 'Step $number, not started';
  }

  @override
  String get planCoffee => 'Coffee';

  @override
  String get planMovie => 'Movie';

  @override
  String get planEvent => 'Event';

  @override
  String get planWalk => 'Walk';

  @override
  String get planDinner => 'Dinner';

  @override
  String get statRating => 'Rating';

  @override
  String get statMeetups => 'Meetups';

  @override
  String get statAge => 'Age';

  @override
  String safetyNotePublicSpots(int km) {
    return 'Meet only at verified public spots within $km km.';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your profile, photos, ID images, preferences, saved people and credits are deleted for good. Open bookings are cancelled and your chats close. This cannot be undone.\n\nTo stop a Plus or Premium plan from renewing, cancel it in Google Play too.';

  @override
  String get deleteAccountConfirm => 'Delete for good';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get rulesForTitle => 'This app is for';

  @override
  String get rulesFor1 => 'Coffee, movies, walks, dinners and events';

  @override
  String get rulesFor2 => 'Meeting at verified public venues only';

  @override
  String get rulesFor3 => 'Respectful, friendly company';

  @override
  String get rulesNotForTitle => 'Not for';

  @override
  String get rulesNotFor1 => 'Sexual services or any kind of solicitation';

  @override
  String get rulesNotFor2 => 'Meeting at private homes, hotels or rooms';

  @override
  String get rulesNotFor3 =>
      'Sharing phone numbers or taking chats off the app';

  @override
  String get rulesConsent =>
      'I am 18 or older and I agree to these rules. Breaking them means a permanent ban.';

  @override
  String get rulesContinue => 'I agree, continue';

  @override
  String get verifyTitle => 'Verify it is you';

  @override
  String get verifySelfieTitle => 'Selfie check';

  @override
  String get verifySelfieSubtitle => 'Takes about 20 seconds';

  @override
  String get verifyIdTitle => 'ID check';

  @override
  String get verifyIdSubtitle => 'Aadhaar, passport or licence';

  @override
  String get verifyPhoneLabel => 'Mobile number';

  @override
  String get verifyPhoneHint => '98765 43210';

  @override
  String verifyPhoneInvalid(int length) {
    return 'Enter a valid $length-digit mobile number.';
  }

  @override
  String get verifySendCode => 'Send code';

  @override
  String verifyOtpLabel(int length) {
    return '$length-digit code';
  }

  @override
  String verifyOtpSentTo(String phone) {
    return 'We sent a code to $phone.';
  }

  @override
  String verifyOtpInvalid(int length) {
    return 'Enter the $length-digit code.';
  }

  @override
  String get verifyConfirmCode => 'Verify code';

  @override
  String verifyResendIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get verifyResend => 'Resend code';

  @override
  String get verifyChangeNumber => 'Change number';

  @override
  String get verifyUseDifferentNumber => 'Use a different number';

  @override
  String get verifyFinishTitle => 'Finish setting up your account';

  @override
  String get verifyFinishBody =>
      'Your number is verified. Tap continue to create your account.';

  @override
  String get verifyContinue => 'Continue';

  @override
  String get verifySelfieFrame => 'Fit your face in the frame';

  @override
  String get verifyTakeSelfie => 'Take selfie';

  @override
  String get verifyIdPrivacy =>
      'Your ID is encrypted and is never shown to other users.';

  @override
  String get verifyChooseId => 'Which ID will you use?';

  @override
  String get idAadhaar => 'Aadhaar';

  @override
  String get idPassport => 'Passport';

  @override
  String get idDrivingLicence => 'Driving licence';

  @override
  String get verifyIdFrame => 'Photograph the front of your ID in good light';

  @override
  String get verifyTakeIdPhoto => 'Take ID photo';

  @override
  String get verifyReviewTitle => 'We are checking your photo';

  @override
  String get verifyReviewBody =>
      'This usually takes a few minutes. You can close the app and come back.';

  @override
  String get verifyRejectedTitle => 'We could not verify this photo';

  @override
  String get verifyRejectedBody =>
      'Make sure it is clear, well lit and not cut off, then try again.';

  @override
  String get verifyTryAgain => 'Try again';

  @override
  String get verifyUnderageTitle => 'VYBE is for adults only';

  @override
  String get verifyUnderageBody =>
      'Your ID shows you are under 18, so you cannot use VYBE.';

  @override
  String get prefsTitle => 'Who do you want to meet?';

  @override
  String get prefsSubtitle =>
      'Everyone is welcome here. You decide who you see.';

  @override
  String get prefsIAm => 'I am';

  @override
  String get genderWoman => 'Woman';

  @override
  String get genderMan => 'Man';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderUndisclosed => 'Prefer not to say';

  @override
  String get prefsShowMe => 'Show me';

  @override
  String get showMeWomen => 'Women';

  @override
  String get showMeMen => 'Men';

  @override
  String get showMeEveryone => 'Everyone';

  @override
  String get prefsAgeRange => 'Age range';

  @override
  String prefsAgeRangeValue(int min, int max) {
    return '$min to $max';
  }

  @override
  String prefsAgeMin(int age) {
    return 'Youngest age, $age';
  }

  @override
  String prefsAgeMax(int age) {
    return 'Oldest age, $age';
  }

  @override
  String get prefsDistance => 'Distance';

  @override
  String prefsDistanceValue(int km) {
    return 'Within $km km';
  }

  @override
  String get prefsShowGender => 'Show my gender on my profile';

  @override
  String get prefsShowGenderSubtitle =>
      'Off by default. Only used to decide who sees you.';

  @override
  String get prefsStart => 'Start exploring';

  @override
  String get suspendedTitle => 'Your account is suspended';

  @override
  String get suspendedBody =>
      'This account was suspended for breaking the VYBE rules.';

  @override
  String creditsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0';
  }

  @override
  String get failureLocationRequired =>
      'Share your location to see people near you.';

  @override
  String get failureLocationDenied =>
      'Location is off or not allowed for VYBE.';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navChats => 'Chats';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String discoverShowing(String who) {
    return 'Showing: $who';
  }

  @override
  String get discoverMap => 'Map';

  @override
  String get discoverFreeNowLink => 'See who is free right now';

  @override
  String get discoverEmptyTitle => 'No one nearby yet';

  @override
  String get discoverEmptyBody =>
      'Try another plan, or see who is free right now.';

  @override
  String get discoverAllSeenTitle => 'You have seen everyone for now';

  @override
  String get discoverMessage => 'Message';

  @override
  String get discoverSave => 'Save';

  @override
  String get discoverUnsave => 'Remove from saved';

  @override
  String cardNameAge(String name, int age) {
    return '$name, $age';
  }

  @override
  String cardAboutKmAway(int km) {
    return 'About $km km away';
  }

  @override
  String cardFreeUntil(String time) {
    return 'free until $time';
  }

  @override
  String cardSpotsNearby(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots nearby',
      one: '1 spot nearby',
      zero: 'No spots nearby',
    );
    return '$_temp0';
  }

  @override
  String voiceIntroPlay(int seconds) {
    return 'Play voice intro, $seconds seconds';
  }

  @override
  String get voiceIntroStop => 'Stop voice intro';

  @override
  String voiceDuration(int minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get promptIdealSunday => 'My ideal Sunday';

  @override
  String get tagCoffee => 'Coffee meetup';

  @override
  String get tagMovie => 'Movie';

  @override
  String get tagEvent => 'Event plus-one';

  @override
  String get tagWalk => 'Walk';

  @override
  String get tagDinner => 'Dinner';

  @override
  String get locationNeededTitle => 'Location is needed';

  @override
  String locationNeededBody(int km) {
    return 'VYBE uses your location to show verified companions and public spots within $km km. Other people never see your exact location.';
  }

  @override
  String get locationAllow => 'Allow location';

  @override
  String get locationOpenSettings => 'Open settings';

  @override
  String get nameBannerTitle => 'Add your first name';

  @override
  String get nameBannerBody =>
      'Companions see your first name when you ask to meet.';

  @override
  String get nameBannerAction => 'Add name';

  @override
  String get freeNowTitle => 'Free right now';

  @override
  String freeNowSubtitle(int km) {
    return 'Verified companions within $km km.';
  }

  @override
  String get freeNowNext2h => 'Next 2 hrs';

  @override
  String get freeNowTonight => 'Tonight';

  @override
  String get freeNowTomorrow => 'Tomorrow';

  @override
  String freeUntil(String time) {
    return 'Free until $time';
  }

  @override
  String freeBetween(String from, String until) {
    return 'Free $from to $until';
  }

  @override
  String aboutKm(int km) {
    return 'About $km km';
  }

  @override
  String get freeNowEmptyTitle => 'No one is free in this window';

  @override
  String get freeNowEmptyBody => 'Try tonight or tomorrow.';

  @override
  String get instantTitle => 'Request instantly';

  @override
  String instantBody(int credits) {
    return 'Costs $credits credits';
  }

  @override
  String get instantPickSpot => 'Pick spot';

  @override
  String get profileNewRating => 'New';

  @override
  String get profileChat => 'Chat';

  @override
  String get profileBookSpot => 'Book your spot';

  @override
  String get myProfileTitle => 'Your profile';

  @override
  String get myProfileName => 'First name';

  @override
  String get myProfileNameHint => 'How companions will see you';

  @override
  String get myProfileSaveName => 'Save name';

  @override
  String get myProfileNameSaved => 'Name saved';

  @override
  String myProfileNameInvalid(int max) {
    return 'Enter your first name, up to $max characters.';
  }

  @override
  String get myProfilePhone => 'Phone';

  @override
  String get myProfileSaved => 'Saved companions';

  @override
  String get savedTitle => 'Saved companions';

  @override
  String get savedEmptyTitle => 'No saved companions yet';

  @override
  String get savedEmptyBody => 'Tap Save on a profile to keep it here.';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatsEmptyTitle => 'No chats yet';

  @override
  String get chatsEmptyBody => 'Your chats with companions will show here.';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get bookingsEmptyTitle => 'No bookings yet';

  @override
  String get bookingsEmptyBody => 'Your booked spots will show here.';

  @override
  String get failureCompanionUnavailable =>
      'They are not free at that time. Pick another time.';

  @override
  String mapWithinKm(int km) {
    return 'Within $km km';
  }

  @override
  String mapSemantics(int km) {
    return 'Map of verified spots within $km km of you';
  }

  @override
  String get mapBestSpots => 'Best spots to meet';

  @override
  String get mapToday => 'Today';

  @override
  String get mapPick => 'Pick';

  @override
  String mapPickSemantics(String venue) {
    return 'Pick $venue';
  }

  @override
  String get mapNoVenuesTitle => 'No verified spots nearby yet';

  @override
  String get mapNoVenuesBody => 'Try another plan.';

  @override
  String venueLine(String category, String km, String busy) {
    return '$category · $km km · $busy';
  }

  @override
  String get venueCafe => 'Cafe';

  @override
  String get venueFoodCourt => 'Food court';

  @override
  String get venueOpenPark => 'Open park';

  @override
  String get venueCinema => 'Cinema';

  @override
  String get venueRestaurant => 'Restaurant';

  @override
  String get venueOther => 'Public venue';

  @override
  String get busyHotNow => 'Hot now';

  @override
  String get busyBusy => 'Busy';

  @override
  String get busyQuiet => 'Quiet';

  @override
  String get bookTitle => 'Book your spot';

  @override
  String bookVenueLine(String km) {
    return '$km km · Verified public venue';
  }

  @override
  String get bookChange => 'Change';

  @override
  String get bookDay => 'Day';

  @override
  String get bookToday => 'Today';

  @override
  String get bookPickDay => 'Pick a day';

  @override
  String get bookTimeSlot => 'Time slot';

  @override
  String get bookNoSlots => 'No times left on this day. Try another day.';

  @override
  String bookSlotUnavailableSemantics(String time) {
    return '$time, not available';
  }

  @override
  String get bookSafety =>
      'Both of you get a reminder and live location sharing on the day.';

  @override
  String get bookCostLabel => 'Spot booking';

  @override
  String get bookInstantCostLabel => 'Instant request';

  @override
  String get bookNoRefund =>
      'Credits are not refunded if the request is declined or cancelled.';

  @override
  String get bookConfirm => 'Confirm spot';

  @override
  String bookSent(String name) {
    return 'Request sent to $name.';
  }

  @override
  String get bookNoVenue =>
      'There are no verified spots you can both reach for this plan.';

  @override
  String get bookingsStatusRequested => 'Waiting for reply';

  @override
  String get bookingsStatusAccepted => 'Confirmed';

  @override
  String get bookingsStatusDeclined => 'Declined';

  @override
  String get bookingsStatusCancelled => 'Cancelled';

  @override
  String get bookingsStatusCheckedIn => 'Checked in';

  @override
  String get bookingsStatusCompleted => 'Completed';

  @override
  String get bookingsStatusDisputed => 'Under review';

  @override
  String get bookingsStatusTimePassed => 'Time passed';

  @override
  String bookingsWith(String plan, String name) {
    return '$plan with $name';
  }

  @override
  String get bookingsCancel => 'Cancel';

  @override
  String get bookingsCancelTitle => 'Cancel this booking?';

  @override
  String get bookingsCancelBody =>
      'Your table is released. Credits are not refunded.';

  @override
  String get bookingsCancelConfirm => 'Cancel booking';

  @override
  String get bookingsKeep => 'Keep it';

  @override
  String get bookingsCancelled => 'Booking cancelled.';

  @override
  String get freeNowSelectHint =>
      'Tap someone to choose them, then pick a spot.';

  @override
  String get freeNowViewProfile => 'View profile';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get chatNotice =>
      'Chat is for planning your meetup. Phone numbers and off-app contact are blocked.';

  @override
  String chatStartedCredits(int credits) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '$credits credits used to start this chat',
      one: '1 credit used to start this chat',
    );
    return '$_temp0';
  }

  @override
  String get chatInputHint => 'Type a message';

  @override
  String get chatSend => 'Send message';

  @override
  String get chatReport => 'Report';

  @override
  String get chatClosed => 'This chat is closed.';

  @override
  String chatBookTitle(String name) {
    return 'Book your spot with $name';
  }

  @override
  String get chatBook => 'Book';

  @override
  String chatBookingCardTitle(String plan) {
    return '$plan meetup';
  }

  @override
  String chatBookingCardLine(String when, String venue) {
    return '$when · $venue';
  }

  @override
  String get chatPreviewBooking => 'Booking request';

  @override
  String get chatPreviewStarted => 'Chat started';

  @override
  String chatStartTitle(String name) {
    return 'Start a chat with $name?';
  }

  @override
  String chatStartBody(String cost) {
    return 'This uses $cost. Credits are not refunded.';
  }

  @override
  String get chatStartConfirm => 'Start chat';

  @override
  String chatsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get reportOrBlock => 'Report or block';

  @override
  String reportTitle(String name) {
    return 'Report $name';
  }

  @override
  String get reportReasonInappropriate => 'Inappropriate messages';

  @override
  String get reportReasonContact => 'Asked for my number or other contact';

  @override
  String get reportReasonHarassment => 'Harassment or pressure';

  @override
  String get reportReasonFake => 'Fake profile';

  @override
  String get reportReasonSafety => 'I felt unsafe';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get reportDetailsHint => 'Anything else we should know (optional)';

  @override
  String get reportSubmit => 'Send report';

  @override
  String get reportSent => 'Thanks. Our safety team will review this.';

  @override
  String blockAction(String name) {
    return 'Block $name';
  }

  @override
  String blockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockBody =>
      'You will not see each other anywhere on VYBE. Your chat closes and open bookings are cancelled. Credits are not refunded.';

  @override
  String get blockConfirm => 'Block';

  @override
  String blockDone(String name) {
    return '$name is blocked.';
  }

  @override
  String get creditsTitle => 'Get more credits';

  @override
  String get creditsSubtitle => 'Unlock new chats.';

  @override
  String get planFree => 'Free';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPremium => 'Premium';

  @override
  String get creditsFreePrice => '₹0';

  @override
  String creditsFreeDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0 when you join';
  }

  @override
  String creditsPlanDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0 a month · unused credits stay';
  }

  @override
  String get creditsPopular => 'Popular';

  @override
  String get creditsYourPlan => 'Your plan';

  @override
  String creditsRenews(String date) {
    return 'Renews $date';
  }

  @override
  String creditsMovesTo(String plan, String date) {
    return 'Moves to $plan on $date';
  }

  @override
  String creditsPerMonth(String price) {
    return '$price/mo';
  }

  @override
  String get creditsTestPrice => 'Test';

  @override
  String get creditsPriceMissing => 'Not available';

  @override
  String get creditsTopUpTitle => 'Or top up credits';

  @override
  String creditsPackSemantics(int count, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0, $price';
  }

  @override
  String creditsPlanSemantics(String plan, String price) {
    return '$plan plan, $price';
  }

  @override
  String get creditsTestStoreNote =>
      'Test store: nothing is charged. These purchases only work on test servers.';

  @override
  String creditsContinueWith(String plan) {
    return 'Continue with $plan';
  }

  @override
  String creditsSwitchAtRenewal(String plan) {
    return 'Switch to $plan at renewal';
  }

  @override
  String creditsBuyPack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return 'Buy $_temp0';
  }

  @override
  String get creditsCurrentPlan => 'This is your plan';

  @override
  String creditsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits added.',
      one: '1 credit added.',
    );
    return '$_temp0';
  }

  @override
  String creditsPlanActive(String plan, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits added.',
      one: '1 credit added.',
    );
    return '$plan is active. $_temp0';
  }

  @override
  String creditsPlanAtRenewal(String plan) {
    return 'You will move to $plan when your current plan renews.';
  }

  @override
  String get creditsAlreadyAdded => 'This purchase was already added.';

  @override
  String get creditsPending =>
      'Payment pending. Credits are added once it clears.';

  @override
  String get creditsRetry => 'Try again';

  @override
  String get getCredits => 'Get credits';

  @override
  String get failureOtpSendFailed =>
      'We could not send the SMS. Try again in a moment.';

  @override
  String get verifySignInTitle => 'Sign in';

  @override
  String get verifySignInSubtitle => 'With your Google account';

  @override
  String get verifySignInSubtitleWithPhone =>
      'With Google or your phone number';

  @override
  String get verifySignInDone => 'Signed in';

  @override
  String get verifySignInBody =>
      'Sign in with your Google account to create your VYBE account. We never post anything to it.';

  @override
  String get verifyContinueWithGoogle => 'Continue with Google';

  @override
  String get verifyOrPhone => 'Or use your phone number';

  @override
  String get verifyTestAccount => 'Use a test account';

  @override
  String get verifyTestAccountEmail => 'Test account email';

  @override
  String get verifyTestAccountHint => 'aarav@findx.test';

  @override
  String get verifyTestAccountSignIn => 'Sign in';

  @override
  String get failureSignInCanceled => 'Sign-in was cancelled.';

  @override
  String get failureGoogleSignInUnavailable =>
      'Google sign-in is not set up on this build yet. Use a test account or try again later.';

  @override
  String get myProfileEmail => 'Signed in as';

  @override
  String get optLanguageEnglish => 'English';

  @override
  String get optLanguageHindi => 'Hindi';

  @override
  String get optLanguageMarathi => 'Marathi';

  @override
  String get optLanguageGujarati => 'Gujarati';

  @override
  String get optLanguageTamil => 'Tamil';

  @override
  String get optLanguageTelugu => 'Telugu';

  @override
  String get optLanguageKannada => 'Kannada';

  @override
  String get optLanguageMalayalam => 'Malayalam';

  @override
  String get optLanguageBengali => 'Bengali';

  @override
  String get optLanguagePunjabi => 'Punjabi';

  @override
  String get optLanguageUrdu => 'Urdu';

  @override
  String get optLanguageOdia => 'Odia';

  @override
  String get optEducationHighSchool => 'High school';

  @override
  String get optEducationDiploma => 'Diploma';

  @override
  String get optEducationBachelors => 'Bachelor\'s degree';

  @override
  String get optEducationMasters => 'Master\'s degree';

  @override
  String get optEducationDoctorate => 'Doctorate';

  @override
  String get optEducationOther => 'Other';

  @override
  String get optInterestMusic => 'Music';

  @override
  String get optInterestMovies => 'Movies';

  @override
  String get optInterestTravel => 'Travel';

  @override
  String get optInterestFood => 'Food';

  @override
  String get optInterestCoffee => 'Coffee';

  @override
  String get optInterestBooks => 'Books';

  @override
  String get optInterestFitness => 'Fitness';

  @override
  String get optInterestArt => 'Art';

  @override
  String get optInterestPhotography => 'Photography';

  @override
  String get optInterestGaming => 'Gaming';

  @override
  String get optInterestCricket => 'Cricket';

  @override
  String get optInterestFootball => 'Football';

  @override
  String get optInterestDance => 'Dance';

  @override
  String get optInterestTheatre => 'Theatre';

  @override
  String get optInterestTech => 'Tech';

  @override
  String get optInterestNature => 'Nature';

  @override
  String get optInterestCooking => 'Cooking';

  @override
  String get optInterestFashion => 'Fashion';

  @override
  String get optPersonalityCalm => 'Calm';

  @override
  String get optPersonalityCheerful => 'Cheerful';

  @override
  String get optPersonalityCurious => 'Curious';

  @override
  String get optPersonalityAdventurous => 'Adventurous';

  @override
  String get optPersonalityThoughtful => 'Thoughtful';

  @override
  String get optPersonalityWitty => 'Witty';

  @override
  String get optPersonalityEasygoing => 'Easygoing';

  @override
  String get optPersonalityAmbitious => 'Ambitious';

  @override
  String get optSocialEnergyIntrovert => 'Introvert';

  @override
  String get optSocialEnergyAmbivert => 'Somewhere in between';

  @override
  String get optSocialEnergyExtrovert => 'Extrovert';

  @override
  String get optHabitNever => 'Never';

  @override
  String get optHabitSocially => 'Socially';

  @override
  String get optHabitRegularly => 'Regularly';

  @override
  String get optFitnessRarely => 'Rarely';

  @override
  String get optFitnessSometimes => 'Sometimes';

  @override
  String get optFitnessActive => 'Active';

  @override
  String get optFitnessVeryActive => 'Very active';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editProfilePhotos => 'Photos';

  @override
  String editProfilePhotosHint(int count) {
    return 'Add up to $count photos. Clear photos of your face get more meetups.';
  }

  @override
  String get editProfileMainPhoto => 'Main';

  @override
  String get editProfileAddPhoto => 'Add photo';

  @override
  String get editProfileFromGallery => 'Choose from gallery';

  @override
  String get editProfileTakePhoto => 'Take a photo';

  @override
  String get editProfileMakeMain => 'Make main photo';

  @override
  String get editProfileRemovePhoto => 'Remove photo';

  @override
  String get editProfileUploading => 'Uploading';

  @override
  String get editProfileBasics => 'Basics';

  @override
  String get editProfileName => 'First name';

  @override
  String get editProfileAge => 'Age';

  @override
  String get editProfileAgeFromId => 'From your ID check';

  @override
  String get editProfileGender => 'Gender';

  @override
  String get editProfileAboutMe => 'About me';

  @override
  String get editProfileCity => 'City';

  @override
  String get editProfileLanguages => 'Languages I speak';

  @override
  String get editProfileWork => 'What I do';

  @override
  String get editProfileEducation => 'Education';

  @override
  String get editProfileProfession => 'Profession';

  @override
  String get editProfileStory => 'My story';

  @override
  String get editProfileBioHint =>
      'A few lines about you and the plans you enjoy';

  @override
  String get editProfilePersonality => 'My personality';

  @override
  String get editProfileHowIAm => 'How I am';

  @override
  String get editProfileSocialEnergy => 'Social energy';

  @override
  String get editProfileLifestyle => 'Lifestyle';

  @override
  String get editProfileDrinking => 'Drinking';

  @override
  String get editProfileSmoking => 'Smoking';

  @override
  String get editProfileFitness => 'Fitness';

  @override
  String get editProfileThingsILove => 'Things I love';

  @override
  String get editProfileNotSet => 'Add';

  @override
  String editProfilePickUpTo(int count) {
    return 'Pick up to $count';
  }

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileClear => 'Clear';

  @override
  String editProfileSelectedMore(String first, int count) {
    return '$first + $count more';
  }

  @override
  String get profileLanguagesTitle => 'Speaks';

  @override
  String get profileInterestsTitle => 'Loves';

  @override
  String get profileLifestyleTitle => 'Lifestyle';

  @override
  String get venueMall => 'Mall';

  @override
  String get venueTheatre => 'Theatre';

  @override
  String get feedViewProfile => 'View full profile';

  @override
  String feedPhotoOf(String name, int index, int total) {
    return 'Photo $index of $total of $name';
  }

  @override
  String get feedEndBody =>
      'New people join every day. Try another plan or check back soon.';

  @override
  String get mapRecenter => 'Back to my location';

  @override
  String get sampleProfileTag => 'Sample';

  @override
  String get sampleProfileNotice =>
      'This is a sample profile. Real members near you will appear here as people join.';

  @override
  String get reelProfile => 'Profile';

  @override
  String get reelSaved => 'Saved';

  @override
  String get reelStartAgain => 'Start again';

  @override
  String get costFree => 'Free';

  @override
  String get instantBodyFree => 'Free · they get your request right away';

  @override
  String get reelBook => 'Book';

  @override
  String reelBookWith(String name) {
    return 'Book a meetup with $name';
  }

  @override
  String get navReels => 'Reels';

  @override
  String get reelsPost => 'Post a reel';

  @override
  String get reelsRecord => 'Record a video';

  @override
  String get reelsPickGallery => 'Choose from gallery';

  @override
  String get reelsEmptyTitle => 'No reels yet';

  @override
  String get reelsEmptyBody =>
      'Post a short video to show people what you are into.';

  @override
  String get reelVideo => 'Video';

  @override
  String get reelPlay => 'Play';

  @override
  String get reelPause => 'Pause';

  @override
  String get reelCouldNotPlay => 'This video could not play';

  @override
  String get reelMute => 'Sound off';

  @override
  String get reelUnmute => 'Sound on';

  @override
  String get reelMore => 'More';

  @override
  String get reelReport => 'Report or block';

  @override
  String get reelYou => 'You';

  @override
  String get reelDelete => 'Delete';

  @override
  String get reelDeleteTitle => 'Delete this reel?';

  @override
  String get reelDeleteBody =>
      'It is removed for everyone. This cannot be undone.';

  @override
  String get reelDeleted => 'Reel deleted';

  @override
  String get reelTooBig => 'This video is too big. Pick one under 50 MB.';

  @override
  String get newReelTitle => 'New reel';

  @override
  String get newReelCaption => 'Caption';

  @override
  String get newReelCaptionHint => 'Say something about it (optional)';

  @override
  String get newReelRules =>
      'Keep it friendly: no nudity, hate or contact details. Reels that break the rules are removed.';

  @override
  String get newReelPost => 'Post';

  @override
  String get newReelPosted => 'Your reel is posted';
}
