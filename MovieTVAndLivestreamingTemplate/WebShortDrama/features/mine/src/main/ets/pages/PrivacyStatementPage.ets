import { AppStorageKeys, FontModel, StatusBarHeight } from '@agctemplate/widgets';
import { Header } from '../component/Header'
import { AppStorageV2 } from '@kit.ArkUI';
import { getMedia } from '@agctemplate/resources';

// 隐私声明
@Preview
@ComponentV2
export struct PrivacyStatementPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  scroller: Scroller = new Scroller();

  build() {
    NavDestination() {
      Column() {
        Header()
        Scroll(this.scroller) {
          Column() {
            Image(getMedia('app.media.ic_security_shield'))
              .size({ width: 32, height: 32 })
              .margin({ top: 16 })

            Text('XX业务与隐私的声明')
              .fontSize(this.fontModel.getFg(20))
              .height(this.fontModel.getDesFg(27))
              .fontWeight(FontWeight.Bold)
              .margin({ top: 19, bottom: 4 })
            Text('更新时间：2024-08-13 12:00:00')
              .fontSize(this.fontModel.getFg(14))
              .fontColor($r('sys.color.font_secondary'))
              .height(this.fontModel.getDesFg(19))
              .fontWeight(FontWeight.Regular)
              .margin({ bottom: 16 })
            Text(' XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的保护措施。\n\n ' +
              '1、我们如何收集和使用您的个人信息 \n\n' +
              '...... \n\n' +
              '4、对儿童的保护 \n\n' +
              '5、与第三方共享（共享） \n\n' +
              '6、管理您的数据 \n\n' +
              '7、数据存储地点及期限 \n\n' +
              '8、如何联系我们 \n\n' +
              '华为将始终遵照我们的隐私政策来收集和使用您的信息。有关我们的隐私政策，可参阅华为消费者业务隐私声明。')
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })
              .lineBreakStrategy(LineBreakStrategy.BALANCED)
          }
          .padding(16)
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }.width('100%').height('100%')

    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`, bottom: 36 })
  }
}

@Builder
export function PrivacyStatementPageBuilder() {
  PrivacyStatementPage()
}