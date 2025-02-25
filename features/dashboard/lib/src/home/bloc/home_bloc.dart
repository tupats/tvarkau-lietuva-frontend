import 'package:api_client/api_client.dart';
import 'package:core/core.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(LoadingState()) {
    on<LoadData>(_onLoadData);
    on<ReloadPage>(_onReloadEvent);
    add(LoadData());
  }

  Future<void> _onLoadData(
    LoadData _,
    Emitter<HomeState> emit,
  ) async {
    try {
      final List<PublicReportDto> trashReports =
          await ApiProvider().getAllVisibleTrashReports();
      final List<DumpDto> dumpReports =
          await ApiProvider().getAllVisibleDumpReports();
      final ReportStatisticsDto reportStatistics =
          await ApiProvider().getReportStatistics();
      emit(
        ContentState(
          trashReports: trashReports,
          dumpReports: dumpReports,
          reportStatistics: reportStatistics,
        ),
      );
    } catch (e) {
      print(e);
      emit(
        ErrorState(errorMessage: 'Netikėta klaida'),
      );
    }
  }

  Future<void> _onReloadEvent(
    ReloadPage _,
    Emitter<HomeState> emit,
  ) async {
    add(LoadData());
  }
}
