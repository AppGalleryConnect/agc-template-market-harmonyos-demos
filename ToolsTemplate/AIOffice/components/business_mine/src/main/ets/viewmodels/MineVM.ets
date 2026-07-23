import { BaseViewModel, CommonConfirmDialog, ERROR_MSG_MAP, RouterMap, RouterUtils } from 'lib_common';
import { FeedbackModel } from 'module_feedback';
import { SettingItem } from 'business_setting';
import { MineGridItem } from '../types/Types';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import {
  AccountApi,
  ApiController,
  Channel,
  LoginChannelType,
  LoginInfoOptions,
  LoginParams,
  LoginType
} from 'aggregated_login';
import { ProtocolData } from 'lib_account/src/main/ets/services/mockdata/ProtocolData';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class MineViewModel extends BaseViewModel {
  @Trace anonymousPhone: string = '177******96';
  private accountInstance: AccountApi = new AccountApi();
  // todo 需要传入应用申请到的AppID
  wxApi = wxopensdk.WXAPIFactory.createWXAPI('xxx')
  huaweiLogin = async (loginParams: LoginParams): Promise<void> => {
    this.accountInstance.huaweiLogin(loginParams.phoneNumbers ?? '');
    RouterUtils.pop();
  }
  wxLogin = async (): Promise<void> => {
    this.accountInstance.wechatLogin();
    RouterUtils.pop();
  }
  verifyCode = async (): Promise<void> => {
    // this.accountInstance.accountPasswordLogin();
  }
  handleLoginFail = (loginChannelType: LoginChannelType, error: BusinessError | wxopensdk.BaseResp) => {
    if (loginChannelType === LoginChannelType.HUAWEI) {
      const businessError = error as BusinessError
      const errorMsg = ERROR_MSG_MAP[businessError.code] ?? '未知错误。';
      CommonConfirmDialog.show({
        primaryTitle: '温馨提示',
        content: errorMsg + '是否先模拟登录成功？',
        confirm: () => {
          this.accountInstance.huaweiLogin(this.anonymousPhone);
          RouterUtils.pop()
        }
      })
      return;
    }
  }
  obtainVerifyCode: () => Promise<void> = () => new Promise(() => {
  });
  @Trace feedbackItem: SettingItem = new SettingItem({
    icon: $r('app.media.ic_public_edit'),
    label: '意见反馈',
    routerName: RouterMap.FEEDBACK_PAGE,
    routerParams: {
      windowTopPadding: this.windowModel.windowTopPadding,
      windowBottomPadding: this.windowModel.windowBottomPadding,
      fontSizeRatio: this.settingInfo.fontSizeRatio,
    } as FeedbackModel,
  });
  serviceList: SettingItem[] = [
    this.feedbackItem,
    new SettingItem({
      icon: $r('app.media.ic_public_setting'),
      label: '设置',
      routerName: RouterMap.SETTING_PAGE,
    }),
  ];

  @Monitor('settingInfo.fontSizeRatio')
  onFontRatioChange() {
    this.feedbackItem.routerParams = {
      windowTopPadding: this.windowModel.windowTopPadding,
      windowBottomPadding: this.windowModel.windowBottomPadding,
      fontSizeRatio: this.settingInfo.fontSizeRatio,
    } as FeedbackModel
  }

  jumpLogin() {
    RouterUtils.pushPathByName(RouterMap.AGGREGATED_LOGIN_PAGE, {
      icon: $r('app.media.startIcon'),
      themeColor: $r('sys.color.icon_emphasize'),
      isSheet: false,
      autoSheet: false,
      isPersistence: false,
      loginTypes: [new Channel(LoginType.WECHAT, '微信', {
        appId: 'xxx'
      }, $r('app.media.ic_wechat'))],
      privacyContent: [{
        privacyLabel: '《用户协议》',
        privacyUrl: ProtocolData.userProtocol,
        privacyTag: '用户协议'
      }, {
        privacyLabel: '《xxxx隐私政策》',
        privacyUrl: ProtocolData.privacyProtocol,
        privacyTag: '隐私政策'
      }, {
        privacyLabel: '《华为账号用户认证协议》',
        privacyUrl: ProtocolData.huaweiUserProtocol,
        privacyTag: '华为账号用户认证协议'
      }],
      apiController: new ApiController(this.huaweiLogin, this.wxLogin, this.verifyCode),
      handleLoginFail: this.handleLoginFail,
      obtainVerifyCode: this.obtainVerifyCode
    } as LoginInfoOptions);
  }

  jumpProfile() {
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME);
  }

  gridClick(v: MineGridItem) {
    RouterUtils.pushPathByName(v.routerName);
  }

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_default');
  }

  @Computed
  get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }
}