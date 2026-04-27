import { ShareKinds } from '../model/Model'
import { firstShareList } from '../constants/Constants'
import { SheetShowVM } from '../viewModel/SheetShowVM'
import { componentSnapshot } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { PosterShare } from '../utils/SystemShare'

@Builder
export function FirstPosterShareBuilder() {
  FirstPosterShare()
}

@ComponentV2
export struct FirstPosterShare {
  @Local shareList: ShareKinds[][] = firstShareList
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  @Param posterShare: PosterShare = new PosterShare()

  build() {
    List() {
      ForEach(this.shareList, (item: ShareKinds[]) => {
        ListItem() {
          Row({ space: 29 }) {
            ForEach(item, (value: ShareKinds) => {
              Column({ space: 8 }) {
                Image($r(value.icon)).width(48).height(48)
                Text(value.name)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_primary'))
              }
              .onClick(() => {
                switch (value.id) {
                  case 'create_poster':
                    this.shareShowVM.setFirstShareShow(false)
                    this.shareShowVM.setSharePpShow(true)
                    this.getUIContext()
                      .getComponentSnapshot()
                      .get('Screenshot', ((err: Error, pixmap: image.PixelMap) => {
                        if (err) {
                          return
                        }
                        this.shareShowVM.setPosterImage(pixmap)
                      }))
                    break
                  case 'system_share':
                    this.posterShare.share(this.getUIContext())
                    break
                  case 'copy_link':
                    this.posterShare.copy(this.getUIContext())
                    break
                }
              })
            },(item: ShareKinds, index: number) => { return index + '__' + JSON.stringify(item); })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ top: 30 })
        }
      },(item: ShareKinds[], index: number) => { return index + '__' + JSON.stringify(item); })
      ListItem() {
        Button('取消')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width('100%')
          .fontColor($r('sys.color.font_primary'))
          .padding({ top: 8, bottom: 8 })
          .margin({ bottom: 16, top: 16 })
          .onClick(() => {
            this.shareShowVM.setFirstShareShow(false)
          })
      }
    }
    .padding({ left: 16, right: 16 })
  }
}