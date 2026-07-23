import { RouterMap, RouterUtils } from 'lib_common';
import { HistoryButton } from '../../components/HistoryButton';
import { NavHeaderBar } from '../../widget/NavHeaderBar';

@ComponentV2
export struct OfficePage {
  build() {
    Column() {
      NavHeaderBar({
        title:'AI办公',
        isSubTitle:false,
        showBackBtn:false
      }) {
        HistoryButton({
          onEvent:()=>{
            RouterUtils.pushPathByName(RouterMap.OFFICE_HISTORY_PAGE)
          }
        })
      }
      Row({ space: 12 }) {
        Column() {
          Image($r('app.media.paper_writing'))
            .height(64)
            .width(64)

          Text('论文写作')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 12 })

          Text('高效生成文章范文')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .margin({ top: 8, bottom: 10 })
        }
        .width(`calc((100% - 12vp)/2)`)
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.PAPER_WRITING_PAGE)
        })

        Column() {
          Image($r('app.media.summary'))
            .height(64)
            .width(64)

          Text('智能总结')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 12 })

          Text('高效生成概要总结')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .margin({ top: 8, bottom: 10 })
        }
        .width(`calc((100% - 12vp)/2)`)
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.AI_SUMMARY_PAGE)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 27 })
      .padding({
        left: 16, right: 16
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }
}