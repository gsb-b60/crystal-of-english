import 'dart:convert';
import 'package:http/http.dart' as http;

// Hàm bất đồng bộ để lấy dữ liệu từ Open Trivia API
Future<void> fetchQuizData() async {
  // URL của API với 10 câu hỏi trắc nghiệm dễ về Lịch sử (category=23)
  final url = Uri.parse('https://opentdb.com/api.php?amount=10&category=27&type=multiple');

  try {
    // Gửi yêu cầu GET đến URL và chờ phản hồi
    final response = await http.get(url);

    // Kiểm tra mã trạng thái của phản hồi
    if (response.statusCode == 200) {
      // Phân tích chuỗi JSON thành một đối tượng Dart
      final data = json.decode(response.body);
      print(data);
      // Trích xuất danh sách các câu hỏi từ trường "results"
      List<dynamic> questions = data['results'];

      // Duyệt qua từng câu hỏi và in ra thông tin
      // for (var question in questions) {
      //   print('Category: ${question['category']}');
      //   print('Question: ${question['question']}');
      //   print('Correct Answer: ${question['correct_answer']}');
      //   print('Incorrect Answers: ${question['incorrect_answers']}');
      //   print('---'); // Dấu phân cách giữa các câu hỏi
      // }
    } else {
      // Xử lý khi yêu cầu không thành công
      print('Lỗi khi lấy dữ liệu: ${response.statusCode}');
    }
  } catch (e) {
    // Bắt các lỗi xảy ra trong quá trình fetch, ví dụ như lỗi mạng
    print('Có lỗi xảy ra: $e');
  }
}

// Hàm main để gọi hàm fetchQuizData
void main() {
  fetchQuizData();
}

class Question {
  final String id;
  final String type;
  final String prompt;
  final List<String> options;
  final int correct;
  final String? image;
  final String? sound;

  Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correct,
    this.image,
    this.sound,
  });
}


class Quizz {
  final int id;
  final String topic;
  final List<Question> questions;

  Quizz({
    required this.id,
    required this.topic,
    required this.questions,
  });
}

