import { AddressInfo } from 'lib_network'
import { ContainerColumn } from './ContainerColumn'
import { NavTitleBar } from './NavTitleBar'

export interface UpdateAddressPageOptions {
  originalAddress?: AddressInfo
  onSelectAddress: (callback: (address: AddressInfo) => void) => void
  onSubmit: (newAddress: AddressInfo) => void
}

@Builder
export function buildUpdateAddressPage() {
  UpdateAddressPage()
}

@ComponentV2
export struct UpdateAddressPage {
  @Local
  originalAddress?: AddressInfo = undefined
  @Local
  newAddress?: AddressInfo = undefined
  private onSelectAddress: (callback: (address: AddressInfo) => void) => void = () => {}
  private onSubmit: (newAddress: AddressInfo) => void = () => {}

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          NavTitleBar({
            title: '修改地址',
            showBackBtn: true,
          })
          Column({ space: 12 }) {
            Text('原地址')
              .fontSize($r('app.float.font_size_18'))
              .fontColor($r('app.color.font_color_level1'))
            ContainerColumn() {
              this.buildAddressDisplay(this.originalAddress)
            }

            Row() {
              Text('新地址')
                .fontSize($r('app.float.font_size_18'))
                .fontColor($r('app.color.font_color_level1'))

              Button('选择地址')
                .controlSize(ControlSize.SMALL)
                .backgroundColor($r('app.color.background_color_primary'))
                .fontColor($r('app.color.theme_color'))
                .border({ width: 1, color: $r('app.color.theme_color') })
                .onClick(() => {
                  this.onSelectAddress((address: AddressInfo) => {
                    this.newAddress = address
                  })
                })
            }
            .width($r('app.string.size_percent_full'))
            .justifyContent(FlexAlign.SpaceBetween)

            if (this.newAddress) {
              ContainerColumn() {
                this.buildAddressDisplay(this.newAddress)
              }
            }

            Blank()
            Button('提交修改')
              .type(ButtonType.Normal)
              .borderRadius($r('app.float.border_radius_capsule'))
              .backgroundColor($r('app.color.theme_color'))
              .enabled(Boolean(this.newAddress))
              .width($r('app.string.size_percent_full'))
              .onClick(() => {
                if (this.newAddress) {
                  this.onSubmit(this.newAddress)
                }
              })
          }
          .padding($r('app.float.space_l'))
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width($r('app.string.size_percent_full'))
        .height($r('app.string.size_percent_75'))
        .backgroundColor($r('app.color.background_color_grey'))
        .borderRadius({
          topLeft: $r('app.float.border_radius_xl'),
          topRight: $r('app.float.border_radius_xl'),
        })
        .padding({ top: $r('app.float.space_m') })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .height($r('app.string.size_percent_full'))
      .width($r('app.string.size_percent_full'))
      .backgroundColor($r('sys.color.mask_fourth'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .align(Alignment.Bottom)
    .onReady((context) => {
      const param = context.pathInfo.param as UpdateAddressPageOptions | undefined
      if (param) {
        this.originalAddress = param.originalAddress
        this.onSelectAddress = param.onSelectAddress
        this.onSubmit = param.onSubmit
      }
    })
  }

  @Builder
  buildAddressDisplay(addr?: AddressInfo) {
    Row() {
      Image($r('app.media.position'))
        .width(24)
        .height(24)
        .margin({ right: $r('app.float.space_m') })
      Column({ space: 4 }) {
        Text(addr?.address ?? '')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text() {
          Span(addr?.name ?? '')
          Span(' ').letterSpacing(8)
          Span(addr?.cellphone ?? '')
        }
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level3'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ right: $r('app.float.space_m') })
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.Start)
  }
}
