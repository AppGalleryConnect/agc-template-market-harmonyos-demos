import { InformationInfoVM } from '../viewModels/InformationInfoVM'

@Builder
export function InformationInfoBuilder() {
  InformationInfo()
}

@ComponentV2
struct InformationInfo {
  vm: InformationInfoVM = InformationInfoVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text(this.vm.notice?.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Image(this.vm.notice?.img)
            .width('100%')
        }
        .padding({ top: 8, left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('资讯详情')
    .onShown(() => {
      this.vm.init()
    })
  }
}