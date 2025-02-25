import 'package:api_client/api_client.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:core_ui/core_ui.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InformationScreenWeb extends StatefulWidget {
  const InformationScreenWeb({
    required this.width,
    required this.height,
    required this.report,
    super.key,
  });

  final double width;
  final double height;
  final PublicReportDto report;

  @override
  State<InformationScreenWeb> createState() => _InformationScreenWebState();
}

class _InformationScreenWebState extends State<InformationScreenWeb> {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Set<Marker> markers = {};
  int textLinesCount = 0;
  int departmentAnswerTextLinesCount = 0;

  int imageLineCount = 0;
  late MapType _currentMapType;
  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(55.1736, 23.8948), zoom: 7.0);

  late Widget statusWidget;
  late Widget firstStageWidget;
  late Widget falseReportWidget;
  late Widget secondStageWidget;
  late Widget thirdStageWidgetFalse;
  late Widget thirdStageWidgetTrue;
  late Widget finalStageWidget;
  double firstStageLineHeight = 0;
  double thirdStageLineHeight = 0;

  late TextSpan span;
  late TextSpan span2;
  late TextPainter tp;
  late TextPainter tp2;
  int strLength = 0;
  String str = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      addCustomIcon();
    });

    span = TextSpan(
        text: widget.report.name,
        style: GoogleFonts.roboto(
          fontSize: widget.width * 0.04444,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ));
    span2 = TextSpan(
        text: widget.report.comment != ' '
            ? widget.report.comment: '',
        style: GoogleFonts.roboto(
          fontSize: widget.width * 0.04444,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ));
    tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: widget.width);
    textLinesCount = tp.computeLineMetrics().length;
    tp2 = TextPainter(text: span2, textDirection: TextDirection.ltr);
    tp2.layout(maxWidth: widget.width);
    departmentAnswerTextLinesCount = tp2.computeLineMetrics().length;
    if (widget.report.imageUrls.isEmpty) {
      imageLineCount = 0;
    } else if (widget.report.imageUrls.length < 3) {
      imageLineCount = 1;
    } else if (widget.report.imageUrls.length > 2) {
      imageLineCount = 2;
    }
    strLength = 8 - widget.report.refId.length;
    str = '0' * strLength;

    _initialCameraPosition = CameraPosition(
        target: LatLng(widget.report.latitude, widget.report.longitude),
        zoom: 9.0);
    _currentMapType = MapType.normal;
    markers.add(
      Marker(
        markerId: MarkerId(
          '${widget.report.name}99899',
        ),
        position: LatLng(
          widget.report.latitude,
          widget.report.longitude,
        ),
        icon: markerIcon,
      ),
    );
    statusWidget = getStatusWidget(widget.report.status, widget.width);
    firstStageWidget = getFirstStageWidget();
    falseReportWidget = getFalseReportWidget();
    secondStageWidget = getSecondStageWidget();
    thirdStageWidgetFalse = getThirdStageWidget(false);
    thirdStageWidgetTrue = getThirdStageWidget(true);
    finalStageWidget = getFinalStageWidget();
    firstStageLineHeight = calculateFirstStageDottedLineHeight();
    thirdStageLineHeight = calculateThirdStageDottedLineHeight();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: "Pranešimo informacija",
      color: Colors.green,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: widget.width * 2.8,
                height: widget.width * 0.8666,
                color: const Color.fromRGBO(57, 97, 84, 1),
              ),
              SizedBox(
                width: widget.width,
                child: Padding(
                  padding: EdgeInsets.all(widget.width * 0.0444),
                  child: Column(
                    children: [
                      SizedBox(height: widget.width * 0.05),
                      Align(
                        alignment: Alignment.topLeft,
                        child: DepartmentLogoMobile(
                          width: widget.width,
                          onTap: () {
                            context.goNamed("home");
                          },
                        ),
                      ),
                      SizedBox(height: widget.width * 0.1333),
                      InkWell(
                        onTap: () {
                          context.goNamed("home");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_outlined,
                              size: widget.width * 0.0416,
                              color: Colors.white,
                            ),
                            SizedBox(width: widget.width * 0.0416),
                            SizedBox(
                              width: widget.width * 0.2111,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  'Grįžti atgal',
                                  style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: widget.width * 0.0472),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: widget.width * 0.5666,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                '#TLP-A$str${widget.report.refId.toUpperCase()}',
                                style: GoogleFonts.roboto(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          statusWidget,
                        ],
                      ),
                      SizedBox(height: widget.width * 0.0333),
                      SizedBox(
                        height: widget.width * 0.7777,
                        width: widget.width * 0.911,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          child: Stack(
                            children: [
                              GoogleMap(
                                mapType: _currentMapType,
                                initialCameraPosition: _initialCameraPosition,
                                markers: markers,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 110, right: 10),
                                child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: GoogleMapTypeButton(
                                      height: 40,
                                      width: 40,
                                      onPressed: () {
                                        showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                MapTypeChangeDialog(
                                                    width: widget.width,
                                                    currentMapType:
                                                        _currentMapType,
                                                    onHover: (isHover) {},
                                                    onChangeTap:
                                                        (MapType mapType) {
                                                      setState(() {
                                                        _currentMapType =
                                                            mapType;
                                                      });
                                                    }));
                                      },
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: widget.width * 0.075),
                      Stack(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  left: widget.width * 0.054166,
                                  top: widget.width * 0.1111),
                              child: DottedLine(
                                dashLength: widget.width * 0.01111,
                                dashGapLength: widget.width * 0.01111,
                                lineThickness: widget.width * 0.002777,
                                dashColor:
                                    const Color.fromRGBO(222, 224, 224, 1),
                                direction: Axis.vertical,
                                lineLength: firstStageLineHeight,
                              )),
                          firstStageWidget,
                        ],
                      ),
                      widget.report.status == 'nepasitvirtino'
                          ? falseReportWidget
                          : const SizedBox.shrink(),
                      widget.report.status == 'tiriamas'
                          ? Stack(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: widget.width * 0.054166,
                                        top: widget.width * 0.1111),
                                    child: DottedLine(
                                      dashLength: widget.width * 0.01111,
                                      dashGapLength: widget.width * 0.01111,
                                      lineThickness: widget.width * 0.002777,
                                      dashColor: const Color.fromRGBO(
                                          222, 224, 224, 1),
                                      direction: Axis.vertical,
                                      lineLength: widget.width * 0.125,
                                    )),
                                secondStageWidget,
                              ],
                            )
                          : const SizedBox.shrink(),
                      widget.report.status == 'ištirtas'
                          ? Stack(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: widget.width * 0.054166,
                                        top: widget.width * 0.1111),
                                    child: DottedLine(
                                      dashLength: widget.width * 0.01111,
                                      dashGapLength: widget.width * 0.01111,
                                      lineThickness: widget.width * 0.002777,
                                      dashColor: const Color.fromRGBO(
                                          222, 224, 224, 1),
                                      direction: Axis.vertical,
                                      lineLength: widget.width * 0.125 +
                                          thirdStageLineHeight,
                                    )),
                                Column(
                                  children: [
                                    secondStageWidget,
                                    thirdStageWidgetFalse,
                                  ],
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                      widget.report.status == 'sutvarkyta'
                          ? Stack(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: widget.width * 0.054166,
                                        top: widget.width * 0.1111),
                                    child: DottedLine(
                                      dashLength: widget.width * 0.01111,
                                      dashGapLength: widget.width * 0.01111,
                                      lineThickness: widget.width * 0.002777,
                                      dashColor: const Color.fromRGBO(
                                          222, 224, 224, 1),
                                      direction: Axis.vertical,
                                      lineLength: widget.width * 0.125 +
                                          thirdStageLineHeight,
                                    )),
                                Column(
                                  children: [
                                    secondStageWidget,
                                    thirdStageWidgetTrue,
                                    finalStageWidget,
                                  ],
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                      SizedBox(height: widget.width * 0.1555),
                      FooterDescriptionMobile(width: widget.width),
                      SizedBox(height: widget.width * 0.0654),
                      FooterContactsMobile(width: widget.width),
                      SizedBox(height: widget.width * 0.0444),
                      FooterConsultMobile(width: widget.width),
                      SizedBox(height: widget.width * 0.04722),
                      FooterSupportMobile(width: widget.width),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  double calculateFirstStageDottedLineHeight() {
    var textLines = textLinesCount == 1 ? 1 : textLinesCount + 1;
    double firstGap = widget.width * 0.08055;
    double textGap = widget.width * 0.067063 * textLines;
    double secondGap = widget.width * 0.056;
    double imageGap = 0;
    if (imageLineCount == 1) {
      imageGap = widget.width * 0.27777;
    } else if (imageLineCount == 2) {
      imageGap = widget.width * 0.6;
    }
    double thirdGap = widget.width * 0.1111;
    double height = firstGap + textGap + secondGap + imageGap + thirdGap;
    return height;
  }

  double calculateThirdStageDottedLineHeight() {
    var depTextLines = departmentAnswerTextLinesCount == 1
        ? 1
        : departmentAnswerTextLinesCount + 1;

    double imageGap = 0;
    if (widget.report.officerImageUrls.isNotEmpty) {
      imageGap = widget.report.officerImageUrls.length <= 2
          ? widget.width * 0.27778
          : widget.width * 0.61;
    }
    double firstGap = widget.width * 0.2111;
    double textGap = widget.width * 0.067063 * depTextLines;
    double secondGap = widget.width * 0.2111;

    double height = firstGap + textGap + secondGap + imageGap;
    return height;
  }

  Widget getThirdStageWidget(bool isFinal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: calculateThirdStageDottedLineHeight(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: widget.width * 0.1111,
                width: widget.width * 0.1111,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(57, 97, 84, 1)),
                child: SizedBox(
                  height: widget.width * 0.05555,
                  width: widget.width * 0.05555,
                  child: SvgPicture.asset(
                    'assets/svg/progress_third_stage_icon.svg',
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              !isFinal
                  ? SizedBox(
                      height: calculateThirdStageDottedLineHeight() -
                          widget.width * 0.2222,
                    )
                  : const SizedBox.shrink(),
              !isFinal
                  ? Container(
                      height: widget.width * 0.1111,
                      width: widget.width * 0.1111,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(241, 244, 243, 1)),
                      child: SizedBox(
                        height: widget.width * 0.05555,
                        width: widget.width * 0.05555,
                        child: SvgPicture.asset(
                          'assets/svg/progress_fourth_stage_icon.svg',
                          color: const Color.fromRGBO(57, 97, 84, 1),
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(width: widget.width * 0.0444),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Pranešimas ištirtas',
              style: GoogleFonts.roboto(
                fontSize: widget.width * 0.05555,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: widget.width * 0.01111),
            Text(
              getFormattedDate('ištirtas'),
              style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.03888,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(0, 0, 0, 0.72)),
            ),
            SizedBox(
                height:
                    widget.report.comment != ' ' ? widget.width * 0.0805 : 0),
            widget.report.comment != ' ' && widget.report.comment != ''
                ? SizedBox(
                    width: widget.width * 0.73055,
                    child: Text(
                      'AAD atsakymas:',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                        fontSize: widget.width * 0.04444,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: widget.width * 0.02777),
            SizedBox(
              width: widget.width * 0.73055,
              child: Text(
                widget.report.comment,
                textAlign: TextAlign.left,
                style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.04444,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            widget.report.officerImageUrls.isNotEmpty
                ? SizedBox(
                    height: widget.report.officerImageUrls.length <= 2
                        ? widget.width * 0.27778
                        : widget.width * 0.61,
                    width: widget.width * 0.6001,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: widget.width * 0.04444,
                      crossAxisSpacing: widget.width * 0.04444,
                      children: List.generate(
                          widget.report.officerImageUrls.length, (index) {
                        return Container(
                          height: widget.width * 0.27777,
                          width: widget.width * 0.27777,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)),
                          child: Image.network(
                            getFormattedImageUrl(
                              getFormattedImageUrl(
                                  widget.report.officerImageUrls[index]),
                            ),
                            fit: BoxFit.fill,
                          ),
                        );
                      }),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        )
      ],
    );
  }

  Widget getSecondStageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.width * 0.1111,
          width: widget.width * 0.1111,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(241, 244, 243, 1),
          ),
          child: SizedBox(
            height: widget.width * 0.05555,
            width: widget.width * 0.05555,
            child: SvgPicture.asset(
              'assets/svg/progress_second_stage_icon.svg',
              color: const Color.fromRGBO(57, 97, 84, 1),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(width: widget.width * 0.0444),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Pranešimas tiriamas',
              style: GoogleFonts.roboto(
                fontSize: widget.width * 0.05555,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: widget.width * 0.01111),
            Text(
              getFormattedDate('tiriamas'),
              style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.03888,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(0, 0, 0, 0.72)),
            ),
            SizedBox(height: widget.width * 0.1111),
          ],
        )
      ],
    );
  }

  Widget getFinalStageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.width * 0.1111,
          width: widget.width * 0.1111,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color.fromRGBO(241, 244, 243, 1)),
          child: SizedBox(
            height: widget.width * 0.05555,
            width: widget.width * 0.05555,
            child: SvgPicture.asset(
              'assets/svg/progress_fourth_stage_icon.svg',
              color: const Color.fromRGBO(57, 97, 84, 1),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(width: widget.width * 0.0444),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Sutvarkyta',
              style: GoogleFonts.roboto(
                fontSize: widget.width * 0.05555,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: widget.width * 0.01111),
            Text(
              getFormattedDate('sutvarkyta'),
              style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.03888,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(0, 0, 0, 0.72)),
            ),
          ],
        )
      ],
    );
  }

  Widget getFalseReportWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.width * 0.1111,
          width: widget.width * 0.1111,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color.fromRGBO(241, 244, 243, 1)),
          child: SizedBox(
            height: widget.width * 0.05555,
            width: widget.width * 0.05555,
            child: SvgPicture.asset(
              'assets/svg/progress_fourth_stage_icon.svg',
              color: const Color.fromRGBO(57, 97, 84, 1),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(width: widget.width * 0.0444),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Pranešimas nepasitvirtino',
              style: GoogleFonts.roboto(
                fontSize: widget.width * 0.05555,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: widget.width * 0.01111),
            Text(
              getFormattedDate('nepasitvirtino'),
              style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.03888,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(0, 0, 0, 0.72)),
            ),
            SizedBox(height: widget.width * 0.0666),
            SizedBox(
              width: widget.width * 0.73055,
              child: Text(
                widget.report.comment,
                textAlign: TextAlign.left,
                style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.04444,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: widget.width * 0.0666),
          ],
        )
      ],
    );
  }

  Widget getFirstStageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.width * 0.1111,
          width: widget.width * 0.1111,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color.fromRGBO(241, 244, 243, 1)),
          child: SizedBox(
            height: widget.width * 0.05555,
            width: widget.width * 0.05555,
            child: SvgPicture.asset(
              'assets/svg/progress_first_stage_icon.svg',
              color: const Color.fromRGBO(57, 97, 84, 1),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(width: widget.width * 0.0444),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Gautas pranešimas',
              style: GoogleFonts.roboto(
                fontSize: widget.width * 0.05555,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: widget.width * 0.01111),
            Text(
              getFormattedDate('gautas'),
              style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.03888,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(0, 0, 0, 0.72)),
            ),
            SizedBox(height: widget.width * 0.0666),
            SizedBox(
              width: widget.width * 0.73055,
              child: Text(
                widget.report.name,
                textAlign: TextAlign.left,
                style: GoogleFonts.roboto(
                  fontSize: widget.width * 0.04444,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: widget.width * 0.0666),
            widget.report.imageUrls.isNotEmpty
                ? SizedBox(
                    height: widget.report.imageUrls.length < 3
                        ? widget.width * 0.27778
                        : widget.width * 0.61,
                    width: widget.width * 0.6001,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: widget.width * 0.04444,
                      crossAxisSpacing: widget.width * 0.04444,
                      children: List.generate(widget.report.imageUrls.length,
                          (index) {
                        return Container(
                          height: widget.width * 0.27777,
                          width: widget.width * 0.27777,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)),
                          child: Image.network(
                            getFormattedImageUrl(
                                widget.report.imageUrls[index]),
                            fit: BoxFit.fill,
                          ),
                        );
                      }),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        )
      ],
    );
  }

  String getFormattedDate(String status) {
    StatusRecordsDto? recordObject = widget.report.statusRecords
        .where((element) => element.status == status)
        .singleOrNull;
    String day = '';
    String hour = '';
    if (recordObject != null) {
      DateTime formattedDate =
          recordObject.date.add(const Duration(hours: 3));
      day = formattedDate.toString().substring(0, 10);
      hour = formattedDate.toString().substring(11, 16);
    } else {
      DateTime formattedDate = widget.report.reportDate
          .add(const Duration(hours: 3));
      day = formattedDate.toString().substring(0, 10);
      hour = formattedDate.toString().substring(11, 16);
    }
    return '$day $hour';
  }

  Widget getStatusWidget(String status, double width) {
    if (status == 'gautas') {
      return Container(
        height: width * 0.07777,
        width: width * 0.17777,
        decoration: getStatusBoxDecoration(
          const Color.fromRGBO(237, 12, 12, 1),
          const Color.fromRGBO(253, 225, 225, 1),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.1222,
            child: FittedBox(
              child: Text(
                'Gautas',
                style: getStatusBoxTextStyle(
                  const Color.fromRGBO(237, 12, 12, 1),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'tiriamas') {
      return Container(
        height: width * 0.07777,
        width: width * 0.2055,
        decoration: getStatusBoxDecoration(
          const Color.fromRGBO(255, 119, 0, 1),
          const Color.fromRGBO(255, 238, 224, 1),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.15,
            child: FittedBox(
              child: Text(
                'Tiriamas',
                style: getStatusBoxTextStyle(
                  const Color.fromRGBO(255, 119, 0, 1),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'ištirtas') {
      return Container(
        height: width * 0.07777,
        width: width * 0.17777,
        decoration: getStatusBoxDecoration(
          const Color.fromRGBO(9, 126, 223, 1),
          const Color.fromRGBO(225, 239, 251, 1),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.1222,
            child: FittedBox(
              child: Text(
                'Ištirtas',
                style: getStatusBoxTextStyle(
                  const Color.fromRGBO(9, 126, 223, 1),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'nepasitvirtino') {
      return Container(
        height: width * 0.07777,
        width: width * 0.2477,
        decoration: getStatusBoxDecoration(
          const Color.fromRGBO(100, 100, 100, 1.0),
          const Color.fromRGBO(220, 220, 220, 1.0),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.1922,
            child: FittedBox(
              child: Text(
                'Nepasitvirtino',
                style: getStatusBoxTextStyle(
                  const Color.fromRGBO(100, 100, 100, 1.0),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'sutvarkyta') {
      return Container(
        height: width * 0.07777,
        width: width * 0.2477,
        decoration: getStatusBoxDecoration(
          const Color.fromRGBO(0, 174, 6, 1),
          const Color.fromRGBO(224, 245, 224, 1),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.1822,
            child: FittedBox(
              child: Text(
                'Sutvarkyta',
                style: getStatusBoxTextStyle(
                  const Color.fromRGBO(0, 174, 6, 1),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  BoxDecoration getStatusBoxDecoration(Color borderColor, Color fillColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        width: 1,
        color: borderColor,
      ),
      color: fillColor,
    );
  }

  TextStyle getStatusBoxTextStyle(Color textColor) {
    return GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textColor,
    );
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/svg/pin_icon.svg')
        .then((icon) {
      setState(() {
        markerIcon = icon;
      });
    });
  }

  String getFormattedImageUrl(String unformattedImageUrl) {
    if (unformattedImageUrl.endsWith('.heic') ||
        unformattedImageUrl.endsWith('.heif')) {
      var convertedString =
          unformattedImageUrl.substring(0, unformattedImageUrl.length - 5);
      convertedString = '$convertedString.jpg';
      return convertedString;
    } else {
      return unformattedImageUrl;
    }
  }
}
