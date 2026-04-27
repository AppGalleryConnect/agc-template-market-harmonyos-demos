import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel, WindowParam } from 'common'
import { WorkViewModel } from 'video_common'
import { metaDataSheetTitleBuilder } from './ActionSheet'

@Builder
export function MetaDataSheetContentBuilderView(param: WindowParam) {
  MetaDataSheetContentBuilder({ param: param })
}

/**
 * 元数据模态框自定义内容
 */
@ComponentV2
struct MetaDataSheetContentBuilder {
  @Param @Require param: WindowParam
  @Local workItem?: WorkViewModel
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local openDetail: string = 'moreSheetcontent'

  aboutToAppear(): void {
    this.workItem = this.param.attachParam as WorkViewModel
  }

  build() {
    Column() {
      metaDataSheetTitleBuilder(true, this.param)
      Row() {
        Text(`文件格式：${this.workItem?.fileFormat}`).fontSize(16).fontColor('#CC000000')
      }.width('100%').padding({ bottom: 8 })

      Row() {
        Text(`视频编码格式：${this.workItem?.videoCodeFormat}`).fontSize(16).fontColor('#CC000000')
      }.width('100%').padding({ bottom: 8 })

      Row() {
        Text(`创建时间：${this.workItem?.createDate}`).fontSize(16).fontColor('#CC000000')
      }.width('100%').padding({ bottom: 8 })

      Row() {
        Text(`文件大小：${this.workItem?.resolutionRatio}  ${this.workItem?.fileSize}`)
          .fontSize(16)
          .fontColor('#CC000000')
      }.width('100%').padding({ bottom: 8 })

    }
    .width(this.breakPointModel.getWindowWidth())
    .height(196)
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}