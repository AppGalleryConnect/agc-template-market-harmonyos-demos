import { CommonConstants } from 'app_setting/src/main/ets/constants/CommonConstants';
import { PersonalInfoView } from 'collect_personal_info';
import { BaseTitle } from 'commonlib';
import { PersonalInfoVM } from '../viewmodels/PersonalInfoVM';

@Builder
export function PersonalInfoPageBuilder() {
  PersonalInfoPage();
}

@ComponentV2
export struct PersonalInfoPage {
  vm: PersonalInfoVM = new PersonalInfoVM();

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        BaseTitle({
          title: '个人信息',
          titleFontSize: $r('sys.float.Title_S'),
          showBackBtn: true
        })
        PersonalInfoView({
          list: this.vm.list,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
        bottom: this.vm.windowSize.bottomHeight
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}