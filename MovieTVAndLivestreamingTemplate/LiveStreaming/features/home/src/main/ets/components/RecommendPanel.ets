import { getMedia, getString } from '@agctemplate/resources'
import { RankList } from './RankList'
import { display } from '@kit.ArkUI'

@ComponentV2
export struct RecommendPanel {
  @Event onLiveClick: () => void
  @Local listWidth:string = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED? '50%' : '100%'
  @Local isExpanded:boolean = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED
  callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if(data === display.FoldStatus.FOLD_STATUS_FOLDED){
      this.isExpanded = false
      this.listWidth = '100%'
    }else if(data === display.FoldStatus.FOLD_STATUS_EXPANDED){
      this.isExpanded = true
      this.listWidth = '50%'
    }
    console.info('Listening enabled. Data: ' + JSON.stringify(data));
  };

  aboutToAppear(): void {
    try {
      display.on('foldStatusChange', this.callback);
    } catch (e) {
    }
  }

  build() {
    Column() {
      Row() {
        Text(getString('app.string.hot_recommend'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(500)
          .fontSize(16)
      }.width('100%')
      .margin({
        top: 12, bottom: 12
      })

      Row({space:8}) {
        Column(){
          RankList({ onLiveClick: this.onLiveClick })
        }
        .width(this.listWidth)
        if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          Column(){
            RankList({ onLiveClick: this.onLiveClick })
          }
          .width(this.listWidth)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}