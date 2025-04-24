import { Constants } from 'utils';

@Builder
export function PrivacyPolicyPageBuilder(name: string, param: Object) {
  PrivacyPolicyPage();
}

@ComponentV2
@Preview
export struct PrivacyPolicyPage {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
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

        Text('安全保障')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Column({space:3}) {
          Text('数据存储在设备本地时采取加密措施 ')
            .lineHeight(20)
          Text('数据传输中采用加密措施 ')
            .lineHeight(20)
          Text('数据存储在服务器时采用加密措施 ')
            .lineHeight(20)
          Text('数据访问权限得到管控 ')
            .lineHeight(20)
        }
        .padding(15)
        .backgroundColor(Color.White)
        .width('100%')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .height('100%')
      .width('90%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('隐私政策')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR);
  }
}