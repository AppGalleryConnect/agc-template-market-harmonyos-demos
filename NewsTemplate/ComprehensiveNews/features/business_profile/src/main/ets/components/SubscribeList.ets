import { ValueType } from '@kit.ArkData';
import { AvRouter, VideoPipViewModel } from 'lib_av_details';
import { CommonConstants, loadingPage, NewsEnum } from 'lib_common';
import { AvModel } from 'lib_news_api';
import { emptyBuilder } from 'lib_widget';
import { SubscribeViewModel } from '../viewmodels/SubscribeVM';

@ComponentV2
export struct SubscribeList {
  @Require @Param vm: SubscribeViewModel;
  @Param loading: boolean = false;
  private avRouter: AvRouter = new AvRouter(this.getUIContext())
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()

  build() {
    Column() {
      if (this.loading) {
        loadingPage()
      } else if (this.vm.dataSource.totalCount() > 0) {
        WaterFlow() {
          LazyForEach(this.vm.dataSource, (v: AvModel) => {
            FlowItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Row({ space: 12 }) {
                  Image(v.coverUrl)
                    .width(56)
                    .height(56)
                    .borderRadius(8)
                    .clip(true)
                    .objectFit(ImageFit.Cover)
                  Column({ space: 4 }) {
                    Text(v.title).fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
                    Text(v.description)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontWeight(FontWeight.Regular)
                      .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('50%')
                  .alignItems(HorizontalAlign.Start)
                }
                .onClick(async () => {
                  const params: Record<string, ValueType | NewsEnum> = {
                    'id': v.id,
                    'type': v.type,
                  }
                  await this.videoPipViewModel.isRestPipController(v.id)
                  this.avRouter.pushToAvDetails(params, '')
                })

                Button(v.isFollow ? '已订阅' : '订阅')
                  .fontColor(v.isFollow ? $r('sys.color.font_emphasize') : $r('sys.color.font_on_primary'))
                  .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor(v.isFollow ? $r('sys.color.comp_background_tertiary') : '#5C79D9')
                  .width(72)
                  .height(28)
                  .padding(0)
                  .onClick(() => {
                    this.vm.subscribeOperation(v)
                  })
              }
            }
            .padding({
              top: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_M,
            })
          }, (v: AvModel) => v.id)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .columnsTemplate(this.vm.getColumnsTemplate())
        .columnsGap(CommonConstants.SPACE_XXL)
        .rowsGap(CommonConstants.SPACE_M)
        .cachedCount(1)
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          top: CommonConstants.SPACE_M,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      } else {
        Column() {
          emptyBuilder({
            text: this.vm.emptyTip,
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
          })
        }
        .layoutWeight(1)
        .padding({
          bottom: 100,
        })
      }
    }
    .layoutWeight(1)
  }
}