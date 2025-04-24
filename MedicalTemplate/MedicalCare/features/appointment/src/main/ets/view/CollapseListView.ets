/**
 * 可以折叠子项的列表
 */
@ComponentV2
export struct CollapseListView {
  @Param @Once listTitle: string = ''
  @Param @Once data: string[] = []
  @Local collapse: boolean = true
  @Local rotateAngle: number = 0
  @Param onItemClick?: (index: number) => void = () => {
  }

  build() {
    Column() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Text(this.listTitle)
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Image($r('app.media.ic_chevron_down'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .rotate({ angle: this.rotateAngle })
      }
      .padding({
        top: 14,
        bottom: 14
      })
      .onClick(() => {
        animateTo({
          duration: 300
        }, () => {
          this.collapse = !this.collapse
          this.rotateAngle = (this.rotateAngle + 180) % 360
        })
      })

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .strokeWidth(0.5)
        .visibility(this.collapse ? Visibility.None : Visibility.Visible)

      Column() {
        List() {
          ForEach(this.data, (item: string, index: number) => {
            ListItem() {
              Column() {
                Text(`${item}`)
                  .fontSize(14)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .width('100%')
                  .padding({
                    top: 14,
                    bottom: 14,
                    left: 9
                  })
                  .visibility((!this.collapse) ? Visibility.Visible : Visibility.None)
              }
            }
            .onClick(() => {
              this.onItemClick?.(index)
            })
          }, (item: number) => JSON.stringify(item))
        }
        .divider({
          strokeWidth: (!this.collapse) ? 0.5 : 0,
          color: $r('sys.color.ohos_id_color_list_separator')
        })
        .padding({
          left: 17
        })
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }
}