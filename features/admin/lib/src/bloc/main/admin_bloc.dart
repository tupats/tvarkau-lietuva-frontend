import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

part 'admin_event.dart';

part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(LoadingState()) {
    on<LoadData>(_onLoadData);
    on<ReloadPage>(_onReloadEvent);
    on<LogIn>(_onLogInEvent);
    on<LogOut>(_onLogOutEvent);
    on<OnViewReports>(_onViewReportsEvent);
    on<OnViewDumps>(_onViewDumpsEvent);
    on<OnViewDeleted>(_onViewDeletedEvent);
    add(LoadData());
  }

  Future<void> _onLoadData(
    LoadData _,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(LoadingState());
      GlobalKey<NavigatorState> navKey = GlobalKey();
      var config = Config(
        tenant: '74edcdf9-ca2e-4601-9982-4e2df1ba3a54',
        clientId: '0408503a-ada6-4a72-8823-c52ca0fe5b43',
        scope: 'openid profile offline_access user.read',
        navigatorKey: navKey,
        loader: LoadingAnimationWidget.staggeredDotsWave(
            color: AppTheme.mainThemeColor, size: 150),
      );
      var oauth = AadOAuth(config);

      var hasCachedAccountInformation = await oauth.hasCachedAccountInformation;
      if (hasCachedAccountInformation) {
        var accessToken = await oauth.getAccessToken();
        if (accessToken != null && accessToken != '') {
          try {
            LogInDto userInfo = await ApiProvider().getUserInfo(accessToken);
            await SecureStorageProvider().setUserInfo(userInfo);
            await SecureStorageProvider().setJwtToken(userInfo.accessKey);

            List<FullReportDto> reports =
                await ApiProvider().getAllTrashReports();

            emit(ReportState(
              reports: reports,
              userInfo: userInfo,
            ));
          } catch (e) {
            emit(
              ErrorState(
                errorMessage: 'Something went wrong',
                errorDescription: e.toString(),
              ),
            );
          }
        } else {
          emit(LogingState());
        }
      } else {
        emit(LogingState());
      }
    } catch (e) {
      emit(
        ErrorState(
            errorMessage: 'Something went wrong',
            errorDescription: e.toString()),
      );
    }
  }

  Future<void> _onViewReportsEvent(
    OnViewReports _,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(LoadingState());
      LogInDto userInfo = await SecureStorageProvider().getUserInfo();
      List<FullReportDto> reports = await ApiProvider().getAllTrashReports();
      emit(ReportState(reports: reports, userInfo: userInfo));
    } catch (e) {
      emit(
        ErrorState(
            errorMessage: 'Something went wrong',
            errorDescription: e.toString()),
      );
    }
  }

  Future<void> _onViewDeletedEvent(
    OnViewDeleted _,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(LoadingState());
      LogInDto userInfo = await SecureStorageProvider().getUserInfo();
      List<FullReportDto> reports = await ApiProvider().getAllRemovedReports();
      emit(DeletedState(reports: reports, userInfo: userInfo));
    } catch (e) {
      emit(
        ErrorState(
            errorMessage: 'Something went wrong',
            errorDescription: e.toString()),
      );
    }
  }

  Future<void> _onViewDumpsEvent(
    OnViewDumps _,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(LoadingState());
      LogInDto userInfo = await SecureStorageProvider().getUserInfo();
      List<FullDumpDto> dumps = await ApiProvider().getAllDumpReports();
      emit(DumpState(dumps: dumps, userInfo: userInfo));
    } catch (e) {
      emit(
        ErrorState(
            errorMessage: 'Something went wrong',
            errorDescription: e.toString()),
      );
    }
  }

  Future<void> _onLogOutEvent(
    LogOut _,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(LoadingState());
      GlobalKey<NavigatorState> navKey = GlobalKey();
      var config = Config(
        tenant: '74edcdf9-ca2e-4601-9982-4e2df1ba3a54',
        clientId: '0408503a-ada6-4a72-8823-c52ca0fe5b43',
        scope: 'openid profile offline_access user.read',
        navigatorKey: navKey,
        loader: LoadingAnimationWidget.staggeredDotsWave(
            color: AppTheme.mainThemeColor, size: 150),
      );
      config.webUseRedirect = false;
      var oauth = AadOAuth(config);
      SecureStorageProvider().deleteJwtToken();
      await oauth.logout();
      var accessToken = await oauth.getAccessToken();
      if (accessToken != null) {
        emit(
          ErrorState(
              errorMessage: 'Something went wrong',
              errorDescription: 'Authentication reset error'),
        );
      } else {
        add(LoadData());
      }
    } catch (e) {
      emit(
        ErrorState(
            errorMessage: 'Something went wrong',
            errorDescription: e.toString()),
      );
    }
  }

  Future<void> _onLogInEvent(
    LogIn _,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(LoadingState());
      GlobalKey<NavigatorState> navKey = GlobalKey();
      var config = Config(
        tenant: '74edcdf9-ca2e-4601-9982-4e2df1ba3a54',
        clientId: '0408503a-ada6-4a72-8823-c52ca0fe5b43',
        scope: 'openid profile offline_access user.read',
        navigatorKey: navKey,
        loader: LoadingAnimationWidget.staggeredDotsWave(
            color: AppTheme.mainThemeColor, size: 150),
      );
      config.webUseRedirect = false;
      var oauth = AadOAuth(config);

      await oauth.login();
      var accessToken = await oauth.getAccessToken();

      if (accessToken != null) {
        add(LoadData());
      } else {
        emit(
          ErrorState(
              errorMessage: 'Something went wrong',
              errorDescription: 'Unauthorized'),
        );
      }
    } catch (e) {
      emit(
        ErrorState(
            errorMessage: 'Something went wrong',
            errorDescription: e.toString()),
      );
    }
  }

  Future<void> _onReloadEvent(
    ReloadPage _,
    Emitter<AdminState> emit,
  ) async {
    add(LoadData());
  }
}
