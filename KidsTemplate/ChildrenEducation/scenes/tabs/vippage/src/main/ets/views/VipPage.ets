import { User } from '@ohos_agcit/children_education_datasource';
import { CommonConstants } from '@ohos_agcit/children_education_utils';
import { UserInfo } from '../components/UserInfo'

@Builder
export function VipPageBuilder() {
  VipPage()
}

@ComponentV2
export struct VipPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.IS_VIP) isVip : boolean = false;
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

  build() {
    NavDestination(){
      Scroll() {
        Column() {
          UserInfo()

          Row() {
            Column() {
              Text($r('app.string.learning_vip'))
                .textAlign(TextAlign.Start)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontFamily('鸿蒙黑体')
                .padding({ left: 16, bottom: 20, top: 20 })
              Image($r('app.media.banner')).padding({ left: 16, right: 16 })
                .height(500).width(CommonConstants.FULL_PERCENT)
            }.alignItems(HorizontalAlign.Start)
          }.margin({ top: 20 }).backgroundColor($r('sys.color.white'))
        }.backgroundColor('#F1F3F5')
      }
      .scrollBar(BarState.Off)
    }
    .hideTitleBar(true)
    .onBackPressed(()=>{
      this.appPathStack.pop();
      return true;
    })

  }
}