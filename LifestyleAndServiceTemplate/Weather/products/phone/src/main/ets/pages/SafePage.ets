import { CommonConstants, GridRowColSetting, WindowUtil } from 'lib_foundation';
import { SafeVM } from '../viewmodels/SafeVM';

@Builder
export function safePageBuilder() {
  SafePage()
}

@ComponentV2
struct SafePage {
  vm: SafeVM = new SafeVM();

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Column() {
            Scroll() {
              Column() {
                Column()
                  .layoutWeight(1)
                  .constraintSize({
                    minHeight: 24,
                    maxHeight: 136,
                  })

                Image($r('app.media.startIcon'))
                  .width(72)
                  .draggable(false)
                Text('天气应用')
                  .fontSize($r('sys.float.Title_L'))
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    top: CommonConstants.SPACE_24,
                    bottom: 2,
                  })
                Text('业务描述')
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_secondary'))
                Column()
                  .layoutWeight(3)
              }
            }
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .layoutWeight(1)

            Column() {
              Image($r('app.media.ic_security'))
                .width(16)
                .draggable(false)
              Text() {
                Span(
                  '本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
                  .fontColor($r('sys.color.font_secondary'))
                Span('XX业务与隐私的声明、权限使用说明')
                  .fontColor($r('app.color.common_theme_color'))
                  .onClick(() => {
                    this.vm.privacyClick();
                  })
                Span('。')
                  .fontColor($r('sys.color.font_secondary'))
              }
              .fontSize($r('sys.float.Caption_M'))
              .margin({
                top: CommonConstants.SPACE_16,
                bottom: 6,
              })

              Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
              Row({ space: CommonConstants.SPACE_12 }) {
                Button('取消')
                  .fontColor($r('sys.color.font_emphasize'))
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .height(40)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.vm.cancelBtnClick();
                  })
                Button('同意')
                  .height(40)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.vm.agreeBtnClick();
                  })
              }
              .padding({
                top: CommonConstants.SPACE_16,
                bottom: CommonConstants.SPACE_16,
              })
            }
            .margin({
              top: CommonConstants.SPACE_12,
            })
          }
          .constraintSize({ minHeight: CommonConstants.FULL_PERCENT })
        }
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: this.vm.pagePadding, right: this.vm.pagePadding, bottom: WindowUtil.getAvoidArea().bottom })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return true;
    })
  }
}
