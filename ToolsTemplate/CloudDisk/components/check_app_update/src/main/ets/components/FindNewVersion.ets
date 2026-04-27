import { pullUpAppGallery } from '../utils/AppUpdateUtil';
import { DialogController } from '../utils/DialogController';
import { common } from '@kit.AbilityKit';
import { Params } from '../model/Params';

@Builder
export function findNewVersion(params: Params) {
  Column() {
    // todo
    // 0 不存在新版本， 1 存在新版本
    Text(params.text === 0 ? '发现新版本' : '未发现新版本，开始mock')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(0,0,0,0.90)')
      .alignSelf(ItemAlign.Start)
      .padding({
        top: 15,
        bottom: 27
      })

    Column({ space: 4 }) {
      Row({ space: 10 }) {
        Text('应用')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
        Text('云盘APP')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
          .fontWeight(FontWeight.Medium)
      }

      Row({ space: 10 }) {
        Text('版本')
          .fontSize(16)
          .fontColor('rgba(0,0,0,0.90)')
        Text('1.0.2.303')
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

    if (params.text === 0) {
      Text('详情')
        .fontSize(16)
        .fontColor('rgba(0,0,0,0.90)')
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .padding({
          top: 24,
          bottom: 12
        })

      Text('1、修改 若干bug')
        .fontSize(16)
        .fontColor('rgba(0,0,0,0.90)')
        .alignSelf(ItemAlign.Start)
        .lineHeight(22)
    }


    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      Text('以后再说')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#9DA3AA')
        .onClick(() => {
          DialogController.closeDialog();
        })

      Text('立即更新')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#0A59F7')
        .onClick(() => {
          pullUpAppGallery(DialogController.ctx.getHostContext() as common.UIAbilityContext);
        })
    }
    .padding({
      top: 21
    })
  }
  .width('90%')
  .height(310)
  .borderRadius(32)
  .padding({
    left: 24,
    right: 24
  })
  .backgroundColor(Color.White)
}