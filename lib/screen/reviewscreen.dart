import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki/business/Flashcard.dart';

class ReviewSreen extends StatefulWidget {
  final int deckId;
  const ReviewSreen({super.key, required this.deckId});

  @override
  State<ReviewSreen> createState() => _ReviewSreenState();
}

class _ReviewSreenState extends State<ReviewSreen> {
  List<Flashcard> _dueCards = [];
  int _currentCardIndex = 0;
  bool _isfrontVisible = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDueCard();
  }

  Future<void> _loadDueCard() async {
    final cardModel = Provider.of<Cardmodel>(context, listen: false);
    _dueCards = await cardModel.getDueCards(widget.deckId);
    setState(() {
      _isLoading=false;
    });
  }

  void _flipCard() {
    setState(() {
      _isfrontVisible = !_isfrontVisible;
    });
  }

  void _onReview(int rating) async { 
    if (_currentCardIndex >= _dueCards.length) {
      return;
    }
    final cardModel = Provider.of<Cardmodel>(context, listen: false);
    final currentCard = _dueCards[_currentCardIndex];
    

    await cardModel.updateCardAfterReview(currentCard, rating);
    setState(() {
      _currentCardIndex++;
      _isfrontVisible=true;
    });
    if(_currentCardIndex == _dueCards.length)
    {
      final newDueCard=await cardModel.getDueCards(widget.deckId);
      setState(() {
        _dueCards=newDueCard;
      });
    }
  }

  Widget _buildCardContent() {
    if (_dueCards.isEmpty) {
      return Center(child: Text('No card due for review'));
    }
    if (_currentCardIndex >= _dueCards.length) {
      return Center(child: Text('You finished your review!'));
    }
    final currentCard = _dueCards[_currentCardIndex];
    final content = _isfrontVisible ? currentCard.word : currentCard.meaning;
    return Center(
      child: GestureDetector(
        onTap: _flipCard,
        child: Container(
          width: 300,
          height: 400,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            content!,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Cards')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsetsGeometry.all(16.0),
              child: Column(children: [Expanded(child: _buildCardContent()),
              const SizedBox(height: 20,),
              if(_currentCardIndex<_dueCards.length)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: (){_onReview(1);}, child: const Text('Hard')),
                    ElevatedButton(onPressed: (){_onReview(2);}, child: const Text('Good')),
                    ElevatedButton(onPressed: (){_onReview(3);}, child: const Text('Easy')),
                    
                  ],
                )
              ]),
            ),
    );
  }
}
