/// Normalizes UI mood strings to database format
String normalizeMood(String ui) => ui.toLowerCase();

/// Normalizes UI genre strings to database format
String normalizeGenre(String ui) => ui.toLowerCase().replaceAll('k-pop', 'kpop');

/// Normalizes UI topic strings to database format
String normalizeTopic(String ui) {
  switch (ui.trim()) {
    case 'My pet':
      return 'myPet';
    case 'My future self':
      return 'myFutureSelf';
    case 'My love':
      return 'myLove';
    default:
      return ui; // already a key
  }
}

/// Validates if the combination of mood, genre, and topic is valid for page 3
bool isValidPage3(String mood, String genre, String topic) {
  const validMoods = {'happy', 'chill', 'motivational'};
  const validGenres = {'kpop', 'rap', 'rock', 'pop'};
  const validTopics = {'myPet', 'myFutureSelf', 'myLove'};

  return validMoods.contains(mood) &&
      validGenres.contains(genre) &&
      validTopics.contains(topic);
}
