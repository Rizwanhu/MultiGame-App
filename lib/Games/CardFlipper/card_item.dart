import 'package:flutter/material.dart';

class CardItem extends StatefulWidget {
  final CardModel? model;
  final Function(bool isOpened, int id)? onFlipCard;

  CardItem({Key? key, this.model, this.onFlipCard}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CardItemState();
  }
}

class CardItemState extends State<CardItem> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> frontScale;
  late Animation<double> backScale;
  String? imagePrimary, imageSecondary;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    frontScale = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    backScale = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    if (widget.model!.status == ECardStatus.None) {
      imagePrimary = widget.model!.image;
      imageSecondary = 'assets/images/CardFlipGame/00.png';
    } else {
      imagePrimary = 'assets/images/CardFlipGame/00.png';
      imageSecondary = widget.model!.image;
    }

    if (widget.model!.isNeedCloseEffect) {
      controller.reverse(from: 1.0);
      widget.model!.isNeedCloseEffect = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Center(
        child: widget.model!.status == ECardStatus.Win
            ? buildImage(widget.model!.image)
            : Stack(
                children: <Widget>[
                  buildCardLayout(backScale, imagePrimary!),
                  buildCardLayout(frontScale, imageSecondary!),
                ],
              ),
      ),
      onTap: flipCard,
    );
  }

  Widget buildCardLayout(Animation<double> animation, String image) {
    return AnimatedBuilder(
      child: buildImage(image),
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final Matrix4 transform = Matrix4.identity()
          ..scale(animation.value, 1.0, 1.0);
        return Transform(
          transform: transform,
          alignment: FractionalOffset.center,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void flipCard() {
    if (widget.model!.status != ECardStatus.Win) {
      setState(() {
        if (controller.isCompleted || controller.velocity > 0) {
          controller.reverse().then(
              (_) => widget.onFlipCard?.call(false, widget.model!.id));
        } else {
          controller.forward().then((_) =>
              widget.onFlipCard?.call(widget.model!.status == ECardStatus.None, widget.model!.id));
        }
      });
    }
  }

  Widget buildImage(String image) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Card(
        child: Image.asset(image),
        elevation: 8.0,
      ),
    );
  }
}

enum ECardStatus { None, Win, Opened }

class CardModel {
  String image;
  int id;
  ECardStatus status;
  bool isNeedCloseEffect;
  Key key;

  CardModel({
    required this.key,
    required this.image,
    required this.id,
    this.isNeedCloseEffect = false,
    this.status = ECardStatus.None,
  });
}