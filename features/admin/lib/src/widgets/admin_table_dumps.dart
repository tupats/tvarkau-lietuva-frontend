import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../common/custom_colors.dart';
import '../common/custom_styles.dart';
import 'custom_button.dart';

class AdminTableDumps extends StatelessWidget {
  const AdminTableDumps({
    super.key,
    required this.dumps,
  });

  final List<FullDumpDto> dumps;

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: Colors.white,
        gridLineColor: CustomColors.greyMedium,
        gridLineStrokeWidth: 1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SfDataGrid(
          source: ReportDataSourceAdmin(
            reportData: dumps,
            context: context,
          ),
          columnWidthMode: ColumnWidthMode.fill,
          allowSorting: true,
          allowFiltering: true,
          rowHeight: 64,
          columns: [
            GridColumn(
              columnName: 'ref',
              allowSorting: false,
              allowFiltering: false,
              visible: false,
              label: Container(),
            ),
            GridColumn(
              columnName: 'name',
              allowSorting: false,
              allowFiltering: true,
              columnWidthMode: ColumnWidthMode.fill,
              label: const _BuildHeaderLabel('Aikštelės pavadinimas'),
            ),
            GridColumn(
              columnName: 'info',
              allowSorting: false,
              allowFiltering: true,
              columnWidthMode: ColumnWidthMode.fill,
              label: const _BuildHeaderLabel('Informacija'),
            ),
            GridColumn(
              columnName: 'lat',
              allowSorting: false,
              allowFiltering: true,
              width: 110,
              filterIconPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              label: const _BuildHeaderLabel('Platuma'),
            ),
            GridColumn(
              columnName: 'long',
              allowSorting: false,
              allowFiltering: true,
              width: 110,
              filterIconPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              label: const _BuildHeaderLabel('Ilguma'),
            ),
            GridColumn(
              columnName: 'visibility',
              allowSorting: true,
              allowFiltering: true,
              width: 140,
              label: const _BuildHeaderLabel('Matomumas'),
            ),
            GridColumn(
              columnName: 'edit',
              allowSorting: false,
              allowFiltering: false,
              width: 160,
              label: const _BuildHeaderLabel('Veiksmai'),
            ),
          ],
          gridLinesVisibility: GridLinesVisibility.horizontal,
          headerGridLinesVisibility: GridLinesVisibility.none,
        ),
      ),
    );
  }
}

String getFormattedDateAdmin(String unformattedDate) {
  DateTime formattedDate =
      DateTime.parse(unformattedDate).add(const Duration(hours: 3));
  String day = formattedDate.toString().substring(0, 10);
  String hour = formattedDate.toString().substring(11, 16);
  return '$day $hour';
}

class ReportDataSourceAdmin extends DataGridSource {
  ReportDataSourceAdmin({
    required this.reportData,
    required this.context,
  }) {
    _reportGridCells = reportData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'ref', value: e.refId),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'info', value: e.moreInformation),
              DataGridCell<String>(
                  columnName: 'lat',
                  value: e.latitude.toString().length > 7
                      ? e.latitude.toString().substring(0, 8)
                      : e.latitude.toString()),
              DataGridCell<String>(
                  columnName: 'long',
                  value: e.longitude.toString().length > 7
                      ? e.longitude.toString().substring(0, 8)
                      : e.longitude.toString()),
              DataGridCell<String>(
                  columnName: 'visibility',
                  value: e.isVisible ? 'Rodomas' : 'Nerodomas'),
              const DataGridCell<String>(columnName: 'edit', value: 'edit'),
            ]))
        .toList();
  }

  List<DataGridRow> _reportGridCells = [];

  final List<FullDumpDto> reportData;

  final BuildContext context;

  @override
  List<DataGridRow> get rows => _reportGridCells;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      final int index = effectiveRows.indexOf(row);
      if (index % 2 == 0) {
        return Colors.grey[200]!;
      }

      return Colors.white;
    }

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        color: getRowBackgroundColor(),
        padding: const EdgeInsets.only(left: 24),
        alignment: Alignment.centerLeft,
        child: e.columnName == 'status'
            ? _BuildStatus(status: e.value)
            : e.columnName == 'visibility'
                ? getVisibilityWidget(e.value)
                : e.columnName == 'edit'
                    ? CustomButton(
                        padding: EdgeInsets.zero,
                        height: 32,
                        width: 110,
                        text: 'Redaguoti',
                        textStyle: CustomStyles.button2.copyWith(
                          color: CustomColors.primary,
                        ),
                        onPressed: () {
                          final int index = effectiveRows.indexOf(row);
                          final FullDumpDto dump = reportData[index];

                          context.goNamed('dump_admin', queryParameters: {
                            'id': dump.refId,
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 14,
                          color: CustomColors.primary,
                        ),
                        buttonType: ButtonType.outlined,
                      )
                    : SelectionArea(
                        child: Text(e.value.toString(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            style: CustomStyles.button1.copyWith(
                              color: CustomColors.black,
                            )),
                      ),
      );
    }).toList());
  }
}

Widget getVisibilityWidget(String isVisible) {
  return SizedBox(
    child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVisible == 'Rodomas'
                  ? CustomColors.primary
                  : CustomColors.red,
            ),
            height: 12,
            width: 12,
          ),
          const SizedBox(width: 8),
          Text(
            isVisible,
            style: CustomStyles.button1.copyWith(
              color: CustomColors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

BoxDecoration getStatusBoxDecorationAdmin(Color borderColor, Color fillColor) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      width: 1,
      color: borderColor,
    ),
    color: fillColor,
  );
}

TextStyle getStatusBoxTextStyleAdmin(Color textColor) {
  return CustomStyles.body2.copyWith(
    color: textColor,
  );
}

class _BuildStatus extends StatelessWidget {
  const _BuildStatus({required this.status});

  final String status;

  Color get color {
    return switch (status) {
      'gautas' => CustomColors.red,
      'tiriamas' => CustomColors.orange,
      'uždarytas' => CustomColors.blue,
      'ištirtas' => CustomColors.green,
      _ => Colors.white,
    };
  }

  String get text {
    return switch (status) {
      'gautas' => 'Gautas',
      'tiriamas' => 'Tiriamas',
      'ištirtas' => 'Ištirtas',
      'uždarytas' => 'Uždarytas',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: color,
        ),
      ),
      child: Text(
        text,
        style: CustomStyles.body2.copyWith(
          color: color,
        ),
      ),
    );
  }
}

class _BuildHeaderLabel extends StatelessWidget {
  const _BuildHeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      child: Text(
        label,
        style: CustomStyles.button2.copyWith(
          color: CustomColors.black,
        ),
      ),
    );
  }
}
