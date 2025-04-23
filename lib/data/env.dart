class Environment{
  static const String baseUrl = "https://race-tracking-app-fbv1-default-rtdb.asia-southeast1.firebasedatabase.app/";
  static const String participantsCollection = "participants";
  static const String racesCollection = "races";

  static const String allParticipantsUrl  = '$baseUrl/$participantsCollection.json';
  static const String allRacesUrl  = '$baseUrl/$racesCollection.json';

}
