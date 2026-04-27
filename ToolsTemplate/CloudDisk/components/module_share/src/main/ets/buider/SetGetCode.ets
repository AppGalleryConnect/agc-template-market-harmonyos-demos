import { PopViewUtils } from '../utils/PopViewUtils'
import { RandomGenerator } from '../utils/RandomGenerator'
import { RowType } from '../componts/RowType'
import { TopHeader } from '../componts/TopHeader'
import { ShreGetCodeParam} from '../model/Model'

@Builder
export function SetGetCodeBuilder(param: ShreGetCodeParam) {
  SetGetCode({
    params: param
  })
}

@ComponentV2
struct SetGetCode {
  @Local selectStatus: number = 0
  @Local content: string = ''
  @Require @Param params: ShreGetCodeParam

  build() {
    Column() {
     TopHeader({title:$r('app.string.set_code')})

      RowType({ title: $r('app.string.random_create_code'), isSelect: this.selectStatus === 1 ? true : false })
        .margin({ top: 24 })
        .onClick(() => {
          this.selectStatus = 1
          let value = RandomGenerator.generateSecureRandomString(4)
          if (this.params.blockContent && value.length === 4) {
            this.params.blockContent(value)
            PopViewUtils.closeSheet()
          }
        })
      RowType({ title: $r('app.string.define_code'), isSelect: this.selectStatus === 2 ? true : false })
        .onClick(() => {
          this.selectStatus = 2
        })
      if (this.selectStatus === 2) {
        Column({ space: 12 }) {
          Row() {
            TextInput({ placeholder: $r('app.string.input_code'), text: this.content })
              .placeholderColor($r('sys.color.font_secondary'))
              .placeholderFont({
                size: $r('sys.float.Body_L'),
                weight: 400
              })
              .maxLength(4)
              .layoutWeight(1)
              .fontSize(14)
              .fontWeight(400)
              .height(44)
              .fontColor(Color.Black)
              .type(InputType.Normal)
              .backgroundColor($r('sys.color.background_secondary'))
              .onChange((value: string) => {
                this.content = value
              })
            Text($r('app.string.sure'))
              .font({
                size: 16,
                weight: 150
              })
              .onClick(() =>{
                if (this.content.length>0 &&  this.params.blockContent) {
                  this.params.blockContent(this.content)
                  PopViewUtils.closeSheet()
                }
              })
              .fontColor('#2FAFFF')
              .textAlign(TextAlign.End)
              .layoutWeight(0.5)
              .width('100%')
              .height(40)
          }
          .borderRadius(12)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
        }
        .margin({ top: 12 })
      }
    }
    .backgroundColor(Color.White)
    .padding(24)
  }
}
