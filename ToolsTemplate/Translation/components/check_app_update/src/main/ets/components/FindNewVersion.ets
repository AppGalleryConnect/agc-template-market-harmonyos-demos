import { pullUpAppGallery } from '../utils/AppUpdateUtil';
import { DialogController } from '../utils/DialogController';
import { common } from '@kit.AbilityKit';
import { Params } from '../model/Params';

@Builder
export function findNewVersion(params: Params) {
  Column() {
    // todo
    // 0 不存在新版本， 1 存在新版本
    Text('模拟新版本更新')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(0,0,0,0.90)')
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: 16 })

    Column({ space: 4 }) {
      Row({ space: 10 }) {
        Text('应用')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
        Text('翻译')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
          .fontWeight(FontWeight.Medium)
      }

      Row({ space: 10 }) {
        Text('版本')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
        Text('10.15.2')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
          .fontWeight(FontWeight.Medium)
      }

      Row({ space: 10 }) {
        Text('大小')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
        Text('50MB')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
          .fontWeight(FontWeight.Medium)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)


    Text('详情')
      .fontSize(16)
      .fontColor('rgba(0,0,0,0.90)')
      .fontWeight(FontWeight.Medium)
      .alignSelf(ItemAlign.Start)
      .margin({ top: 16, bottom: 8 })

    Text('1、修复 若干bug')
      .fontSize(16)
      .fontColor('rgba(0,0,0,0.90)')
      .alignSelf(ItemAlign.Start)
      .lineHeight(22)

    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      Text('以后再说')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .onClick(() => {
          DialogController.closeDialog();
        })

      Text('立即更新')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#46B1E3')
        .onClick(() => {
          pullUpAppGallery(DialogController.ctx.getHostContext() as common.UIAbilityContext);
        })
    }
    .margin({ top: 40 })
  }
  .width('90%')
  .borderRadius(32)
  .padding(24)
  .backgroundColor(Color.White)
}