import { authorisedPayMethod, PayMethod, userPayMethod } from 'commonlib'

@CustomDialog
export struct defaultPayMethodDialog{
  controller?:CustomDialogController
  cancel:()=>void=()=>{
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text('请选择默认的支付方式').margin({top:10})

      ForEach(authorisedPayMethod,(pay:PayMethod,index:number)=>{
        Column() {
          Row() {
            Row() {
              Image(pay.imageDefault)
                .width(30)
                .height(30)
                .margin({right:5})
              Text(pay.text)
                .fontSize(14)
            }

            Radio({ value: 'Radio' + index, group: 'radioGroup' })
              .checked(index === 0 ? true : false)
              .radioStyle()
              .onClick(()=>{
                userPayMethod.defaultPayMethod = pay
                let temp = authorisedPayMethod[0]
                authorisedPayMethod[0] = authorisedPayMethod[index]
                authorisedPayMethod[index] = temp
                this.controller?.close()
              })
          }
          .margin({ top: 20, bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          Divider()
        }
      }, (item: string, index: number) => item + index)

    }
    .width('90%')
    .alignItems(HorizontalAlign.Center)
  }
}