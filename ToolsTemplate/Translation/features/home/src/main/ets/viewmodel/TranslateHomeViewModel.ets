// 翻译首页ViewModel

import { LanguageViewModel, LanguageType } from 'choose_language';
import { BreakpointModel, UserInfo } from 'common';
import { BreakpointNameEnum } from 'common/src/main/ets/constant/GridRowColSetting';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

// VIP状态变更事件ID
const VIP_STATUS_CHANGE_EVENT_ID = 10001;

@ObservedV2
export class TranslateHomeViewModel {
  private static _instance: TranslateHomeViewModel;
  public languageViewModel: LanguageViewModel = new LanguageViewModel();
  @Trace showLanguagePicker: boolean = false;
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  static get instance(): TranslateHomeViewModel {
    if (!TranslateHomeViewModel._instance) {
      TranslateHomeViewModel._instance = new TranslateHomeViewModel();
      // 注册VIP状态变更事件监听
      TranslateHomeViewModel._instance.registerVipStatusListener();
    }
    // 每次获取实例时同步VIP状态
    TranslateHomeViewModel._instance.syncVipStatus();
    return TranslateHomeViewModel._instance;
  }

  // 注册VIP状态变更事件监听
  private registerVipStatusListener(): void {
    try {
      emitter.on({ eventId: VIP_STATUS_CHANGE_EVENT_ID }, (eventData) => {
        const isVip = eventData?.data?.isVip as boolean ?? false;
        this.languageViewModel.setVipStatus(isVip);
      });
    } catch (err) {
    }
  }

  @Monitor('userInfo.isVip')
  onVipStatusChange(): void {
    this.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  // 同步VIP状态
  public syncVipStatus(): void {
    this.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  public openLanguagePicker(type: LanguageType): void {
    this.languageViewModel.setEditingType(type);
    this.showLanguagePicker = true;
  }

  public closeLanguagePicker(): void {
    this.showLanguagePicker = false;
  }

  //判断是否显示折叠屏布局
  @Computed
  get isFoldScreen(): boolean {
    return this.breakpointModel.currentBreakpoint !== BreakpointNameEnum.SM;
  }

  //获取功能卡片列数
  @Computed
  get cardColumns(): number {
    return this.isFoldScreen ? 2 : 1;
  }

  private constructor() {
  }
}
