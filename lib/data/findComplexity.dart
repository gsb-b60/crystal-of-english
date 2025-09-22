bool checkSuffix(String word) {
  final suffix = ['tion', 'ology', 'sion', 'phobia'];
  for (var suf in suffix) {
    if (word.endsWith(suf) && word.length >= suf.length + 2) {
      return true;
    }
  }
  final prefix = ['un','im', 'dis', 'non', 'pre', 'mis', 'sub', 'inter'];
  for (var pre in prefix) {
    if (word.startsWith(pre) && word.length > pre.length + 2) {
      return true;
    }
  }
  return false;
}

int countSyllables(String word) {
  word = word.toLowerCase();
  final vowels='aeiouy';  
  int count=0;
  for(int i=0;i<word.length-1;i++){
    if(i==word.length-1 && word[i]=='e'&& !vowels.contains(word[i-1])){
      return count;
    }
    if(vowels.contains(word[i]) && !vowels.contains(word[i+1])){
      count++;
    }

  }
  return count;
}
int findComplexity(word) {
  //check for collocation
  int rule= findLengthRule(word);
  int syllables=countSyllables(word);
  int hasSuffix=checkSuffix(word)?1:0;

  int complexity=(syllables*0.7 + rule*0.3).round()+hasSuffix;
  return complexity;
}

int findLengthRule(word){
  if(word.contains('-') || word.contains(' '))
  {
    return 0;
  }

  if (word.length <= 3) {
    return 1;
  } else if (word.length < 5) {
    return 2;
  } else if (word.length < 7) {
    return 3;
  } else if (word.length < 9) {
    return 4;
  } else if (word.length < 11) {
    return 5;
  }
  return 1;
}