import { CommonButton } from '../components/CommonButton';
import { CommonHeader } from '../components/CommonHeader';
import {
  FONT_COLOR_LIST,
  FONT_OPACITY_LIST,
  FONT_ROTATE_LIST,
  FONT_SIZE_LIST,
  FONT_SPACE_LIST,
  TAB_BAR_LIST,
} from '../constants/Constants';
import { StyleConstants } from '../constants/Styles';
import { WaterMarksVM } from '../viewmodel/WaterMarksVM';

@Builder
export function waterMarksEditPageBuilder() {
  WaterMarksEditPage();
}

@ComponentV2
export struct WaterMarksEditPage {
  vm: WaterMarksVM = WaterMarksVM.instance;
  @Local stack?: NavPathStack;

  aboutToAppear(): void {
    this.vm.resetParamsInEdit();
  }

  build() {
    NavDestination() {
      /** 顶部标题区 **/
      this.header()

      Scroll() {
        Column() {
          /** 图片展示区 **/
          this.show()

          /** 选项编辑区 **/
          this.options()
        }
      }
      .layoutWeight(1)

      CommonButton({
        title: '确定',
        handleClick: () => {
          this.vm.confirm();
          this.stack?.pop();
        },
      }).margin({ top: StyleConstants.SPACE_8 })
    }
    .onReady((event) => {
      this.stack = event.pathStack;
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  header() {
    if (this.stack) {
      CommonHeader({
        stack: this.stack, moreUi: () => {
          this.headerMoreUi()
        },
      })
    }
  }

  @Builder
  headerMoreUi() {
    Text('重置')
      .width(64)
      .height(40)
      .textAlign(TextAlign.Center)
      .borderRadius(StyleConstants.HALF_PERCENT)
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.vm.resetDrawParams();
      })
  }

  @Builder
  show() {
    Image(this.vm.pixelMapWithMarksTemp || this.vm.pixelMap)
      .objectFit(ImageFit.Contain)
      .width(StyleConstants.FULL_PERCENT)
      .aspectRatio(1)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
  }

  @Builder
  options() {
    Column() {
      Row() {
        ForEach(TAB_BAR_LIST, (item: string, index) => {
          Text(item)
            .fontColor(this.vm.tabIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(this.vm.tabIndex === index ? FontWeight.Bold : FontWeight.Medium)
            .onClick(() => {
              this.vm.tabIndex = index;
            })
        }, (item: string) => item)
      }
      .height(69)
      .width(StyleConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })

      Tabs({ index: $$this.vm.tabIndex }) {
        TabContent() {
          Column() {
            Text('编辑文字').titleStyle()
            TextInput({ text: $$this.vm.maskText })
              .height(40)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .padding({
                left: StyleConstants.SPACE_16,
                right: StyleConstants.SPACE_16,
                top: StyleConstants.SPACE_8,
                bottom: StyleConstants.SPACE_8,
              })
              .margin({ top: StyleConstants.SPACE_22, bottom: StyleConstants.SPACE_22 })

            Text('水印大小').titleStyle().margin({ bottom: StyleConstants.SPACE_14 })
            Slider({
              value: $$this.vm.fontSize,
              min: FONT_SIZE_LIST[0],
              max: FONT_SIZE_LIST[1],
              style: SliderStyle.InSet,
              step: 1,
            })
              .width('102%')
              .height(20)
              .alignSelf(ItemAlign.Center)
          }
          .height(StyleConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })


        TabContent() {
          Column() {
            Text('颜色').titleStyle()
            List({ space: StyleConstants.SPACE_8 }) {
              ForEach(FONT_COLOR_LIST, (color: string) => {
                ListItem()
                  .height(40)
                  .width(40)
                  .border({
                    radius: StyleConstants.HALF_PERCENT,
                    width: this.vm.fontColor === color ? 1 : 0,
                    color: $r('sys.color.white'),
                  })
                  .backgroundColor(color)
                  .onClick(() => {
                    this.vm.fontColor = color;
                  })
              }, (color: string) => color)
            }
            .lanes(1)
            .height(40)
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .margin({ top: StyleConstants.SPACE_12, bottom: StyleConstants.SPACE_22 })

            Text('透明度').titleStyle().margin({ bottom: StyleConstants.SPACE_14 })
            Slider({
              value: $$this.vm.fontOpacity,
              min: FONT_OPACITY_LIST[0],
              max: FONT_OPACITY_LIST[1],
              style: SliderStyle.InSet,
              step: 0.1,
            })
              .width('102%')
              .height(20)
              .alignSelf(ItemAlign.Center)
          }
          .height(StyleConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })

        TabContent() {
          Column() {
            Text('间距').titleStyle()
            Column() {
              Slider({
                value: $$this.vm.fontSpace,
                min: FONT_SPACE_LIST[0],
                max: FONT_SPACE_LIST[1],
                style: SliderStyle.InSet,
                step: 1,
              })
                .width('102%')
                .height(20)
            }
            .width(StyleConstants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .height(40)
            .margin({ top: StyleConstants.SPACE_12, bottom: StyleConstants.SPACE_22 })

            Text('旋转').titleStyle().margin({ bottom: StyleConstants.SPACE_14 })
            Slider({
              value: $$this.vm.fontRotate,
              min: FONT_ROTATE_LIST[0],
              max: FONT_ROTATE_LIST[1],
              style: SliderStyle.InSet,
              step: 1,
            })
              .width('102%')
              .height(20)
              .alignSelf(ItemAlign.Center)
          }
          .height(StyleConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
      }
      .barHeight(0)
      .animationDuration(0)
      .height(188)
      .scrollable(false)
    }
    .height(257)
  }
}

@Extend(Text)
function titleStyle() {
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Subtitle_M'))
  .fontWeight(FontWeight.Bold)
}