import { AvRouter } from 'lib_av_details'
import { AvModel, NewsEnum } from 'lib_news_api'
import { BroadcastExtraModel } from '../models/BroadcastModel'
import { BroadcastViewModel } from '../viewmodels/BroadcastViewModel'

@ComponentV2
export struct BroadcastLikeView {
  @Param @Require extraInfo: BroadcastExtraModel
  @Local broadcastViewModel: BroadcastViewModel = new BroadcastViewModel(this.getUIContext())
  private avRouter: AvRouter = new AvRouter(this.getUIContext())

  aboutToAppear(): void {
    this.broadcastViewModel.requestBroadcastLike(this.extraInfo.id)
  }

  @Builder
  broadcastList() {
    List({ space: 8 }) {
      ForEach(this.broadcastViewModel.broadcastExtraList, (item: AvModel, index: number) => {
        ListItem() {
          Column({ space: 4 }) {
            Image(item.coverUrl)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .clip(true)
              .width(this.broadcastViewModel.getBroadcastSize)
              .height(this.broadcastViewModel.getBroadcastSize)
            Text(item.title)
              .fontSize(this.broadcastViewModel.settingInfo.fontSizeRatio * 14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .backgroundColor($r('sys.color.background_primary'))
          .id('broadcast_flow_tb' + item.id + index)
          .onClick(() => {
            const params: Record<string, string | NewsEnum | boolean> = {
              'id': item.id,
              'type': item.type,
              'isCreateSubWindow': false,
            }
            this.avRouter.pushToAvDetails(params,
              'broadcast_flow_tb' + item.id + index)
          })
        }
      }, (item: AvModel) => item.id)
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  build() {
    Column({ space: 16 }) {
      Text(this.extraInfo.title)
        .fontSize(this.broadcastViewModel.settingInfo.fontSizeRatio * 18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
      this.broadcastList()
    }
    .alignItems(HorizontalAlign.Start)
  }
}