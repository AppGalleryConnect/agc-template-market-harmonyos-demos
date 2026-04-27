import * as wxopensdk from '@tencent/wechat_open_sdk';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants, LoginType } from '../common/Constant';

export type LoginFailError = BusinessError | wxopensdk.BaseResp

export class Channel {
  type: LoginType;
  name: string;
  icon: ResourceStr;
  extraInfo: ExtraInfo;

  constructor(type: LoginType, name: string, extraInfo: ExtraInfo, icon: ResourceStr) {
    this.type = type;
    this.name = name;
    this.icon = icon;
    this.extraInfo = extraInfo;
  }
}

export class ExtraInfo {
  appId: string = '';
  scope?: string;
  transaction?: string;
  state?: string;
}

export class PrivacyContent {
  privacyLabel: ResourceStr = ''
  privacyUrl: ResourceStr = ''
  privacyTag: string = ''
}

export class LoginParams {
  phoneNumbers?: string = ''
  verifyCode?: string = ''
  unionID?: string = ''
  authorizationCode?: string = ''
}

@ObservedV2
export class NavParam {
  @Trace privacyContent: PrivacyContent[] = []
  @Trace themeColor: ResourceColor = '#0A59F7';
  @Trace isSheet: boolean = false;
  @Trace isPersistence: boolean = false;
  icon: ResourceStr = '';
  @Trace loginTypes: Channel[] = [];
}

/**
 * 登录半模态弹窗参数
 */
@ObservedV2
export class LoginSheetParams {
  @Trace height: number = Constants.DEFAULT_LOGIN_SHEET_HEIGHT;
  @Trace sheetType: SheetType = SheetType.BOTTOM;
}

/**
 * 跳转协议页面路由参数
 */
export interface ProtocolRouterParams {
  content: string
  isSheet?: boolean
  sheetType?: SheetType
}
