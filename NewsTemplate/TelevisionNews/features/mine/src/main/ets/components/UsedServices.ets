import { BreakpointNameEnum, BreakpointType, Constants, RouterMap, RouterUtils } from 'lib_common'

@ComponentV2
export struct UsedServices {
  @Param breakpoint: string = ''
  @Local callTelSheet: boolean = false

  build() {
    Column() {
      Text('常用服务')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: 12 })
      List() {
        ListItem() {
          Row() {
            Row() {
              SymbolGlyph($r('sys.symbol.plus_bookmark'))
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary'), '#000000'])
              Text('我的订阅')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 16 })
            }

            SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(24).fontColor([$r('sys.color.icon_fourth'), '#000000'])
          }
          .width(Constants.FULL_SIZE)
          .padding({ top: 16, bottom: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.SETTING_SUBSCRIBE)
          })
        }

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_public_edit'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
                .fillColor($r('sys.color.font_primary'))
              Text('意见反馈')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 16 })
            }

            SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(24).fontColor([$r('sys.color.icon_fourth'), '#000000'])
          }
          .width(Constants.FULL_SIZE)
          .padding({ top: 16, bottom: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.FEEDBACK_SUBMIT_PAGE)
          })
        }

      }
      .padding({
        left: 12,
        right: 12,
        top: 4,
        bottom: 4,
      })
      .margin({ top: 8 })
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(20)
      .divider({ strokeWidth: 1, startMargin: 40 })
      .lanes(new BreakpointType<number>({
        [BreakpointNameEnum.SM]: 1,
        [BreakpointNameEnum.MD]: 2,
        [BreakpointNameEnum.LG]: 2,
        [BreakpointNameEnum.XL]: 2,
      }).getValue(this.breakpoint), 12)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .enableScrollInteraction(false)
    }.margin({ top: 24 }).alignItems(HorizontalAlign.Start)
  }
}