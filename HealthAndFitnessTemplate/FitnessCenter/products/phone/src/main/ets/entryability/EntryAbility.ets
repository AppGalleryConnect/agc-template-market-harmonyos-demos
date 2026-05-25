import { abilityAccessCtrl, AbilityConstant,
  PermissionRequestResult,
  Permissions, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import {
  BookingInfo,
  BookingRecordInfo,
  BookState,
  CardInfo,
  ConsumeType,
  CourseBookingInfo,
  CourseDetailModel,
  DateUtil,
  MockService,
  UserCard,
  getCalendarPermission,
  EmitterConstant,
  LoginState,
  WindowUtil,
  Logger
} from 'external_interactions';
import { ScreenPropStorage } from 'external_interactions'
import { FileUtils } from 'feedback';
import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const navPathStack =  AppStorage.get('navPathStack') as NavPathStack;
    if(want?.parameters?.params) {
      let formId = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string
      const loginStateStorage: LoginState = AppStorageV2.connect(LoginState, 'LoginState', () => new LoginState())!;
      if (!loginStateStorage.loginState) {
        this.context.eventHub.emit('showToastEvent', { message: '请先关联账号' });
        navPathStack.clear(false);
        try {
          emitter.emit(EmitterConstant.CLICK_BOOK_DETAIL)
        } catch (e) {
          Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
        }
        return;
      }
      try {
        let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
        let targetPage: string = params.targetPage as string;
        let currentName: string[] = navPathStack.getAllPathName()
        if(currentName[currentName.length - 1] === 'course/BookingDetail') {
          navPathStack.clear()
        }
        if (targetPage === 'course/ShowAllCourse' && MockService.userCourseList.length > 0) {
          targetPage = 'course/UserCourses';
        }
        if (targetPage !== currentName[currentName.length - 1] ) {
          navPathStack.pushPath({ name: targetPage });
        }
      } catch (e) {
        Logger.error(TAG, `get form params failed. code: ${e.code}, message: ${e.message}`)
      }
    }
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    try {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        Logger.info(TAG, 'Succeeded in loading the content.');
        // 初始化全局使用的uiContext
        WindowUtil.init(windowClass.getUIContext());
      });
    } catch (e) {
      Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(e) ?? '');
    }
    FileUtils.init(this.context);
    let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
    let isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
    });

    let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 导航条避让
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let bottomRectHeight = avoidArea.bottomRect.height; // 获取到导航条区域的高度
    AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

    type = window.AvoidAreaType.TYPE_SYSTEM; // 状态栏避让
    avoidArea = windowClass.getWindowAvoidArea(type);
    let topRectHeight = avoidArea.topRect.height; // 获取状态栏区域高度
    AppStorage.setOrCreate('topRectHeight', topRectHeight);
    let screenPropStorage: ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage',() => new ScreenPropStorage())!
    screenPropStorage.topRectHeight = topRectHeight
    screenPropStorage.bottomRectHeight = bottomRectHeight
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }
}
