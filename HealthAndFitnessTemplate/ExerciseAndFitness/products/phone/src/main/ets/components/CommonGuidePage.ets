import { CommonConstants, GridRowColSetting } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { GuidePageVM } from '../viewmodels/GuidePageVM';


@ComponentV2
export struct CommonGuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Param isShowSubTitle: boolean = true
  @Param guideTitle?: ResourceStr = ''
  @Param guideDesc: ResourceStr = ''
  @Param isShowSkipButton?: boolean = true
  @Param isShowNextButton?: boolean = true
  @Param nextButtonDesc?: string = '下一步'
  @Param backColor?: ResourceStr = '#F1F3F5'
  @BuilderParam customBuilderParam?: CustomBuilder;

  @Event onNextButtonClick?: () => void = () => {}
  @Event onSkipButtonClick?: () => void = () => {}
  @Event onNavShown?: () => void = () => {}
  @Builder
  skipBuilder() {
    Text('跳过')
      .width(104)
      .height(40)
      .borderRadius(20)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(TextAlign.Center)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.onSkipButtonClick?.())
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          isSubTitle: this.isShowSubTitle,
          rightPartBuilder: () => {
            if (this.isShowSkipButton) {
              this.skipBuilder();
            }
          },
        })
      }

      Column() {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.SMALL_CENTER_COL_SPAN,
            offset: GridRowColSetting.SMALL_CENTER_COL_OFFSET
          }) {
            Column() {
              Column() {
                if (this.guideTitle) {
                  Column() {
                    Text(this.guideTitle)
                      .fontSize($r('sys.float.Title_L'))
                      .fontWeight(FontWeight.Medium)
                      .margin({
                        bottom: 24,
                      })

                    Row({ space: CommonConstants.SPACE_S }) {
                      Image($r('app.media.ic_privacy'))
                        .width(16)
                        .draggable(false)
                        .margin({ right: 4 })
                      Text(this.guideDesc)
                        .fontSize($r('sys.float.Body_S'))
                        .fontColor($r('sys.color.font_secondary'))
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width('100%')
                }
                if (this.customBuilderParam) {
                  Column() {
                    this.customBuilderParam()
                  }
                }
              }
              .width('100%')
              if (this.isShowNextButton) {
                Column() {
                  // 只在非第一页显示下一步按钮
                  Button(this.nextButtonDesc, { type: ButtonType.Capsule })
                    .width(328)
                    .height(40)
                    .fontColor($r('sys.color.font_on_primary'))
                    .backgroundColor($r('app.color.app_theme'))
                    .onClick(() => {
                      this.onNextButtonClick?.()
                    })
                    .margin({ bottom: CommonConstants.PADDING_M })
                }
                .width('100%')
                .padding({ bottom: 20 })
              }
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
        }
      }
      .margin({ top: 16 })
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
      })
      .layoutWeight(1)
    }
    .backgroundColor(this.backColor)
    .hideTitleBar(true)
    .onShown(() => {
      this.onNavShown?.()
    })
  }
}
