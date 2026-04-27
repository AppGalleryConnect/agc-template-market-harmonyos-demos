import { PopViewUtil, RouterMap, routerStack, WindowUtil } from 'lib_foundation'
import { CommonSymbol } from './CommonSymbol'
import { ContainerColumn } from './ContainerColumn'
import { call } from '@kit.TelephonyKit'
import { CommonButton } from './CommonButton'

@Builder
function buildCustomServiceSheet() {
  Column() {
    ContainerColumn() {
      buildCustomServiceItem($r('sys.symbol.phone'), '电话客服', () => {
        PopViewUtil.openSheet(
          wrapBuilder(buildMakeCallComponent),
          {
            title: { title: '联系客服' },
            dragBar: true,
            preferType: SheetType.CENTER,
            height: 260,
          },
        )
      })

      Divider()

      buildCustomServiceItem($r('sys.symbol.service'), '在线客服', () => {
        routerStack.pushPath({
          name: RouterMap.USER_CUSTOM_SERVICE,
        })
        PopViewUtil.closeAllSheet()
      })
    }
  }
  .padding($r('app.float.space_l'))
}

@Builder
function buildCustomServiceItem(icon: Resource, label: string, callback?: () => void) {
  Row() {
    CommonSymbol({
      src: icon,
    })
      .margin({ right: $r('app.float.space_m') })
    Text(label)
      .layoutWeight(1)
      .fontWeight(FontWeight.Medium)
    Image($r('app.media.ic_arrow_right')).width(24)
  }
  .onClick(() => {
    callback?.()
  })
  .width($r('app.string.size_percent_full'))
  .margin({
    top: $r('app.float.space_m'),
    bottom: $r('app.float.space_m'),
  })
}

@Builder
export function buildMakeCallComponent() {
  Column() {
    ContainerColumn() {
      Text('012****7890')
        .fontSize(18)
        .fontColor($r('app.color.font_color_level1'))
        .lineHeight(30)
        .halfLeading(true)

      CommonButton({
        icon: $r('app.media.ic_phone'),
        title: '一键拨号',
        handleClick: () => {
          if (canIUse('SystemCapability.Applications.Contacts')) {
            call.makeCall('01234567890')
              .catch(() => {
                WindowUtil.toast('跳转拨号界面失败')
              })
              .finally(() => {
                PopViewUtil.closeAllSheet()
              })
          }
        },
      })

      Blank().height($r('app.float.space_m'))

      CommonButton({
        title: '取消',
        bgColor: $r('app.color.background_color_button_grey'),
        fontColor: $r('sys.color.font_primary'),
        handleClick: () => {
          PopViewUtil.closeSheet()
        },
      })
    }
  }
  .width('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .padding($r('app.float.space_l'))
}

export class CustomServiceSheet {
  public static show() {
    PopViewUtil.openSheet(
      wrapBuilder(buildCustomServiceSheet),
      {
        title: { title: '联系客服' },
        preferType: SheetType.CENTER,
        dragBar: true,
        height: 260,
        backgroundColor: $r('app.color.background_color_grey'),
      },
    )
  }
}