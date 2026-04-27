@Builder
export function BuildValuationInfoPageBuilder(params: ValuationParams) {
  ValuationInfoPage({ params })
}

export interface SelectionPair {
  title: string;
  value: string
}

export interface SubmitData {
  modelName: string;
  imageSrc: ResourceStr;
  deviceType: string;
  price: number;
  selections: SelectionPair[]
}

//modelName商品名称，deviceType电脑 ('computer')&手机('phone')
export interface ValuationParams {
  modelName?: string;
  imageSrc?: ResourceStr;
  deviceType?: string;
  onBack?: () => void;
  onSubmit?: (data: SubmitData) => void
}

@ObservedV2
export class OptionItem {
  title: string
  required: boolean
  values: string[]
  @Trace selected: number = -1

  constructor(title: string, required: boolean, values: string[]) {
    this.title = title
    this.required = required
    this.values = values
  }
}

@ObservedV2
class ValuationVM {
  modelName: string = ''
  groups: OptionItem[] = []
  deviceType: string = 'phone'
  imageSrc: ResourceStr = ''

  initPhone(name: string) {
    this.modelName = name
    this.groups = [
      new OptionItem('购买渠道', false, ['专卖店', '线上']),
      new OptionItem('保修期', true, ['3天', '3个月', '1年']),
      new OptionItem('容量', true, ['12GB+1T', '12GB+512GB', '12GB+256GB']),
      new OptionItem('颜色', true, ['雪域白', '羽砂黑', '紫罗兰']),
      new OptionItem('使用情况', false, ['几乎没有使用痕迹', '中度使用痕迹', '轻微使用痕迹', '明显使用痕迹']),
      new OptionItem('机身外观', false, ['99新', '95新', '9新', '8新']),
      new OptionItem('屏幕显示', false, ['全面屏', '曲面屏', '大弧屏', '小弧屏']),
      new OptionItem('维修历史', false, ['无', '有']),
      new OptionItem('功能情况', false,
        ['功能完好，无维修更换，电池100，保修>100天', '功能基本完好，无维修更换，电池80%，性价比之王']),
    ]
  }

  initComputer(name: string) {
    this.modelName = name
    this.groups = [
      new OptionItem('内存', true, ['32G内存+2T', '32G内存+1T', '32G内存+512G', '32G内存+256G']),
      new OptionItem('硬盘类型', true, ['固态', '机械']),
      new OptionItem('处理器', true, ['麒麟', '骁龙', '英特尔']),
      new OptionItem('机身外观', false, ['99新', '95新', '9新', '8新']),
      new OptionItem('屏幕显示', false, ['2880*1800', '2560*1600', '2560*1440', '1920*1080']),
      new OptionItem('维修历史', false, ['无', '有']),
      new OptionItem('功能情况', false,
        ['功能完好，无维修更换，电池100，保修>100天', '功能基本完好，无维修更换，电池80%，性价比之王']),
    ]
  }
}

@ComponentV2
export struct ValuationInfoPage {
  @Param params: ValuationParams = {}
  @Local vm: ValuationVM = new ValuationVM()

  aboutToAppear(): void {
    this.vm.deviceType = (this.params?.deviceType ?? 'phone')
    this.vm.imageSrc = this.params?.imageSrc ?? ''
    const name = this.params?.modelName ?? (this.vm.deviceType === 'computer' ? 'HUAWEI NBOOK' : 'HUAWEI Mate 60 Pro')
    if (this.vm.deviceType === 'computer') {
      this.vm.initComputer(name)
    } else {
      this.vm.initPhone(name)
    }
  }

  getColumns(): string {
    return this.vm.deviceType === 'computer' ? '1fr 1fr' : '1fr 1fr 1fr'
  }

  getColumnsFor(item: OptionItem): string {
    if (item.values.length >= 4) {
      return '1fr 1fr 1fr 1fr'
    }
    return this.getColumns()
  }

