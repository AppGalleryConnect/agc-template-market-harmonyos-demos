import { BaseCell } from 'base_apis';
import { VipPackageItem } from '../model/Model';

@ComponentV2
export struct VipPackage {
  @Local currentIndex: number = 0
  @Param userName: string = ''
  @Param avatar: ResourceStr = ''
  @Param isVip: boolean = false
  @Param currentPackage: VipPackageItem = new VipPackageItem()
  @Event packageChange: (vipPackage: VipPackageItem) => void = () => {
  }
  private packageList: VipPackageItem[] = [{
    title: '连续包月',
    amount: 29,
    duration: 'month',
    amountDes: '每天仅需0.8元',
  }, {
    title: '会员季卡',
    amount: 118,
    duration: 'halfYear',
    amountDes: '低至0.93元/天',
  }, {
    title: '会员月卡',
    amount: 39,
    duration: 'month',
    amountDes: '畅享VIP权益31天',
  }, {
    title: '会员终身卡',
    amount: 299,
    duration: 'perpetual',
    amountDes: '畅享全部权益',
  }]

  @Builder
  vipPackageCard(item: VipPackageItem, index: number) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, direction: FlexDirection.Column }) {
      Column({ space: 16 }) {
        Text(item.title)
          .fontSize(14)
          .fontColor('#000000')
          .fontWeight(FontWeight.Medium)
        Text() {
          Span('¥')
            .fontSize(10)
          Span(`${item.amount.toString()}`)
            .fontSize(14)
        }
        .fontColor(this.currentIndex === index ? '#7E4D12' : $r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(item.amountDes)
          .fontSize(12)
          .fontColor(this.currentIndex === index ? '#562E15' : $r('sys.color.font_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F8E6CE')
      .padding({ top: 4, bottom: 4 })
    }
    .border({
      width: this.currentIndex === index ? 2 : 1,
      color: this.currentIndex === index ? '#F8E6CE' : '#F3F3F3',
    })
    .backgroundColor(this.currentIndex === index ? '#FFFCF2' : $r('sys.color.background_primary'))
    .borderRadius(8)
    .width(104)
    .height(124)
    .clip(true)
    .margin({ top: 8 })
    .onClick(() => {
      this.currentIndex = index
      this.packageChange(item)
    })
  }

  @Builder
  vipPackageBuilder() {
    List({ space: 8 }) {
      ForEach(this.packageList, (item: VipPackageItem, index: number) => {
        ListItem() {
          this.vipPackageCard(item, index)
        }
      },(item: VipPackageItem) => item.title)
    }
    .height(130)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }

  build() {
    Column() {
      BaseCell({
        cellTitle: '会员套餐',
        customBuilderParam: () => this.vipPackageBuilder(),
      })
    }
  }
}