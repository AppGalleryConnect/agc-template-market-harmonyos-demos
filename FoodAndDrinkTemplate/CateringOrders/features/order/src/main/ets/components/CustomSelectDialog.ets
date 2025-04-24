import { Constants, SheetHeaderComp } from 'common/Index'

@Builder
export function CustomSelectSheetBuilder(title: Resource, list: Array<string> | Resource,
  confirm: (select: ResourceStr) => void, selected: ResourceStr = '') {
  CustomSelectSheet({
    title,
    list,
    confirm: (select: ResourceStr) => {
      confirm(select)
    },
    selected,
  })
}

@Component
struct CustomSelectSheet {
  @Prop title: Resource
  @Prop list: Array<string> | Resource = []
  @Prop selected: ResourceStr
  @State select: ResourceStr = ''
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  confirm: (select: ResourceStr) => void = () => {
  }

  aboutToAppear(): void {
    this.select = this.selected || this.list[0]
  }

  build() {
    Column() {
      SheetHeaderComp({
        title: this.title, close: () => {
          this.confirm('')
        },
      })
      Column() {
        TextPicker({ range: this.list, value: $$this.select })
          .width(Constants.FULL_SIZE)
          .disappearTextStyle({
            font: { size: $r('sys.float.Body_M') },
          })// 设置所有选项中除了最上、最下及选中项以外的文本颜色、字号、字体粗细。
          .textStyle({
            font: {
              size: $r('sys.float.Body_L'),
            },
          })// 设置选中项的文本颜色、字号、字体粗细。
          .selectedTextStyle({
            color: $r('sys.color.multi_color_09'),
            font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium },
          })
          .canLoop(false)
          .divider(null)

        Row() {
          Text($r('app.string.confirm'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.background_primary'))
            .textAlign(TextAlign.Center)
            .width(Constants.FULL_SIZE)
            .constraintSize({ maxWidth: Constants.FULL_SIZE })
            .padding({
              top: 8,
              bottom: 8,
            })
            .margin({
              top: 2,
              left: 12,
              right: 12,
              bottom: 2,
            })
        }
        .justifyContent(FlexAlign.Center)
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .borderRadius(18)
        .margin({ top: 40 })
        .backgroundColor($r('sys.color.multi_color_09'))
        .onClick(() => {
          this.confirm(this.select)
        })
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))
      .margin({ top: 8 })
      .padding({ top: 32, left: 32, right: 32 })
      .borderRadius({ topLeft: 12, topRight: 12 })

    }
    .width(Constants.FULL_SIZE)
    .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, top: 8 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
  }
}