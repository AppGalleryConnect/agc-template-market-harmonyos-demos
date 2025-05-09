import { RouteEntryVM } from 'common'

@Component
export struct PageHeader {
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State name: string = '';

  build() {
    Row() {
      Polyline({ width: 11, height: 19 })
        .points([[11, 0], [0, 9.5], [11, 19]])
        .fillOpacity(0)
        .stroke($r('sys.color.black'))
        .strokeWidth('1px')
        .onClick(() => {
          this.vm.pop()
        })
        .margin({ right: '18vp' })

      Text(this.name)
        .fontSize(20)
        .fontColor($r('sys.color.black'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('60vp')
    .padding({ left: '24.5vp' })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.white'))
  }
}