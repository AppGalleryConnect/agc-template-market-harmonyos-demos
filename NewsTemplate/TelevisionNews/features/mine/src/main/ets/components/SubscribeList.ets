import { ValueType } from '@kit.ArkData';
import { Constants, emptyBuilder, loadingPage } from 'lib_common';
import { AvModel } from 'lib_tv_apis';
import { VideoPipViewModel } from 'lib_tv_details';
import { SubscribeViewModel } from '../viewmodels/SubscribeVM';

@ComponentV2
export struct SubscribeList {
  @Require @Param vm: SubscribeViewModel;
  @Param loading: boolean = false;
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
                      .fontSize(16)
                    Text(v.description)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontWeight(FontWeight.Regular)
                      .fontSize(12)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('50%')
                  .alignItems(HorizontalAlign.Start)
                }
                .onClick(async () => {
                  const params: Record<string, ValueType> = {
                    'id': v.id,
                  }
                  this.vm.pushToAvDetails(params)
                })

                Button(v.isFollow ? '已订阅' : '订阅')
                  .fontColor(v.isFollow ? '#EB5544' : $r('sys.color.font_on_primary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor(v.isFollow ? $r('sys.color.comp_background_tertiary') : '#EB5544')
                  .width(72)
                  .height(28)
                  .padding(0)
                  .onClick(() => {
                    this.vm.subscribeOperation(v)
                  })
              }
            }
            .padding({
              top: Constants.PADDING_M,
              bottom: Constants.PADDING_M,
            })
          }, (v: AvModel) => v.id)
        }
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .columnsTemplate(this.vm.getColumnsTemplate())
        .columnsGap(Constants.SPACE_XXL)
        .rowsGap(Constants.SPACE_M)
        .cachedCount(1)
        .padding({
          top: Constants.SPACE_M,
          bottom: 28,
        })
      } else {
        Column() {
          emptyBuilder({
            text: this.vm.emptyTip,
          })
        }
        .layoutWeight(1)
        .padding({
          bottom: 100,
        })
      }
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
  }
}