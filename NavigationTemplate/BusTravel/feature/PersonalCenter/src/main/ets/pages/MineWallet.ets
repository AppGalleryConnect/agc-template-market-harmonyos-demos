import { RouteEntryVM } from 'common'
import { ExpendSet } from '../model/ExpendSet'
import { getDataFromJSON } from 'common';
import { PageHeader } from '../components/PageHeader';
import { CardInfoList } from 'common'

@Builder
export function MineWalletBuilder() {
  MineWallet()
}

@Component
export struct MineWallet {
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State cardInfo: CardInfoList = new CardInfoList()
  @State cardNum: number | undefined = undefined
  @State cardBalance: number | undefined = undefined
  @State userBalance: number | undefined = undefined
  @State userTotalConsumption: Array<ExpendSet> = []
  @State userBusConsumption: Array<ExpendSet> = []
  @State userRechargeConsumption: Array<ExpendSet> = []
  @State userShowConsumption: Array<ExpendSet> = []
  @State assetVisible: boolean = false

  aboutToAppear(): void {
    this.initDataSource()
    console.log('============' + JSON.stringify(this.userBusConsumption))
  }

  initDataSource() {
    this.userTotalConsumption = getDataFromJSON<ExpendSet>('PersonalCenter_MineWallet.json', this);
    this.userShowConsumption = this.userTotalConsumption
    this.userTotalConsumption.forEach((value: ExpendSet) => {
      if (value.type === '乘车消费') {
        this.userBusConsumption.push(value)
      } else {
        this.userRechargeConsumption.push(value)
      }
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.buildNanjingBus()
          this.buildCardId()
          this.buildExpendDetail()
        }
        .height('100%')
        .width('100%')
        .backgroundImageSize(ImageSize.Auto)
        .backgroundColor('#F1F3F5')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
    }
    .hideTitleBar(false)
    .title('我的钱包')
  }

  @Builder
  buildNanjingBus() {
    Text() {
      Span('XX公交  ')
      Span('NO: ')
      Span(this.cardInfo.cardID.toString())
    }
    .margin({ top: '23vp', bottom: '12vp' })
    .padding({ left: '20vp' })
    .width('100%')
    .align(Alignment.Start)
    .fontSize('14vp')
  }

  @Builder
  buildCardId() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('总资产')
              .fontColor($r('app.color.font_color_white'))
              .fontSize('14vp')
            Row() {
              Image($r('app.media.ic_public_eye'))
                .height('14.77vp')
                .width('14.77vp')
                .margin({ left: '7.6vp' })
            }
            .height(16)
            .width(16)
            .onClick(() => {
              this.assetVisible = !this.assetVisible;
            })
          }

          Text() {
            Span(' ￥')
            Span(this.assetVisible ? this.cardInfo.balance.toString() : '*****')
          }
          .fontColor($r('app.color.font_color_white'))
          .fontSize('24vp')
          .margin({ top: '14vp' })

          Text('金额（元）')
            .fontColor($r('app.color.font_color_white'))
            .fontSize('12vp')
            .margin({ top: '22vp', bottom: '9vp' })
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Image($r('app.media.icon_gift'))
            .width('24vp')
            .height('24vp')
          Text('充值送5元')
            .fontSize('12vp')
            .margin({ left: '8vp', right: '6vp' })
            .fontColor($r('app.color.system_color_green'))
        }
        .height('36vp')
        .width('101vp')
        .backgroundColor($r('app.color.background_color_white'))
        .borderRadius({ topLeft: '18vp', bottomLeft: '18vp' })
        .margin({ top: '87vp', bottom: '14vp' })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('336vp')
      .height('137vp')
      .backgroundImage($r('app.media.BG'))
      .backgroundImageSize({ width: '336vp', height: '137vp' })
      .padding({ left: '18vp', top: '12vp' })

      Row() {
        Text('累计消费（元）')
          .fontColor('#191919')
          .fontSize('12vp')
          .fontWeight(400)
          .height('20vp')
          .margin({ left: '15vp', right: '12vp' })
        Text() {
          Span('￥')
          Span(this.cardInfo.accumulatorCost.toString())
        }
        .height('20vp')
        .fontSize('12vp')
        .fontColor('#FF0000')
      }
      .padding({ top: '12vp' })
      .width('100%')
      .align(Alignment.Start)
    }
    .backgroundColor($r('app.color.background_color_white'))
    .width('336vp')
    .height('181vp')
    .borderRadius('8vp')
  }

  @Builder
  buildExpendDetail() {
    Column() {
      Row() {
        Text('流水明细')
          .fontSize('16vp')
          .fontWeight(500)
          .height('20vp')
        Row() {
          Image($r('app.media.ic_digital_conference_control'))
            .width('14vp')
            .height('14vp')
            .margin({ right: '3vp' })
          Row() {
            Text('筛选')
              .fontSize('12vp')
              .fontWeight(400)
          }
          .height('20vp')
          .bindMenu([// 支出和充值修改type展示
            {
              value: '支出',
              action: () => {
                console.info('handle Menu1 select')
                this.userShowConsumption = this.userBusConsumption
              }
            },
            {
              value: '充值',
              action: () => {
                console.info('handle Menu2 select')
                this.userShowConsumption = this.userRechargeConsumption
              }
            },
            {
              value: '全部',
              action: () => {
                console.info('handle Menu2 select')
                this.userShowConsumption = this.userTotalConsumption
              }
            },
          ])
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: '20vp',
        right: '20vp',
        top: '31vp',
        bottom: '8vp'
      })

      Column() {
        ForEach(this.userShowConsumption, (expendSetItem: ExpendSet) => {
          buildSettingItemView(expendSetItem)
        },(expendSetItem:ExpendSet)=>expendSetItem.id)
      }
      .width('94%')
      .borderRadius('8vp')
      .backgroundColor($r('app.color.background_color_white'))
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@Builder
function buildSettingItemView(item: ExpendSet) {

  Row() {
    Column() {
      Text(item.type)
        .fontSize('12vp')
        .height('20vp')
        .margin({ bottom: '2vp' })
        .width('40%')
        .textAlign(TextAlign.Start)
      Text(item.time)
        .fontSize('12vp')
        .height('20vp')
        .width('40%')
        .textAlign(TextAlign.Start)
    }

    Text() {
      Span('￥')
        .fontSize('8vp')
      Span(item.money)
        .fontSize('14vp')
    }
    .margin({ right: '14vp' })
  }
  .width('100%')
  .height('54vp')
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .padding({ left: '14vp' })

  Divider()
    .margin({ top: '7vp', left: '12vp', right: '12vp' })
    .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

}

