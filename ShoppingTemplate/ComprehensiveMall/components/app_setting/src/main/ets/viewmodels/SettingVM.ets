import {
  common, ConfigurationConstant, EnvironmentCallback,
} from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { notificationManager } from '@kit.NotificationKit';
import { Logger } from 'module_ui_base';
import { ToastDialog as promptAction, ToastDialog } from '@hw-agconnect/ui-toast';
import { AppGalleryUtils } from '../common/AppGalleryUtils';
import { ColorModePreference } from '../common/ColorModePreference';
import { FileUtils } from '../common/FileUtils';
import { CommonConfirmDialog } from '../components/CommonConfirmDialog';
import { LOG_TAG } from '../constants/CommonConstants';
import { lightDarkOptions } from '../constants/LightDarkOptions';
import { BaseViewModel } from '../models/BaseViewModel';
import {
  AboutModel, AgreementModel, IFontModel, WebModel,
} from '../models/CustomConfigModel';
import { SettingItem, SettingGroup } from '../types/SettingItem';
import {
  SettingPageEnum, SettingType, SupportedSetting,
} from '../types/SettingType';

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
      });
    });
  }

  handlePrivacy(item: SettingItem) {
    item
      .setType(SettingType.ROUTER)
      .setLabel(item.label ?? '隐私设置')
      .setRouterParam({ routerName: SettingPageEnum.SETTING_PRIVACY });
    this.handleGlobalAgreement(item.extraParams as AgreementModel);
  }

  handlePush(item: SettingItem) {
    try {
      const isOn = notificationManager.isNotificationEnabledSync();
      item
        .setType(SettingType.SWITCH)
        .setLabel(item.label ?? '通知开关')
        .setSwitchValue(isOn)
        .setItemId(this.PUSH_ITEM_ID)
        .setClickEvent(() => {
          notificationManager.openNotificationSettings(
            this.uiContext?.getHostContext() as common.UIAbilityContext,
          ).catch((err: BusinessError) => {
            Logger.error(LOG_TAG, 'set notification status failed. error:' + JSON.stringify(err));

          });
        });
    } catch (err) {
      Logger.error(LOG_TAG, 'get notification status failed. error:' + JSON.stringify(err));
    }

  }

  async handleCache(item: SettingItem) {
    item
      .setType(SettingType.TEXT)
      .setLabel(item.label ?? '清理缓存')
      .setClickEvent(() => {
        if (!this.uiContext) {
          return;
        }
        CommonConfirmDialog.show({
          primaryTitle: '温馨提示',
          content:
          'APP使用过程中下载的图片、音频、视频等资源将被清除，不可还原。',
          confirm: () => {
            FileUtils.clearCache(this.uiContext?.getHostContext()!);
            setTimeout(async () => {
              const cache = await this.getCache();
              item.setNormalText(cache);
              promptAction.showToast({ message: '清除缓存成功' });
              if (item.onChange) {
                item.onChange(cache);
              }
            }, 400);
          },
        });
      });
    const cache = await this.getCache();
    item.setNormalText(cache);
  }

  handleDark(item: SettingItem) {
    const options = item.selectOptions ?? lightDarkOptions;
    let initialIndex = item.selectIndex;
    const savedIndex = ColorModePreference.getSavedColorModeIndex(this.context);
    if (savedIndex >= 0 && savedIndex < options.length) {
      initialIndex = savedIndex;
    } else {
      const currentColorMode = this.context?.config?.colorMode as ConfigurationConstant.ColorMode;
      const currentIndex = ColorModePreference.getColorModeIndexByMode(currentColorMode);
      if (currentIndex >= 0 && currentIndex < options.length) {
        initialIndex = currentIndex;
      }
    }
    item.setSelectIndex(initialIndex);

    item
      .setType(SettingType.SELECT)
      .setLabel(item.label ?? '显示模式')
      .setSelectOptions(options)
      .setSelectEvent((index: number) => {
        const colorMode = options[index]
          .value as ConfigurationConstant.ColorMode;
        try {
          this.uiContext
          ?.getHostContext()
          ?.getApplicationContext()
            .setColorMode(colorMode);
          ColorModePreference.saveColorModeIndex(this.context, index);
          if (item.onChange) {
            item.onChange(colorMode);
          }
        } catch (err) {
          Logger.error(LOG_TAG, 'set color mode failed. error: ' + JSON.stringify(err));
        }
      });
  }

  handleFont(item: SettingItem) {
    item
      .setType(SettingType.ROUTER)
      .setLabel(item.label ?? '字体大小')
      .setRouterParam({ routerName: SettingPageEnum.SETTING_FONT });
    this.handleGlobalFont(item.extraParams as IFontModel);
  }

  handleVersionCheck(item: SettingItem) {
    item
      .setType(SettingType.TEXT)
      .setLabel(item.label ?? '检测版本')
      .setClickEvent(() => {
        const context =
          this.uiContext?.getHostContext() as common.UIAbilityContext;
        if (!context) {
          return;
        }
        AppGalleryUtils.checkAppUpdate(context).then((resp: boolean) => {
          if (resp) {
            AppGalleryUtils.showUpdateDialog(context);
          } else {
            ToastDialog.showToast({ message: '已是最新版本' });
          }
          if (item.onChange) {
            item.onChange(resp);
          }
        });
      });
  }

  handleAbout(item: SettingItem) {
    item
      .setType(SettingType.ROUTER)
      .setLabel(item.label ?? '关于我们')
      .setRouterParam({ routerName: SettingPageEnum.SETTING_ABOUT });
    this.handleGlobalAbout(item.extraParams as AboutModel);
  }

  handleWeb(item: SettingItem) {
    item.setRouterParam({
      routerName: SettingPageEnum.SETTING_AGREEMENT,
      routerParams: (item.extraParams as WebModel).src,
    });
  }

  handleGlobalAgreement(agreementInfo: AgreementModel) {
    if (agreementInfo.userAgreement) {
      this.configInfo.agreementModel.userAgreement =
        agreementInfo.userAgreement;
    }
    if (agreementInfo.privacyPolicy) {
      this.configInfo.agreementModel.privacyPolicy =
        agreementInfo.privacyPolicy;
    }
    if (agreementInfo.thirtyItem) {
      this.configInfo.agreementModel.thirtyItem = agreementInfo.thirtyItem;
    }
    if (agreementInfo.personalCollection) {
      this.configInfo.agreementModel.personalCollection =
        agreementInfo.personalCollection;
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
      fontModel.onChange?.(
        this.fontModel.followSystem,
        this.fontModel.fontSizeRatio,
        this.fontModel.sysFontSizeScale,
      );
    };
  }

  getLatestPushStatus() {
    try {
      const isOn = notificationManager.isNotificationEnabledSync();
      this.settingList.forEach((group: SettingGroup) => {
        group.list.forEach((item: SettingItem) => {
          if (item.id === this.PUSH_ITEM_ID) {
            const oldValue = item.switchV;
            item.setSwitchValue(isOn);
            if (item.onChange && oldValue !== isOn) {
              item.onChange(isOn);
            }
          }
        });
      });
    } catch (err) {
      Logger.error(LOG_TAG, 'get notification status failed. error:' + JSON.stringify(err));
    }
  }

  getCache() {
    return FileUtils.getCache().then((resp: number) => {
      const cacheSize = (resp / 1024 / 1024).toFixed(2);
      return `${cacheSize}M`;
    });
  }

  onConfigurationUpdate(): void {
    if (!this.context) {
      return;
    }
    this.fontModel.sysFontSizeScale = this.context.config
    ?.fontSizeScale as number;
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated: (config) => {
        this.fontModel.sysFontSizeScale = config.fontSizeScale as number;
      },
      onMemoryLevel: () => {
      },
    };
    try {
      this.callbackId = this.context
        .getApplicationContext()
        .on('environment', environmentCallback);
    } catch (err) {
      Logger.error(
        TAG,
        `Failed to register applicationContext. err: ${JSON.stringify(err)}`,
      );
    }
  }

  offConfigurationUpdate() {
    if (!this.context) {
      return;
    }
    try {
      this.context.getApplicationContext().off('environment', this.callbackId);
    } catch (err) {
      Logger.error(TAG, `offConfigurationUpdate failed. err: ${JSON.stringify(err)}`);
    }
  }
}
