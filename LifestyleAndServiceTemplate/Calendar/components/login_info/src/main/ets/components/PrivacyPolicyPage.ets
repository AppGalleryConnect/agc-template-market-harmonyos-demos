import { BaseNavTitle } from 'base_apis';
import { ThemeVM } from '../viewModel/ThemeController';

@Builder
export function PrivacyPolicyPageBuilder() {
  PrivacyPolicyPage()
}

@ComponentV2
export struct PrivacyPolicyPage {
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local themeVM: ThemeVM = ThemeVM.instance;

  build() {
    NavDestination() {
      BaseNavTitle({
        title: '隐私政策',
        titleColor: this.themeVM.titleColor,
        currentTheme: this.themeVM.selectColor,
        routerModule: this.pathStack,
      })
      Column({ space: 15 }) {
        Text('数据收集')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Row(){
          Column({space:15}){
            Row(){
              Text('个人基本信息')
            }
            Row(){
              Text('个人位置信息')
            }
          }
          .alignItems(HorizontalAlign.Start)


          Column({space:15}){
            Row(){
              Text('用户内容')
            }
            Row(){
              Text('设备系统信息')
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(15)
        .backgroundColor(Color.White)
        .width('100%')
        .borderRadius(20)

        Text('数据共享')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Row() {
          Text('设备信息，包括终端设备唯一标识符，IDFV，OAID，IMEI，MAC地址，设备配置，网络信息，基站信息，蓝牙信息等。')
            .lineHeight(20)
        }
        .padding(15)
        .backgroundColor(Color.White)
        .width('100%')
        .borderRadius(20)
      }
      .alignItems(HorizontalAlign.Start)
      .height('100%')
      .width('90%')
      .margin({ top: 16 })
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.pathStack = ctx.pathStack
    })
  }
}