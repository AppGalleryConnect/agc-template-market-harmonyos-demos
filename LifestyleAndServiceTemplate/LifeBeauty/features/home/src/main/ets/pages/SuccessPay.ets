import { RouterMap, RouterModule, SimpleOrderInfo, UIOrderPart } from 'utils';
import { FormItemDivider } from '../common/UIComponent';

@Builder
export function SuccessPayBuilder() {
  SuccessPay()
}

@Extend(Text)
function formLabel() {
  .fontSize(16)
  .fontWeight(500)
}

@ComponentV2
export struct SuccessPay {
  @Local orderInfo: SimpleOrderInfo = new SimpleOrderInfo();

  aboutToAppear(): void {
    const paramList: Array<SimpleOrderInfo> = RouterModule.getNavParam({ url: RouterMap.SUCCESS_PAY });
    if (paramList.length) {
      this.orderInfo = paramList[paramList.length - 1];
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row({ space: 9 }) {
            Image($r('app.media.ic_public_success')).width(26).height(26)
            Text('支付完成').fontSize(18)
          }.padding({ top: 35, bottom: 30 })

          Column({ space: 16 }) {
            this.FormCard1()
            this.FormCard2()
            this.FormCard3()
          }
        }.width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 10, right: 10 })
      .align(Alignment.Top)

    }
    .title('支付完成', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
    .onBackPressed(() => {
      RouterModule.popToName(RouterMap.MAIN);
      return true;
    })
  }

  @Builder
  FormCard1() {
    Column() {
      Row() {
        Text('姓名').formLabel()
        Blank()
        Text(this.orderInfo.contactName)
      }.width('100%').height(48)

      FormItemDivider()

      Row() {
        Text('电话').formLabel()
        Blank()
        Text(this.orderInfo.contactPhone)
      }.width('100%').height(48)
    }
    .width('100%')
    .padding({
      top: 9,
      bottom: 9,
      left: 12,
      right: 12,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  FormCard2() {
    Column({ space: 4 }) {
      UIOrderPart({ goodInfo: this.orderInfo })
    }
    .width('100%')
    .padding({
      top: 10,
      bottom: 10,
      left: 7,
      right: 10,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  FormCard3() {
    Row({ space: 10 }) {
      Text('备注').formLabel()
      Blank()
      Text(this.orderInfo.remark || '暂无')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: '70%' })
    }
    .width('100%')
    .padding({
      top: 13,
      bottom: 13,
      left: 12,
      right: 12,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Top)
  }
}
