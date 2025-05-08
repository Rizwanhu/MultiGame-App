import 'dart:math';
import 'package:flutter/material.dart';
import 'CardFlipper.dart';
import 'card_item.dart';

class CardBoard extends StatefulWidget {
  final Function() onWin;
  final Function() onGameEnd;
  final BuildContext context;

  CardBoard({
    Key? key,
    required this.onWin,
    required this.onGameEnd,
    required this.context,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CardBoardState();
}

class CardBoardState extends State<CardBoard> {
  List<int> openedCards = [];
  List<CardModel> cards = [];
  int a = 1;

  @override
  void initState() {
    super.initState();
    cards = createCards();
  }

  List<CardModel> createCards() {
    List<String> asset = [];
    for (int i = 1; i <= 10; i++) {
      asset.add('0$i.png');
    }
    asset = [...asset, ...asset];
    asset.shuffle();

    return List.generate(asset.length, (index) {
      return CardModel(
        id: index,
        image: 'assets/images/CardFlipGame/${asset[index]}',
        key: UniqueKey(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      crossAxisCount: 4,
      childAspectRatio: 322 / 400,
      children: cards
          .map((f) =>
              CardItem(key: f.key, model: f, onFlipCard: handleFlipCard))
          .toList(),
    );
  }

  void handleFlipCard(bool isOpened, int id) {
    cards[id].isNeedCloseEffect = false;

    checkOpenedCard(isOpened);

    if (isOpened) {
      setCardOpened(id);
      openedCards.add(id);
    } else {
      setCardNone(id);
      openedCards.remove(id);
    }

    checkWin();
    checkOver();
  }

  void checkOver() {
    if (a >= 11) {
      a = 1;
      widget.onGameEnd(); // <- This triggers the dialog and Firestore update
    }
  }

  void checkOpenedCard(bool isOpened) {
    if (openedCards.length == 2 && isOpened) {
      cards[openedCards[0]].isNeedCloseEffect = true;
      setCardNone(openedCards[0]);
      cards[openedCards[1]].isNeedCloseEffect = true;
      setCardNone(openedCards[1]);
      openedCards.clear();
    }
  }

  void checkWin() {
    if (openedCards.length == 2) {
      if (cards[openedCards[0]].image == cards[openedCards[1]].image) {
        setCardWin(openedCards[0]);
        setCardWin(openedCards[1]);
        openedCards.clear();
        a++;
        widget.onWin();
      }
    }
  }

  void setCardNone(int id) {
    setState(() {
      cards[id].status = ECardStatus.None;
      cards[id].key = UniqueKey();
    });
  }

  void setCardOpened(int id) {
    setState(() {
      cards[id].status = ECardStatus.Opened;
      cards[id].key = UniqueKey();
    });
  }

  void setCardWin(int id) {
    setState(() {
      cards[id].status = ECardStatus.Win;
      cards[id].key = UniqueKey();
    });
  }
}
