class AppExceptions implements Exception {
  final String message;
  AppExceptions(this.message);

  @override
  String toString() => message;

  factory AppExceptions.fromFirebaseAuth(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AppExceptions('This email is already on Pocki 💕');
      case 'invalid-email':
        return AppExceptions('Hmm... that email doesn\'t look right 😅');
      case 'weak-password':
        return AppExceptions('Make your password a little stronger 🔐');
      case 'wrong-password':
        return AppExceptions('Oops! Wrong password 😅');
      case 'user-not-found':
        return AppExceptions('We couldn\'t find that account 🥲');
      case 'network-request-failed':
        return AppExceptions('Looks like your internet took a little break 🌐');
      default:
        return AppExceptions('Oops! Something went wrong. Let\'s try again ✨');
    }
  }
}
