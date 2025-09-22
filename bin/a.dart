// void main() {
//   List<String> testWords = [
//     // --- Level 1: Basic (1–2 âm tiết, dễ) ---
//     "cat",        // 1 âm tiết chuẩn
//     "dog",        // 1 âm tiết chuẩn
//     "cake",       // silent e
//     "hope",       // silent e
//     "table",      // -le cuối từ
//     "music",      // 2 âm tiết chuẩn
//     "river",      // 2 âm tiết đơn giản
//     "baby",       // y = nguyên âm

//     // --- Level 2: Medium (2–3 âm tiết, có rule) ---
//     "walked",     // -ed không thêm âm tiết
//     "wanted",     // -ed thêm âm tiết
//     "ended",      // -ed thêm âm tiết
//     "banana",     // ba-na-na
//     "family",     // tùy accent: 2–3
//     "computer",   // 3 âm tiết
//     "playing",    // y = nguyên âm
//     "yes",        // y = phụ âm

//     // --- Level 3: Tricky (chữ thừa, nguyên âm kép) ---
//     "coat",       // oa = 1 âm tiết
//     "queue",      // viết dài, đọc 1
//     "science",    // sci-ence
//     "people",     // viết nhiều, đọc 2
//     "hour",       // ou = 1 âm tiết
//     "choir",      // 2 âm tiết
//     "business",   // viết 8 chữ, đọc 2

//     // --- Level 4: Hard (bất quy tắc, accent khác) ---
//     "colonel",    // đọc /ˈkɜrnəl/
//     "Wednesday",  // thường đọc "Wenzday"
//     "vehicle",    // Mỹ 2, Anh 3
//     "chocolate",  // Mỹ hay đọc 2 âm tiết
//     "comfortable",// viết 4, đọc 3
//     "literature", // Mỹ 3, Anh 4
//     "bourgeois",  // gốc Pháp, 2 âm tiết
//     "nation"
//   ];
//   for (var word in testWords) {
//     print("word: $word, complexity: ${findComplexity(word)}");
//   }
// }

// bool checkSuffix(String word) {
//   final suffix = ['tion', 'ology', 'sion', 'phobia'];
//   for (var suf in suffix) {
//     if (word.endsWith(suf) && word.length >= suf.length + 2) {
//       return true;
//     }
//   }
//   final prefix = ['un','im', 'dis', 'non', 'pre', 'mis', 'sub', 'inter'];
//   for (var pre in prefix) {
//     if (word.startsWith(pre) && word.length > pre.length + 2) {
//       return true;
//     }
//   }
//   return false;
// }

// int countSyllables(String word) {
//   word = word.toLowerCase();
//   final vowels='aeiouy';  
//   int count=0;
//   for(int i=0;i<word.length-1;i++){
//     if(i==word.length-1 && word[i]=='e'&& !vowels.contains(word[i-1])){
//       return count;
//     }
//     if(vowels.contains(word[i]) && !vowels.contains(word[i+1])){
//       count++;
//     }

//   }
//   return count;
// }
// int findComplexity(word) {
//   //check for collocation
//   int rule= findLengthRule(word);
//   int syllables=countSyllables(word);
//   int hasSuffix=checkSuffix(word)?1:0;

//   int complexity=(syllables*0.7 + rule*0.3).round()+hasSuffix;
//   return complexity;
// }

// int findLengthRule(word){
//   if(word.contains('-') || word.contains(' '))
//   {
//     return 0;
//   }

//   if (word.length <= 3) {
//     return 1;
//   } else if (word.length < 5) {
//     return 2;
//   } else if (word.length < 7) {
//     return 3;
//   } else if (word.length < 9) {
//     return 4;
//   } else if (word.length < 11) {
//     return 5;
//   }
//   return 1;
// }
// int