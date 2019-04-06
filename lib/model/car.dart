import 'package:egitim/model/full_screen_dialog_demo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Car {
  String _name;
  String _description;
  int _maxSpeed;
  String _image;
  bool _isFavorite;

  String get name => _name;

  String get description => _description;

  int get maxSpeed => _maxSpeed;

  String get image => _image;

  bool get isFavorite => _isFavorite;

  set isFavorite(bool value) {
    _isFavorite = value;
  }

  set image(String value) {
    _image = value;
  }

  Car(this._name, this._description, this._maxSpeed, this._image, this._isFavorite);

  Car.added(this._name, this._description, this._isFavorite);
}

typedef BannerTapCallback = void Function(Car car);

const double _kMinFlingVelocity = 800.0;
enum GridDemoTileStyle { imageOnly, oneLine, twoLine }
enum DialogButtons { yes, no }

class GaragePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GaragePageState();
  }
}

class GaragePageState extends State<GaragePage> {
  GridDemoTileStyle _tileStyle = GridDemoTileStyle.twoLine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int listViewNumber = 2;

  List<Car> myGarage = [
    Car('BMW', 'Favorim', 250, 'images/bmw.png', true),
    Car('Audi', 'On Numara', 300, 'images/audi.png', false),
    Car('Mercedes', 'Çok Pahalı', 300, 'images/mercedes.png', false),
    Car('Porshe', 'Aşırı Pahalı', 350, 'images/porshe.png', false),
    Car('Toyota', 'Motor Sağlam', 200, 'images/toyota.png', false),
    Car('Renault', 'Parçası Ucuz', 200, 'images/renault.png', false)
  ];

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    void changeTileStyle(GridDemoTileStyle value) {
      setState(() {
        _tileStyle = value;
      });
    }

    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('My Garage'),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<Car>(
                    builder: (BuildContext context) => FullScreenDialogDemo(),
                    fullscreenDialog: true,
                  )).then((car) {
                car.image = 'images/default.png';
                setState(() {
                  myGarage.add(car);
                });
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('You added: ${car.name}')));
              });
            },
          ),
          IconButton(
            icon: Icon(listViewNumber == 1 ? Icons.view_column : Icons.view_list),
            onPressed: () {
              setState(() {
                listViewNumber = listViewNumber == 1 ? 2 : 1;
              });
            },
          ),
          PopupMenuButton<GridDemoTileStyle>(
            onSelected: changeTileStyle,
            itemBuilder: (BuildContext context) => <PopupMenuItem<GridDemoTileStyle>>[
                  const PopupMenuItem<GridDemoTileStyle>(
                    value: GridDemoTileStyle.imageOnly,
                    child: Text('Image only'),
                  ),
                  const PopupMenuItem<GridDemoTileStyle>(
                    value: GridDemoTileStyle.oneLine,
                    child: Text('One Line Text Up'),
                  ),
                  const PopupMenuItem<GridDemoTileStyle>(
                    value: GridDemoTileStyle.twoLine,
                    child: Text('Two line Text Bottom'),
                  ),
                ],
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              child: GridView.count(
                crossAxisCount: (orientation == Orientation.portrait) ? listViewNumber : listViewNumber + 1,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                padding: const EdgeInsets.all(4.0),
                childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
                children: myGarage.map<Widget>((Car car) {
                  return GestureDetector(
                    child: GridDemoPhotoItem(
                        car: car,
                        tileStyle: _tileStyle,
                        onBannerTap: (Car car) {
                          setState(() {
                            car.isFavorite = !car.isFavorite;
                          });
                        }),
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  content: Text('Are you sure you want to delete ${car.name}?'),
                                  actions: <Widget>[
                                    FlatButton(
                                        child: const Text('NO'),
                                        onPressed: () {
                                          Navigator.pop(context, null);
                                        }),
                                    FlatButton(
                                        child: const Text('YES'),
                                        onPressed: () {
                                          Navigator.pop(context, car);
                                        })
                                  ])).then((value) {
                        if (value != null) {
                          setState(() {
                            myGarage.remove(value);
                          });
                          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('You deleted: ${value.name}')));
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class GridDemoPhotoItem extends StatelessWidget {
  GridDemoPhotoItem({Key key, @required this.car, @required this.tileStyle, @required this.onBannerTap})
      : assert(car != null && car.name != null),
        assert(tileStyle != null),
        assert(onBannerTap != null),
        super(key: key);

  final Car car;
  final GridDemoTileStyle tileStyle;
  final BannerTapCallback onBannerTap; // User taps on the photo's header or footer.

  void showPhoto(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text(car.name)),
        body: SizedBox.expand(
          child: Hero(
            tag: car.name,
            child: GridPhotoViewer(car: car),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = GestureDetector(
        onTap: () {
          showPhoto(context);
        },
        child: Hero(
            tag: car.name,
            child: Image.asset(
              car.image,
              fit: BoxFit.fitWidth,
            )));

    final IconData icon = car.isFavorite ? Icons.star : Icons.star_border;

    switch (tileStyle) {
      case GridDemoTileStyle.imageOnly:
        return image;

      case GridDemoTileStyle.oneLine:
        return GridTile(
          header: GestureDetector(
            onTap: () {
              onBannerTap(car);
            },
            child: GridTileBar(
              title: _GridTitleText(car.name),
              backgroundColor: Colors.black45,
              leading: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );

      case GridDemoTileStyle.twoLine:
        return GridTile(
          footer: GestureDetector(
            onTap: () {
              onBannerTap(car);
            },
            child: GridTileBar(
              backgroundColor: Colors.black45,
              title: _GridTitleText(car.name),
              subtitle: _GridTitleText(car.description),
              trailing: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );
    }
    assert(tileStyle != null);
    return null;
  }
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}

class GridPhotoViewer extends StatefulWidget {
  const GridPhotoViewer({Key key, this.car}) : super(key: key);

  final Car car;

  @override
  _GridPhotoViewerState createState() => _GridPhotoViewerState();
}

class _GridPhotoViewerState extends State<GridPhotoViewer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation =
        _controller.drive(Tween<Offset>(begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: Image.asset(
            widget.car.image,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
