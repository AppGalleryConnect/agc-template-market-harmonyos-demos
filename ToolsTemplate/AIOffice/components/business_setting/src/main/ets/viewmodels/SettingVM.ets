import { ConfigurationConstant } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import {
  AppGalleryUtils,
  BaseViewModel,
  CommonConfirmDialog,
  FileUtils,
  GlobalContext,
  RouterMap,
  RouterUtils
} from 'lib_common';
import { AccountApi } from 'lib_account';
import { ISelectOption, SettingItem } from '../types/Types';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  private accountInstance: AccountApi = new AccountApi();
  @Trace isFocusOnPage: boolean = true;
  @Trace isLoading: boolean = false;
  @Trace cacheSize: string = '0';
  @Trace cacheSettingItem = new SettingItem({
    label: '清理缓存',
    extraLabel: this.getLocalCacheLabel(),
    onClick: () => {
      this.onCacheConfirmClick()
    },
  })
  @Trace colorSettingItem = new SettingItem({
    label: '夜间模式',
    typeSelect: true,
    selectTitle: '夜间模式',
    selectOptions: [
      {
        id: 0,
        label: '跟随系统',
        value: -1,
      },
      {
        id: 1,
        label: '普通模式',
        value: 1,
      },
      {
        id: 2,
        label: '夜间模式',
        value: 0,
      },
    ],
    selectV: this.getColorIndex(),
    onSelect: (option) => {
      this.settingInfo.colorMode = (option as ISelectOption).value as ConfigurationConstant.ColorMode;
      this.colorSettingItem.selectV = this.getColorIndex();
      (GlobalContext.getContext() as Context).getApplicationContext().setColorMode(this.settingInfo.colorMode);
    },
  });
  @Trace pushSettingItem = new SettingItem({
    label: '通知开关',
    typeSwitch: true,
    switchV: this.settingInfo.pushSwitch,
    onClick: (isOn) => {
      this.requestPushPermission(isOn as boolean);
    },
  });
  @Trace list1: SettingItem[] = [
    new SettingItem({
      label: '个人信息',
      routerName: RouterMap.SETTING_PERSONAL,
      onClick: () => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL);
        } else {
          GlobalContext.getUIContext().getPromptAction().showToast({ message: '请先登录' });
        }
      },
    }),
    new SettingItem({
      label: '隐私设置',
      routerName: RouterMap.SETTING_PRIVACY,
    }),
  ];
  @Trace list2: SettingItem[] = [
    this.pushSettingItem,
    this.cacheSettingItem,
  ];
  @Trace list3: SettingItem[] = [
    this.colorSettingItem,
  ];
  @Trace list4: SettingItem[] = [
    new SettingItem({
      label: '检测版本',
      onClick: () => {
        const context = GlobalContext.getContext()
        AppGalleryUtils.checkAppUpdate(context).then((resp: boolean) => {
          if (resp) {
            AppGalleryUtils.showUpdateDialog(context);
          } else {
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '已是最新版本' });
          }
        })
      },
    }),
    new SettingItem({
      label: '关于我们',
      routerName: RouterMap.SETTING_ABOUT,
    }),
  ];

  requestPushPermission(isOn: boolean) {
    notificationManager.openNotificationSettings(GlobalContext.getContext())
      .then(() => {
        this.isFocusOnPage = false;
      })
  }

  getLatestPushStatus() {
    if (!this.isFocusOnPage) {
      const isOn = notificationManager.isNotificationEnabledSync();
      this.settingInfo.pushSwitch = isOn;
      this.pushSettingItem.switchV = isOn;
      this.isFocusOnPage = true;
    }
  }

  getCache() {
    FileUtils.getCache().then((resp: number) => {
      this.cacheSize = (resp / 1024 / 1024).toFixed(2);
      this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
    })
  }

  getLocalCacheLabel() {
    return `${this.cacheSize}M`;
  }

  getColorIndex() {
    if (this.settingInfo.colorMode === 0) {
      return 2;
    }
    if (this.settingInfo.colorMode === 1) {
      return 1;
    }
    return 0;
  }

  onCacheConfirmClick() {
    CommonConfirmDialog.show({
      content: '确定清除缓存吗？',
      confirm: () => {
        this.cacheSize = '0';
        this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
        FileUtils.clearCache();
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '清除缓存成功' });
      }
    })
  }

  onSignOutBtnClick() {
    CommonConfirmDialog.show({
      content: '确定退出登录吗？',
      confirm: () => {
        this.isLoading = true;
        this.accountInstance.signOut()
          .then(() => {
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '已退出登录' });
          })
          .finally(() => {
            this.isLoading = false;
          });
      },
    })
  }

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出登录'
  }
}