import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { sensor } from '@kit.SensorServiceKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { pushService } from '@kit.PushKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { appDB, initNFC } from 'mobile_nfc';
import { ShortCutParam } from 'home';
import { DiaryDB } from 'diary';
import { PushActionParams } from '../model/Index';
import { RouterUtils } from '../utils/RouterUtils';
import { CommentUtil } from '../utils/CommentUtil';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    UtilLog.info('%{public}s', 'Ability onCreate');
    this.setColorMode(this.context);
    DiaryDB.initDB(this.context);
    appDB.initDb(this.context);
    initNFC(want);
    this.handlePushCreate(want);
    this.setShortCutKey(want);
    this.getPushToken();
    UtilLog.setGlobalConfig({
      tag: 'ComprehensiveTool', // 指定日志标识
      domain: 0xff00, // 日志对应的领域标识
      open: true,
      showStack: false,
    });

  }

  getPushToken() {
    pushService.getToken().then(token => {
      UtilLog.info('Succeeded in getting push token');
      // todo： 上报Push Token到您的服务端
    }).catch((err: BusinessError) => {
      UtilLog.error('Failed to get push token: %{public}d %{public}s', err.code, err.message);
    });
  }

  handlePushCreate(want: Want) {
    UtilLog.info('Succeeded in handle push create');
    let pushActionParams: PushActionParams = AppStorageV2.connect(PushActionParams, () => new PushActionParams())!;
    pushActionParams.name = want.parameters?.eventInfo as string;
  }

  handlePushWant(want: Want) {
    UtilLog.info('Succeeded in handle push want');
    let pushActionParams: PushActionParams = AppStorageV2.connect(PushActionParams, () => new PushActionParams())!;
    let eventInfo: string = want.parameters?.eventInfo as string;
    if (eventInfo?.length) {
      pushActionParams.name = want.parameters?.eventInfo as string;
      RouterUtils.pushPathByName(pushActionParams.name, null);
    }
  }


  setShortCutKey(want: Want) {
    let shortCutKey = want.parameters?.shortCutKey as string | undefined;
    let shortCutParm: ShortCutParam = AppStorageV2.connect(ShortCutParam, () => new ShortCutParam())!;
    if (shortCutKey) {
      shortCutParm.key = shortCutKey;
    }
  }

  goShortCutPage(want: Want) {
    let shortCutKey = want.parameters?.shortCutKey as string | undefined;
    if (shortCutKey) {
      RouterUtils.popToName('Main');
      RouterUtils.pushPathByName(shortCutKey, null);
    }
  }

  onDestroy(): void {
    UtilLog.info('%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    UtilLog.info('%{public}s', 'Ability onWindowStageCreate');
    AppStorage.setOrCreate('windowStage', windowStage);
    let windowClass: window.Window | undefined = undefined;

    try {
      window.getLastWindow(this.context, (err: BusinessError, data) => {
        const errCode: number = err.code;
        if (errCode) {
          return;
        }
        windowClass = data;
        try {
          // 对窗口尺寸大小变化的监听
          windowClass.on('windowSizeChange', (data) => {
            AppStorage.setOrCreate('height', windowStage.getMainWindowSync().getUIContext().px2vp(data.height));
          });
        } catch (exception) {
          UtilLog.error('Failed to listen windowSizeChange. Cause: %{public}s', JSON.stringify(exception));
        }
      });
    } catch (exception) {
      UtilLog.error('Failed to getLastWindow. Cause: %{public}s', JSON.stringify(exception));
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        UtilLog.error('Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      UtilLog.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    UtilLog.info('%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    UtilLog.info('%{public}s', 'Ability onForeground');
    CommentUtil.setForegroundFlag();
  }

  onBackground(): void {
    // Ability has back to background
    UtilLog.info('%{public}s', 'Ability onBackground');
    try {
      sensor.off(sensor.SensorId.ORIENTATION);
    } catch (e) {
      UtilLog.error(`sensor off error ${JSON.stringify(e)}`);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handlePushWant(want);
    this.goShortCutPage(want);
  }

  private setColorMode(context: common.UIAbilityContext) {
    context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }
};