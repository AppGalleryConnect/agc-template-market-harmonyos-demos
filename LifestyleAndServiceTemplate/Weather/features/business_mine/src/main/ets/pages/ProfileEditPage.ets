import { CommonHeader, WindowUtil } from 'lib_foundation';
import { PersonalInfoView } from 'collect_personal_info';
import { ProfileVM } from '../viewmodels/ProfileVM';

@ComponentV2
export struct ProfileEditPage {
  @Local profileVM: ProfileVM = new ProfileVM();

  aboutToAppear(): void {
    this.profileVM.buildList();
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '个人信息', bgColor: $r('sys.color.background_primary') })

        Scroll() {
          Column() {
            PersonalInfoView({
              list: this.profileVM.list,
              themeColor: $r('app.color.common_theme_color'),
            })
          }
          .padding({ left: 16, right: 16, top: 12 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }
}

@Builder
export function profileEditPageBuilder() {
  ProfileEditPage()
}
