import { Constants } from '../common/Constants';

const storageWidget = new LocalStorage();


@Extend(Text)
function textFancy() {
  .width(Constants.FULL_PERCENT)
  .fontSize(16)
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(700)
}

@Entry(storageWidget)
@Component
struct WidgetCard2x4Card {
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';
  @LocalStorageProp('formDimension') formDimension: number = 3;
  @LocalStorageProp('isLogin') isLogin: boolean = false;
  @LocalStorageProp('orderNo') orderNo: string = '';
  @LocalStorageProp('senderCity') senderCity: string = '';
  @LocalStorageProp('receiverCity') receiverCity: string = '';
  @LocalStorageProp('logistics') logistics: string = '';

  postFormCard(routeUrl: string, orderNo: string) {
    postCardAction(this, {
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        source: 'FormCard',
        pageUrl: routeUrl,
        extraParam: orderNo,
      },
    });
  }

  build() {
    Column() {
      this.headerBuilder()

      Column() {
        if (this.isLogin) {
          if (this.orderNo) {
            Text(`${this.senderCity} - ${this.receiverCity}`)
              .textFancy()
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 8 })
            Text(this.logistics)
              .width(Constants.FULL_PERCENT)
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(400)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 8, bottom: 8 })

            this.commonBtnView('查询进度', Constants.ORDER_INFO_PAGE, FlexAlign.End)
          } else {
            Text('暂无物流信息')
              .textFancy()
              .margin({ top: 8, bottom: 20 })

            this.commonBtnView('去寄件', Constants.EXPRESS_PAGE, FlexAlign.Center)
          }
        } else {
          Text('当前未登录')
            .textFancy()
            .textAlign(TextAlign.Center)
          Text('不登录看不到信息~')
            .width(Constants.FULL_PERCENT)
            .textAlign(TextAlign.Center)
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(400)
            .margin({ top: 8, bottom: 20 })

          this.commonBtnView('去登录', Constants.QUICK_LOGIN_PAGE, FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .width(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding(Constants.PADDING_M)
    .backgroundImage($r('app.media.widget_card_bg'))
    .backgroundImageSize({ width: '100%', height: '100%' })
  }

  @Builder
  headerBuilder() {
    Row({ space: 8 }) {
      Image($r('app.media.startIcon')).width(20).height(20)
      Text('物流信息')
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(400)
        .layoutWeight(1)
    }
    .width(Constants.FULL_PERCENT)
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
      });
    })
  }

  @Builder
  commonBtnView(label: string, routeUrl: string, flexAlign: FlexAlign) {
    Row() {
      Button(label)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_emphasize'))
        .width(126)
        .height(28)
        .backgroundColor(Color.White)
        .onClick(() => {
          this.postFormCard(routeUrl, this.orderNo)
        })
    }
    .width(Constants.FULL_PERCENT)
    .justifyContent(flexAlign)
  }
}