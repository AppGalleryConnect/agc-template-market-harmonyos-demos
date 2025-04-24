import { Constants } from 'common/Index';
import { BtnType } from '../models/Model';

@Component
export struct ButtonListComp {
  @Prop btnList: Array<BtnType>;
  @Prop pos: string = 'center';
  @Prop orderId: string

  build() {
    Row({ space: 10 }) {
      ForEach(this.btnList, (item: BtnType) => {
        Column() {
          Text(item.text)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(item.color)
            .textAlign(TextAlign.Center)
            .width(56)
        }
        .borderRadius(23)
        .constraintSize({ minWidth: 72 })
        .backgroundColor(item.backgroundColor)
        .padding({
          left: 8,
          right: 8,
          top: 4,
          bottom: 4,
        })
        .onClick(() => {
          item.callback(this.orderId)
        })

      }, (item: BtnType) => JSON.stringify(item))
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.Center)
  }
}