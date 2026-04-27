import { ShareKinds } from '../model/Model'
import { secondShareList } from '../constants/Constants'
import { SheetShowVM } from '../viewModel/SheetShowVM'
import { PosterShare } from '../utils/SystemShare'

@ComponentV2
export struct SecondPosterShare {
  @Local shareList: ShareKinds[] = secondShareList
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  @Param posterShare: PosterShare = new PosterShare()
  @Event onCancel:() => void = () => {}
  build() {
    Column() {
      Row({ space: 29 }) {
        ForEach(this.shareList, (value: ShareKinds) => {
          Column({ space: 8 }) {
            Image($r(value.icon)).width(48).height(48)
            Text(value.name)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
          }
          .onClick(() => {
            switch (value.id) {
              case 'save':
                this.posterShare.saveImage(this.getUIContext())
                break;
            }
          })
        },(item: ShareKinds, index: number) => { return index + '__' + JSON.stringify(item); })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Button('取消')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .width('100%')
        .fontColor($r('sys.color.font_primary'))
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          this.onCancel()
        })
    }
    .padding({
      left: 26,
      right: 26,
      top: 32,
      bottom: 32,
    })
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}