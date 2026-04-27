import { BankCard, Constants, RouterMap } from 'common'
import { NavPageInfo, phoneRouterControl } from 'oh_router'
import { promptAction } from '@kit.ArkUI'
import { MyBankCardPageVM } from '../viewmodel/MyBankCardPageVM'
import { MyBankCardUnbindDialog } from '../views/MyBankCard/MyBankCardUnbindDialog'
import { AddBankCardPageBuilder } from './AddBankCardPage'

/**
 * @usage: 我的银行卡页面，用于展示用户绑定的银行卡列表，支持添加和解绑银行卡。
 * @layout: 采用垂直布局（Column），顶部为标题栏，下方为银行卡列表卡片。
 * @isGen: true
 * @fileType: page
 * @zhName: 我的银行卡页面
 * @subPage: AddBankCardPage
 * @component: MyBankCardUnbindDialog
 * @image: screenshots/person/myBankCard.png
 */
@Builder
export function BuildMyBankCardPage(): void {
  MyBankCardPage()
}

@ComponentV2
export struct MyBankCardPage {
  private logTag: string = 'MyBankCardPage'
  // 操作对象VM
  @Local myBankCardVM: MyBankCardPageVM = MyBankCardPageVM.instance

  // 标题区域
  @Builder
  buildTitleLayout() {
    Row() {
      Image($r('app.media.back')).width(40).height(40).margin({ left: 17 })
        .onClick(() => {
          phoneRouterControl.popPage()
        })

      Text('我的银行卡').fontSize(20).fontColor('rgba(0, 0, 0, 1)').margin({ left: 5 })

    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('rgba(255, 255, 255, 1)')
  }

  // 银行卡元素布局
  @Builder
  buildBankCardItem(item: BankCard, index: number) {
    Row() {
      RelativeContainer() {
        Image(item.bankIcon).width(28).height(28)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({ left: 8, top: 9 })

        Text(item.cardNo)
          .height(16)
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 1)')
          .fontWeight(FontWeight.Regular)
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
          .margin({ left: 8, bottom: 7 })

        Text('解绑')
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 1)')
          .fontWeight(FontWeight.Medium)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .margin({ top: 9, right: 12 })
          .onClick(() => {
            promptAction.openCustomDialog({
              builder: () => {
                this.unbindCustomDialog(index)
              },
              alignment: DialogAlignment.Center,
              width: '90%'
            })
              .then((id) => {
                this.myBankCardVM.closeUnbindId = id
              })
          })
      }
      .layoutWeight(1)
      .height('100%')
      .margin({ left: 12, right: 12 })
      .borderRadius(8)
      .linearGradient({
        angle: 90, // 渐变角度（0点方向顺时针）
        colors: [
          [item.rotateColor[0], 0.0], // 起始颜色及位置
          [item.rotateColor[1], 1.0]// 结束颜色及位置
        ]
      })
    }.height(80).width('100%').margin({ bottom: 8 })

  }

  @Builder
  unbindCustomDialog(index: number) {
    MyBankCardUnbindDialog({
      vm: this.myBankCardVM,
      deleteId: index
    })
  }

  // 银行卡列表
  @Builder
  buildContent() {
    Column() {
      Column() {
        // 我的标题“我的卡”
        Row() {
          Row() {
            Text('我的卡').fontSize(14).fontColor('rgba(0, 0, 0, 1)').fontWeight(FontWeight.Medium)

            Text(`（共${this.myBankCardVM.bankCardTool.bankCards.length}张）`)
              .fontSize(10)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .margin({ top: 4 })
          }
          .margin({ left: 12 })

          Row() {
            Image($r('app.media.ic_public_add_normal')).width(12).height(12)

            Text('添加卡').fontSize(12).fontColor('rgba(0, 0, 0, 1)').margin({ left: 5 })
          }.margin({ right: 12 })
          .onClick(() => {
            const orderPage: NavPageInfo = {
              pageName: RouterMap.ADD_BANK_CARD_PAGE,
              builder: wrapBuilder(AddBankCardPageBuilder),
            }
            phoneRouterControl.jumpPage(orderPage)
          })
        }.width('100%').height(44).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

        // 银行卡列表
        List() {
          ForEach(this.myBankCardVM.bankCardTool.bankCards, (item: BankCard, index: number) => {
            ListItem() {
              this.buildBankCardItem(item, index)
            }
          }, (item: BankCard, index: number) => JSON.stringify(item) + index)
        }.width('100%').padding({ bottom: 6 }).layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }.width('100%').border({ radius: 16 }).backgroundColor('rgba(255, 255, 255, 1)')
    }.width('100%').layoutWeight(1).padding({ top: 12, left: 16, right: 16 }).backgroundColor('rgba(245, 245, 245, 1)')
  }

  build() {
    NavDestination() {
      // 标题区域
      this.buildTitleLayout()

      // 内容区域
      this.buildContent()

    }
    .hideTitleBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
