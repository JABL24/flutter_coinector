import 'package:endlisch/MyColors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Merchant.dart';
import 'package:transparent_image/transparent_image.dart';
import 'ItemInfoStackLayer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays its integer item as 'item N' on a Card whose color is based on
/// the item's value. The text is displayed in bright green if selected is true.
/// This widget's height is based on the animation parameter, it varies
/// from 0 to 128 as the animation varies from 0.0 to 1.0.
class CardItem extends StatelessWidget {
  const CardItem(
      {Key key,
      @required this.animation,
      //  this.onTap,
      @required this.item,
      this.selected: false})
      : assert(animation != null),
        assert(item != null),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  //final VoidCallback onTap;
  final Merchant item;
  final bool selected;
  final double itemHeight = 100;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.body1;
    TextStyle textStyle2 = Theme.of(context).textTheme.body2;

    final infoBoxBackgroundColor = MyColors.getCardInfoBoxBackgroundColor(item.type);
    final actionButtonBackgroundColor = MyColors.getCardActionButtonBackgroundColor(item.type);
    return SizedBox(
      child: Card(
          clipBehavior: Clip.none,
          margin: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: actionButtonBackgroundColor,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: FadeInImage.memoryNetwork(
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 300),
                      placeholder: kTransparentImage,
                      image:
                          "https://realbitcoinclub.firebaseapp.com/img/app/" +
                              item.id +
                              ".gif",
                      height: 320,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: itemHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                infoBoxBackgroundColor,
                                infoBoxBackgroundColor,
                                infoBoxBackgroundColor.withOpacity(0.9),
                                infoBoxBackgroundColor.withOpacity(0.75),
                                infoBoxBackgroundColor.withOpacity(0.6)
                              ]),
                        ),
                      ),
                      Container(
                        height: itemHeight,
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.2)),
                      ),
                      ItemInfoStackLayer(
                          item: item,
                          textStyle: textStyle,
                          textStyleSmall: textStyle2,
                          height: itemHeight)
                    ],
                  ),
                ],
              ),
              ButtonTheme.bar(
                padding: EdgeInsets.all(10.0),
                // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Column(
                        children: <Widget>[
                          buildIcon(Icons.rate_review),
                          buildSpacer(),
                          const Text(
                            'REVIEW',
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      onPressed: () {
                        /* ... */
                      },
                    ),
                    FlatButton(
                      child: Column(
                        children: <Widget>[
                          buildIcon(Icons.payment),
                          buildSpacer(),
                          const Text('PAY')
                        ],
                      ),
                      onPressed: () {
                        showPayDialog(context);
                      },
                    ),
                    FlatButton(
                      child: Column(
                        children: <Widget>[
                          buildIcon(Icons.directions_run),
                          buildSpacer(),
                          const Text(
                            'VISIT',
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      onPressed: () {
                        _launchURL(item.id);
                      },
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Icon buildIcon(final icon) => Icon(icon, size: 25);

  SizedBox buildSpacer() {
    return const SizedBox(
                          height: 5,
                        );
  }
}

//TODO setup various servers to host images, for each dataset one
//TODO get receiving address from adddr.json
_launchURL(id) async {
//TODO setup the url forwarding on the URL server
  var url = 'https://realbitcoinclub-url.firebaseapp.com/' + id;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

showPayDialog(BuildContext context) {
  // set up the buttons
  Widget remindButton = FlatButton(
    child: Text("DASH"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget cancelButton = FlatButton(
    child: Text("BCH"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget launchButton = FlatButton(
    child: Text("BTC"),
    onPressed: null,
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Choose Coin"),
    content: Text("Which coin do you want to use?"),
    actions: [
      remindButton,
      cancelButton,
      launchButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
