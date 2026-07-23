import { common, ConfigurationConstant, EnvironmentCallback } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { notificationManager } from '@kit.NotificationKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { BaseViewModel } from '../models/BaseViewModel';
import { SettingItem, SettingGroup } from '../types/SettingItem';
import { SettingPageEnum, SettingType, SupportedSetting } from '../types/SettingType';
import { AboutModel, AgreementModel, IFontModel, WebModel } from '../models/CustomConfigModel';
import { FileUtils } from '../common/FileUtils';
import { AppGalleryUtils } from '../common/AppGalleryUtils';
import { lightDarkOptions } from '../constants/LightDarkOptions';
import { CommonConfirmDialog } from '../components/CommonConfirmDialog';

const TAG = '[SettingViewModel]';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  @Trace settingList: SettingGroup[] = [];
  @Trace callbackId: number = 0;
  public uiContext: UIContext | null = null;
  public context: common.UIAbilityContext | null = null;
  private readonly PUSH_ITEM_ID = 'push_item_id';

  handleSettingList(list: SettingGroup[]) {
    this.settingList = list;
    this.settingList.forEach((v: SettingGroup) => {
      v.list.forEach(async (item: SettingItem) => {
        switch (item.supportedType) {
          case SupportedSetting.PRIVACY:
            this.handlePrivacy(item);
            break;
          case SupportedSetting.PUSH_SWITCH:
            this.handlePush(item);
            break;
          case SupportedSetting.CLEAR_CACHE:
            this.handleCache(item);
            break;
          case SupportedSetting.LIGHT_DARK_MODE:
            this.handleDark(item);
            break;
          case SupportedSetting.FONT_SIZE:
            this.handleFont(item);
            break;
          case SupportedSetting.CHECK_VERSION:
            this.handleVersionCheck(item);
            break;
          case SupportedSetting.ABOUT:
            this.handleAbout(item);
            break;
          case SupportedSetting.WEB:
            this.handleWeb(item);
            break;
        }
      })
    })
  }

  handlePrivacy(item: SettingItem) {
    item.setType(SettingType.ROUTER)
      .setLabel(item.label ?? '隐私设置')
      .setRouterParam({ routerName: SettingPageEnum.SETTING_PRIVACY });
    this.handleGlobalAgreement(item.extraParams as AgreementModel);
  }

  handlePush(item: SettingItem) {
    try {
      const isOn = notificationManager.isNotificationEnabledSync();
      item.setType(SettingType.SWITCH)
        .setLabel(item.label ?? '通知开关')
        .setSwitchValue(isOn)
        .setItemId(this.PUSH_ITEM_ID)
        .setClickEvent(() => {
          notificationManager.openNotificationSettings(this.uiContext?.getHostContext() as common.UIAbilityContext)
            .catch((error: BusinessError) => {
              Logger.error(TAG, `Failed to open notification settings. err: ${JSON.stringify(error)}`);
            });
        })
    } catch (error) {
      Logger.error(TAG, `Failed to is notification enabled sync. err: ${JSON.stringify(error)}`);
    }

  }

  async handleCache(item: SettingItem) {
    item.setType(SettingType.TEXT)
      .setLabel(item.label ?? '清理缓存')
      .setClickEvent(() => {
        if (!this.uiContext) {
          return;
        }
        CommonConfirmDialog.show({
          primaryTitle: '温馨提示',
          content: 'APP使用过程中下载的图片、音频、视频等资源将被清除，不可还原。',
          confirm: () => {
            FileUtils.clearCache(this.uiContext?.getHostContext()!);
            setTimeout(async () => {
              const cache = await this.getCache();
              item.setNormalText(cache);
              promptAction.showToast({ message: '清除缓存成功' });
              if (item.onChange) {
                item.onChange(cache);
              }
            }, 400)
          },
        })
      })
    const cache = await this.getCache();
    item.setNormalText(cache);
  }

  handleDark(item: SettingItem) {
    try {
      const options = item.selectOptions ?? lightDarkOptions;
      if (item.selectIndex < options.length && item.selectIndex >= 0) {
        const colorMode = options[item.selectIndex].value as ConfigurationConstant.ColorMode;
        this.uiContext?.getHostContext()?.getApplicationContext().setColorMode(colorMode);
      }

      item.setType(SettingType.SELECT)
        .setLabel(item.label ?? '夜间模式')
        .setSelectOptions(item.selectOptions ?? lightDarkOptions)
        .setSelectEvent((index: number) => {
          const colorMode = lightDarkOptions[index].value as ConfigurationConstant.ColorMode;
          this.uiContext?.getHostContext()?.getApplicationContext().setColorMode(colorMode);
          if (item.onChange) {
            item.onChange(colorMode);
          }
        })
    } catch (e) {
      Logger.error(TAG, 'handleDark fail, error: ' + JSON.stringify(e));
    }
  }

  handleFont(item: SettingItem) {
    item.setType(SettingType.ROUTER)
      .setLabel(item.label ?? '字体大小')
      .setRouterParam({ routerName: SettingPageEnum.SETTING_FONT });
    this.handleGlobalFont(item.extraParams as IFontModel);
  }

  handleVersionCheck(item: SettingItem) {
    item.setType(SettingType.TEXT)
      .setLabel(item.label ?? '检测版本')
      .setClickEvent(() => {
        const context = this.uiContext?.getHostContext() as common.UIAbilityContext;
        if (!context) {
          return;
        }
        AppGalleryUtils.checkAppUpdate(context).then((resp: boolean) => {
          if (resp) {
            AppGalleryUtils.showUpdateDialog(context);
          } else {
            promptAction.showToast({ message: '已是最新版本' });
          }
          if (item.onChange) {
            item.onChange(resp);
          }
        })
      })
  }

  handleAbout(item: SettingItem) {
    item.setType(SettingType.ROUTER)
      .setLabel(item.label ?? '关于我们')
      .setRouterParam({ routerName: SettingPageEnum.SETTING_ABOUT });
    this.handleGlobalAbout(item.extraParams as AboutModel);
  }

  handleWeb(item: SettingItem) {
    item.setRouterParam({
      routerName: SettingPageEnum.SETTING_AGREEMENT,
      routerParams: (item.extraParams as WebModel).src,
    })
  }

  handleGlobalAgreement(agreementInfo: AgreementModel) {
    if (agreementInfo.userAgreement) {
      this.configInfo.agreementModel.userAgreement = agreementInfo.userAgreement;
    }
    if (agreementInfo.privacyPolicy) {
      this.configInfo.agreementModel.privacyPolicy = agreementInfo.privacyPolicy;
    }
    if (agreementInfo.thirtyItem) {
      this.configInfo.agreementModel.thirtyItem = agreementInfo.thirtyItem;
    }
    if (agreementInfo.personalCollection) {
      this.configInfo.agreementModel.personalCollection = agreementInfo.personalCollection;
    }
  }

  handleGlobalAbout(aboutModel: AboutModel) {
    if (aboutModel.icpText) {
      this.configInfo.aboutModel.icpText = aboutModel.icpText;
    }
    if (aboutModel.copyrightText) {
      this.configInfo.aboutModel.copyrightText = aboutModel.copyrightText;
    }
    if (aboutModel.hotline) {
      this.configInfo.aboutModel.hotline = aboutModel.hotline;
    }
  }

  handleGlobalFont(fontModel: IFontModel) {
    this.fontModel.followSystem = fontModel.followSystem ?? false;
    this.fontModel.fontSizeRatio = fontModel.fontSizeRatio ?? 1;
    this.fontModel.onChange = () => {
      fontModel.onChange?.(this.fontModel.followSystem, this.fontModel.fontSizeRatio,
        this.fontModel.sysFontSizeScale);
    };
  }

  getLatestPushStatus() {
    try {
      const isOn = notificationManager.isNotificationEnabledSync();
      this.settingList.forEach((group: SettingGroup) => {
        group.list.forEach((item: SettingItem) => {
          if (item.id === this.PUSH_ITEM_ID) {
            const oldValue = item.switchV;
            item.setSwitchValue(isOn)
            if (item.onChange && oldValue !== isOn) {
              item.onChange(isOn);
            }
          }
        })
      })
    } catch (error) {
      Logger.error(TAG, `Failed to is notification nnabled sync. err: ${JSON.stringify(error)}`);
    }

  }

  getCache() {
    return FileUtils.getCache().then((resp: number) => {
      const cacheSize = (resp / 1024 / 1024).toFixed(2);
      return `${cacheSize}M`;
    })
  }

  onConfigurationUpdate(): void {
    if (!this.context) {
      return;
    }
    this.fontModel.sysFontSizeScale = this.context.config.fontSizeScale as number;
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated: (config) => {
        this.fontModel.sysFontSizeScale = config.fontSizeScale as number;
      },
      onMemoryLevel: () => {
      },
    }
    try {
      this.callbackId = this.context.getApplicationContext().on('environment', environmentCallback);
    } catch (err) {
      Logger.error(TAG, `Failed to register applicationContext. err: ${JSON.stringify(err)}`);
    }
  }

  offConfigurationUpdate() {
    if (!this.context) {
      return;
    }
    try {
      this.context.getApplicationContext().off('environment', this.callbackId);
    } catch (err) {
      Logger.error(TAG, `Failed to unregister applicationContext. err: ${JSON.stringify(err)}`);
    }
  }
}