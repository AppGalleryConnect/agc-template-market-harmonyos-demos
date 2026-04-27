import { WorkViewModel } from 'video_common';
import { TimeUtil, WindowParam } from 'common';

/**
 * @usage: 用于构建更多操作模态框的标题区域，展示作品缩略图、标题、文件大小和更新时间。
 * 关键参数：workItem作品视图模型。包含if逻辑：当status为finish时显示文件大小。
 * @layout: 横向排列。左侧为缩略图，右侧为纵向排列的标题和信息文本（左对齐）。
 * @constraints:
 * @zhName: 更多操作模态框标题
 * @fileType: component
 * @isGen: true
 */
// 更多模态框自定义标题
@Builder
export function
moreSheetTitleBuilder(workItem: WorkViewModel, param: WindowParam) {
  // 顶部信息区
  Row() {
    Image(workItem.thumbnail)
      .width(50)
      .height(50)
      .borderRadius(8)
      .margin({ top: 16 })
    Column() {
      Text(workItem.title)
        .fontSize(14)
        .fontColor('#FF000000')
        .margin({ top: 6, bottom: 4 })
        .lineHeight(19)

      Row() {
        if (workItem.status === 'finish') {
          Text(workItem.fileSize)
            .fontSize(12)
            .fontColor('#99000000')
            .padding({ right: 2 })
            .lineHeight(15)

        }
        Text(`${TimeUtil.formatAppointment(workItem.createTimestamp)}更新`)
          .fontSize(12)
          .fontColor('#99000000')
          .lineHeight(15)

      }
    }
    .height(50)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 12, top: 16 })

    Blank().layoutWeight(1)
    Image($r('app.media.ic_cancel'))
      .width(24)
      .height(24)
      .padding(4)
      .margin({ top: 16 })
      .onClick(() => {
        param.event?.remove()
      })
  }
  .height(82)
  .alignItems(VerticalAlign.Top)
}

// 元数据模态框自定义标题
@Builder
export function
metaDataSheetTitleBuilder(showClose = false, param: WindowParam) {
  // 顶部信息区
  Row() {
    Text('元数据')
      .fontColor('#FF000000')
      .fontSize(20)
      .textAlign(TextAlign.Center)
      .fontWeight(FontWeight.Medium)
      .margin({ left: showClose ? '40%' : 0 })
    Blank()
    Image($r('app.media.ic_cancel'))
      .width(24)
      .height(24)
      .padding(4)
      .onClick(() => {
        param.event?.remove()
      })
  }
  .width('100%')
  .height(56)
  .justifyContent(FlexAlign.Center)
}
