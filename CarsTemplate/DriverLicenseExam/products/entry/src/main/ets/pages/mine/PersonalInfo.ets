import fs from '@ohos.file.fs';
// import { MinePageVM } from '../viewModels/MinePageVM';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
// import { buildTitleBar, Logger } from 'commonlib';
import { util } from '@kit.ArkTS';
import { CustomContentDialog, LengthMetrics } from '@kit.ArkUI';
import { AccountUtil, CommonModel, Logger, UserInfoModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { CommonConstants } from '@ohos_agcit/driver_license_exam_guide';
import { rightArrow } from './FeedTitle';

import { PersonalInfo, PersonalInfoView, DataType, SwitchInfo, ApiHandler, GenderType } from 'collect_personal_info';

@Builder
export function PersonalInfoBuilder() {
  Personal();
}

@ComponentV2
struct Personal {
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();
  topRectHeight: number = AppStorage.get('topRectHeight') || 0;
  vm: CommonModel = CommonModel.instance;

  aboutToAppear(): void {}

  @Local switchInfo: SwitchInfo = {
    showAvatar: true,
    showNickName: true,
    showFullName: false,
    showGender: false,
    showBirthDate: false,
    showPhoneNumber: false,
    showIntroDesc: false,
  };
  @Local personalInfo: PersonalInfo = {
    avatar: AccountUtil.getUserInfo().avatar,
    nickName: AccountUtil.getUserInfo().nickname,
  };
  @Local apiInfo: ApiHandler = {
    updateAvatar: (param: Object) => {
      return new Promise((resolve) => {
        const userInfo = AccountUtil.getUserInfo();
        userInfo.avatar = param as string;
        AccountUtil.setUserInfo(userInfo);
        resolve(param as ESObject)
      })
    },
    updateNickName:  (param: Object) => {
      return new Promise((resolve) => {
        const userInfo = AccountUtil.getUserInfo();
        userInfo.nickname = param as string;
        AccountUtil.setUserInfo(userInfo);
        resolve(param as ESObject)
      })
    },
  };

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        PersonalInfoView({
          switchInfo: this.switchInfo,
          personalInfo: this.personalInfo,
          apiInfo: this.apiInfo,
          onChange: (type: DataType, data: PersonalInfo) => {
            Logger.info('PersonalInfo', 'personal info change, all data: %{public}s', JSON.stringify(data));
          }
        })
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding({ top: 12, left: 16, right: 16 });
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .padding({
      top: 10,
      left: '4%',
      right: '4%'
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .title('个人信息')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight) + 10,
    })
  }
}



@Extend(Text)
function textExtend() {
  .fontSize(16)
  .fontFamily('鸿蒙黑体')
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
  .fontColor($r('sys.color.black'));
}
