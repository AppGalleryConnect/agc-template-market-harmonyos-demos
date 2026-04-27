import { baseToast, DividerTmp } from 'base_apis'
import { promptAction } from '@kit.ArkUI';
import { Operation } from '../model/Model';

@ComponentV2
export struct VipOperation {
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Local redemptionValue: string = ''
  @Event onVerifyNow: () => void = () => {
  }
  @Local vipOperationList: Operation[] = [
    {
      'title': '自动续费声明',
      'id': 'renewal',
    },
    {
      'title': '兑换会员',
      'id': 'redemption',
    },
  ]

  @Builder
  renewalTipsContent() {
    Column({ space: 16 }) {
      Text('付款：用户确认购买并签约华为支付、 支付宝周期付费账户')
      Text('取消续订：在鸿蒙系统中打开设置-华 为账号-付款与账单-订购-关闭服务')
      Text('取消续订：打开支付宝App-我的-设置- 支付设置-免密支付/自动扣款-关闭服务')
      Text('续订：华为支付、支付宝签约账户将会 在到期前24小时内扣费，扣费成功后订阅权益顺延一个订阅周期。')
    }
  }

  @Builder
  renewalTipsFooter() {
    Column({ space: 16 }) {
      Text('知道了')
        .fontColor('#C4272B')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
    }
    .onClick(() => {
      baseToast.hide()
    })
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  redemptionContent() {
    Column({ space: 16 }) {
      TextInput({ placeholder: '请输入兑换码', text: $$this.redemptionValue })
        .placeholderColor($r('sys.color.font_secondary'))
      Column({ space: 3 }) {
        Text('兑换规则说明 ')
          .fontColor($r('sys.color.font_secondary'))
        Text('1、本兑换页用于兑换万年历VIP，兑换后立即获得会员并享受相应会员权益； ')
          .fontColor($r('sys.color.font_secondary'))
        Text('2、已经付费开通万年历VIP服务的用户，在此兑换的会员时长将在付费会员到期后生效 ')
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  redemptionFooter() {
    Flex({ justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
      Column() {
        Text('取消')
          .fontSize(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Center)
      .width('50%')
      .border({
        width: { right: 1 },
        color: '#ccc',
      })
      .onClick(() => {
        baseToast.hide()
      })

      Column() {
        Text('立即验证')
          .fontColor('#C4272B')
          .fontSize(FontWeight.Medium)
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        if (!this.redemptionValue) {
          promptAction.showToast({ message: '请输入兑换码' })
          return
        }
        promptAction.showToast({ message: '兑换成功' })
        this.onVerifyNow()
        baseToast.hide()
      })
    }
  }

  @Builder
  vipOperation() {
    List() {
      ForEach(this.vipOperationList, (item: Operation) => {
        ListItem() {
          Row() {
            Text(item.title)
              .fontColor('#000000')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Image($r('app.media.chevron_right')).width(12).height(14)
          }
          .padding(16)
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
        }
        .onClick(() => {
          switch (item.id) {
            case 'renewal':
              baseToast.show({
                type: 'custom',
                hasTitle: '自动续费声明',
                customContent: () => {
                  this.renewalTipsContent()
                },
                customFooter: () => {
                  this.renewalTipsFooter()
                },
              })
              break
            case 'redemption':
              baseToast.show({
                type: 'custom',
                hasTitle: '兑换会员',
                customContent: () => {
                  this.redemptionContent()
                },
                customFooter: () => {
                  this.redemptionFooter()
                },
              })
              break
          }
        })
      }, (item: Operation) => JSON.stringify(item))
    }
    .divider(this.egDivider)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 8 })
  }

  build() {
    Column() {
      this.vipOperation()
    }
  }
}