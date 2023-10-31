import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomInfoWindowController {
  Function(Widget, LatLng)? addInfoWindow;

  VoidCallback? onCameraMove;

  VoidCallback? hideInfoWindow;

  VoidCallback? showInfoWindow;

  GoogleMapController? googleMapController;

  void dispose() {
    addInfoWindow = null;
    onCameraMove = null;
    hideInfoWindow = null;
    showInfoWindow = null;
    googleMapController = null;
  }
}

class CustomInfoWindow extends StatefulWidget {
  final CustomInfoWindowController controller;

  final double offset;

  final double height;

  final double width;
  final double leftMargin;
  final bool isDump;

  final Function(double top, double left, double width, double height) onChange;

  const CustomInfoWindow(
    this.onChange, {
    required this.controller,
    required this.leftMargin,
    required this.isDump,
    this.offset = 50,
    this.height = 50,
    this.width = 100,
  })  : assert(controller != null),
        assert(offset != null),
        assert(offset >= 0),
        assert(height != null),
        assert(height >= 0),
        assert(width != null),
        assert(width >= 0);

  @override
  _CustomInfoWindowState createState() => _CustomInfoWindowState();
}

class _CustomInfoWindowState extends State<CustomInfoWindow> {
  bool _showNow = false;
  double _leftMargin = 50;
  double _topMargin = 50;
  Widget? _child;
  LatLng? _latLng;

  @override
  void initState() {
    super.initState();
    widget.controller.addInfoWindow = _addInfoWindow;
    widget.controller.onCameraMove = _onCameraMove;
    widget.controller.hideInfoWindow = _hideInfoWindow;
    widget.controller.showInfoWindow = _showInfoWindow;
  }

  void _updateInfoWindow() async {
    if (_latLng == null ||
        _child == null ||
        widget.controller.googleMapController == null) {
      return;
    }
    ScreenCoordinate screenCoordinate = await widget
        .controller.googleMapController!
        .getScreenCoordinate(_latLng!);
    double devicePixelRatio = 1.0;
    double left =
        (screenCoordinate.x.toDouble() / devicePixelRatio) - (widget.width / 2);
    double top = (screenCoordinate.y.toDouble() / devicePixelRatio) -
        (widget.offset + widget.height);
    setState(() {
      _showNow = true;
      _leftMargin = left;
      _topMargin = top;
    });
    widget.onChange.call(top, left, widget.width, widget.height);
  }

  void _addInfoWindow(Widget child, LatLng latLng) {
    assert(child != null);
    assert(latLng != null);
    _child = child;
    _latLng = latLng;
    _updateInfoWindow();
  }

  void _onCameraMove() {
    if (!_showNow) return;
    _updateInfoWindow();
  }

  void _hideInfoWindow() {
    setState(() {
      _showNow = false;
    });
  }

  void _showInfoWindow() {
    _updateInfoWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.isDump ? _leftMargin - 100 : _leftMargin - 50,
        top: _topMargin - 140,
        child: Visibility(
          visible: (_showNow == false ||
                  (_leftMargin == 0 && _topMargin == 0) ||
                  _latLng == null)
              ? false
              : true,
          child: _child ?? Container(),
        ));
  }
}
