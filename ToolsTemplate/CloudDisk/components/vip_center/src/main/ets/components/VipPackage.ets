import { BaseCell } from 'base_apis';
import { VipPackageItem } from '../model/Model';

/**
 * @usage: 用于VIP会员套餐选择场景。提供多种会员套餐展示和选择功能。
 * 关键数据结构：VipPackageItem（套餐项，包含title标题、amount金额、duration时长、amountDes金额描述）、
 * packageList（套餐列表数组）、currentIndex（当前选中索引）、currentPackage（当前选中套餐）、
 * packageChange（套餐切换回调函数，参数为VipPackageItem）。
 * 包含if逻辑：根据currentIndex判断选中状态（选中显示高亮样式，未选中显示普通样式）。
 * @layout: 使用BaseCell卡片布局。内部为横向滚动列表，每个套餐卡片垂直布局（标题、金额、描述从上到下），
 * 卡片宽度104高度124，选中卡片显示浅黄色背景和边框。
 * @constraints: packageList套餐列表不能为空，packageChange回调函数必须正确处理套餐切换，
 * currentPackage当前套餐必须有效
 * @isGen: true
 * @fileType: component
 * @zhName: VIP套餐组件
 */
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
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
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