  getWidth(values: string[]) {
    if (values.length === 3) {
      return '30%'
    } else if (values.length === 4) {
      return '45%'
    } else {
      return '45%'
    }
  }

  @Builder
  sectionHeader(title: string, required: boolean) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0,0,0,1)')
      if (required) {
        Text('*')
          .fontSize(16)
          .fontColor('rgba(255, 75, 75, 1)')
          .margin({ left: 2 })
      }
    }
    .width('100%')
    .height(24)
    .margin({ bottom: 14 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  chipItem(item: OptionItem, idx: number, val: string) {
    Row() {
      Text(val)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor(item.selected === idx ? 'rgba(255, 75, 75, 1)' : 'rgba(0,0,0,0.85)')
        .maxLines(1)
    }
    .padding({
      left: 8,
      right: 8,
      top: 4,
      bottom: 4
    })
    .height(44)
    .constraintSize({ minWidth: this.getWidth(item.values) })
    .padding(item.values.length === 2 ? { left: 16, right: 16 } : {})
    .margin({ right: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor(item.selected === idx ? 'rgba(255, 75, 75, 0.12)' : 'rgba(0,0,0,0.05)')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      item.selected = idx
    })
  }

  @Builder
  optionGroup(item: OptionItem, index: number) {
    Column() {
      this.sectionHeader(item.title, item.required)
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(item.values, (v: string, i: number) => {
          this.chipItem(item, i, v)
        }, (v: string, i: number) => `${index}_${i}`)
      }
      .width('100%')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  getSelectedPairs(): SelectionPair[] {
    const list: SelectionPair[] = []
    for (let i = 0; i < this.vm.groups.length; i++) {
      const g = this.vm.groups[i]
      if (g.selected >= 0) {
        list.push({ title: g.title, value: g.values[g.selected] })
      }
    }
    return list
  }

  computePrice(): number {
    let price = this.vm.deviceType === 'computer' ? 6088 : 3210
    const pairs = this.getSelectedPairs()
    for (let p of pairs) {
      if (p.title.includes('容量') || p.title.includes('内存')) {
        if (p.value.includes('1T') || p.value.includes('512')) {
          price += 200
        }
        if (p.value.includes('256')) {
          price -= 150
        }
      }
      if (p.title.includes('维修历史') && p.value === '有') {
        price -= 300
      }
      if (p.title.includes('使用情况')) {
        if (p.value.includes('明显')) {
          price -= 300
        } else if (p.value.includes('中度')) {
          price -= 150
        }
      }
      if (p.title.includes('机身外观')) {
        if (p.value.includes('99新')) {
          price += 200
        } else if (p.value.includes('8新')) {
          price -= 200
        }
      }
    }
    return price < 0 ? 0 : price
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text(this.vm.modelName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(0, 0, 0, 0.71)')
              .padding({ left: '4%', right: '4%', top: 12 })
              .width('100%')
              .textAlign(TextAlign.Start)

            Column({ space: 12 }) {
              ForEach(this.vm.groups, (it: OptionItem, idx: number) => {
                this.optionGroup(it, idx)
              }, (it: OptionItem, idx: number) => `${idx}`)
            }
            .padding({
              left: 12,
              right: 12,
              bottom: 12,
              top: 28
            })
          }
          .width('92%')
          .borderRadius(12)
          .backgroundColor(Color.White)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 1
          })
          .margin({ left: '4%', right: '4%' })
        }
        .width('100%')
      }
      .padding({ top: 12 })
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        Button('确认')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('rgba(255, 75, 75, 1)')
          .borderRadius(24)
          .height(48)
          .width('90%')
          .onClick(() => {
            const payload: SubmitData = {
              modelName: this.vm.modelName,
              imageSrc: this.vm.imageSrc,
              deviceType: this.vm.deviceType,
              price: this.computePrice(),
              selections: this.getSelectedPairs()
            }
            this.params.onSubmit && this.params.onSubmit(payload)
          })
      }
      .width('100%')
      .height(72)
      .margin({ bottom: 28 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(242,243,245,1)')

  }
}
