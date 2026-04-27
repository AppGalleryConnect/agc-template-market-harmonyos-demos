import { BankCard, connectValuationStore, Constants, RouterMap, TCLogger, ValuationStore } from 'common';
import { NavPageInfo, phoneRouterControl, RouterPopInfo } from 'oh_router';
import { TimeSelect } from 'module_time_select';
import {
  AddressManagerPageBuilder,
  AddressManagerPageVM,
  BuildMyOrderPage,
  MyOrderPageVM,
  OrderItem,
  OrderLocationInfo,
  OrderMasterInfo
} from 'person';
import { RecycleNoticePageBuilder } from './RecycleNoticePage';
import { AddBankCardPageBuilder } from './AddBankCardPage';

interface SelectionPair {
  title: string;
  value: string
}

interface OrderParams {
  modelName: string;
  imageSrc?: ResourceStr;
  deviceType?: string;
  price?: number;
  selections?: SelectionPair[]
}

interface BankCardPopInfo { popResult?: BankCard }

interface ModifyAppointmentPayload {
  selectedPickupDate?: number
  selectedPickupRegion?: string
  selectedPickupDetail?: string
}

interface AddressLike {
  street?: string
  detail?: string
  address?: string
  name?: string
  phone?: string
}

interface ProtocolParams {
  content: string
  isSheet: boolean
}

@ObservedV2
class OrderVM {
  modelName: string = ''
  @Trace imageSrc: ResourceStr = ''
  price: number = 0
  deviceType: string = 'phone'
  @Trace selectedIndex: number = 0
  @Trace selectedAgreement: boolean = false
  @Trace showPriceSheet: boolean = false
  deviceAttrs: SelectionPair[] = [
    { title: '购买渠道', value: '专卖店' },
    { title: '保修期', value: '30天' },
    { title: '容量', value: '12GB+1T' },
    { title: '颜色', value: '雪域白' }
  ]
  functionStatus: SelectionPair[] = [
    { title: '使用情况', value: '几乎没有使用痕迹' },
    { title: '机身外观', value: '99新' },
    { title: '屏幕显示', value: '全曲面' },
    { title: '维修记录', value: '无' },
    { title: '功能情况', value: '功能完好，无维修更换，电池100，保修>100天' }
  ]
}

@Builder
export function OrderSubmitPageBuilder(params: object) {
  OrderSubmitPage({ params: params as OrderParams })
}

@ComponentV2
export struct OrderSubmitPage {
  @Param params: OrderParams = {
    modelName: '',
    imageSrc: '',
    deviceType: 'phone',
    price: 0
  }
  @Local vm: OrderVM = new OrderVM()
  @Local store: ValuationStore = connectValuationStore()
  @Local date: Date | null = null;
  @Local selectedRegion: string = ''
  @Local selectedDetail: string = ''

  @Computed
  get computedAddrText() {
    const addr = `${this.store.selectedPickupRegion || ''}${this.store.selectedPickupDetail || ''}`
    return addr && addr.length > 0 ? addr : '请选择地址'
  }

  @Computed
  get getTimeText() {
    if (this.store.selectedPickupDate) {
      return this.formatDate(new Date(this.store.selectedPickupDate));
    }
    return '请选择上门时间';
  }

  @Computed
  get getTimeTextOpacity() {
    if (this.store.selectedPickupDate) {
      return 1;
    }
    return 0.4;
  }

  // 获取当前商品的图标信息
  @Computed
  get getImageUrl() {
    return this.vm.imageSrc
  }

  private formatDate(d: Date): string {
    const pad = (n: number) => `${n < 10 ? '0' : ''}${n}`
    const m = pad(d.getMonth() + 1)
    const day = pad(d.getDate())
    const hh = pad(d.getHours())
    const mm = pad(d.getMinutes())
    const end = new Date(d.getTime() + 30 * 60 * 1000)
    const eh = pad(end.getHours())
    const em = pad(end.getMinutes())
    const weeks = ['日', '一', '二', '三', '四', '五', '六']
    const w = weeks[d.getDay()]
    return `上门时间  ${m}月${day}日(星期${w})${hh}:${mm}-${eh}:${em}`
  }

  private extractField(json: string, key: string): string | null {
    const resultStart: number = json.indexOf('"result":')
    if (resultStart < 0) {
      return null
    }
    const resultJson: string = json.substring(resultStart, json.length - 1)
    const pattern = `"${key}":"`
    const start = resultJson.indexOf(pattern)
    if (start < 0) {
      return null
    }
    const from = start + pattern.length
    const end = resultJson.indexOf('"', from)
    if (end < 0) {
      return null
    }
    return resultJson.substring(from, end)
  }

  aboutToAppear(): void {
    this.vm.modelName = this.params.modelName
    this.vm.imageSrc = this.params.imageSrc ?? ''
    this.vm.deviceType = this.params.deviceType ?? 'phone'
    this.vm.price = this.params.price ?? 3210
    const selMap: Map<string, string> =
      new Map<string, string>((this.params.selections ?? []).map(s => [s.title, s.value]))
    const getVal = (title: string): string => selMap.get(title) ?? '未知'
    if (this.vm.deviceType === 'computer') {
      this.vm.deviceAttrs = [
        { title: '内存', value: getVal('内存') },
        { title: '硬盘类型', value: getVal('硬盘类型') },
        { title: '处理器', value: getVal('处理器') },
      ]
    } else {
      this.vm.deviceAttrs = [
        { title: '购买渠道', value: getVal('购买渠道') },
        { title: '保修期', value: getVal('保修期') },
        { title: '容量', value: getVal('容量') },
        { title: '颜色', value: getVal('颜色') },
      ]
    }
    this.vm.functionStatus = [
      { title: '使用情况', value: getVal('使用情况') },
      { title: '机身外观', value: getVal('机身外观') },
      { title: '屏幕显示', value: getVal('屏幕显示') },
      { title: '维修历史', value: getVal('维修历史') },
      { title: '功能情况', value: getVal('功能情况') },
    ]
    // 重置时间
    this.store.selectedPickupDate = null
    this.date = new Date()
    const addrVm = AddressManagerPageVM.instance
    const list = addrVm.addressList
    if (!list || list.length === 0) {
      this.store.selectedPickupRegion = ''
      this.store.selectedPickupDetail = ''
    } else {
      const def = list.find(a => a.isDefault)
      if (def) {
        this.store.selectedPickupRegion = def.area
        this.store.selectedPickupDetail = def.detailAddress
        this.store.selectedName = def.name
        this.store.selectedPhone = def.phone
      } else {
        this.store.selectedPickupRegion = ''
        this.store.selectedPickupDetail = ''
        this.store.selectedName = ''
        this.store.selectedPhone = ''
      }
    }
  }

  @Builder
  bankCardItem(card: BankCard, index: number) {
    Row() {
      Text(`${card.bankName}${card.cardNo}`)
        .fontSize(14)
        .fontColor('rgba(0,0,0,0.95)')
      Blank()
      Stack() {
        Circle()
          .width(14)
          .height(14)
          .fillOpacity(0)
          .strokeWidth(1)
          .stroke('#C6C6C6')
        if (this.vm.selectedIndex === index) {
          Image($r('app.media.img_select_white'))
            .width(14)
            .height(14)
        }
      }
    }
    .height(40)
    .padding({
      left: 12,
      right: 12,
      top: 11,
      bottom: 11
    })
    .borderRadius(8)
    .backgroundColor('#0D000000')
    .width('100%')
    .margin({ bottom: 4 })
    .onClick(() => {
      this.vm.selectedIndex = index
    })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .title('订单详情')
    .hideTitleBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }

  // 标题布局
  @Builder
  renderTitle() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          phoneRouterControl.popPage()
        })

      Text(this.vm.modelName)
        .font({ size: 20 })
        .fontColor('rgba(0, 0, 0, 1)')
        .textAlign(TextAlign.Start)
        .margin({ left: 5 })
        .fontWeight(FontWeight.Bold)
        .width('70%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text('重新估价')
        .font({ size: 14 })
        .fontColor('rgba(0,0,0,0.6)')
        .textAlign(TextAlign.Start)
        .margin({ left: 5 })
        .onClick(() => {
          this.store.selectedPickupDate = null
          this.store.selectedPickupRegion = ''
          this.store.selectedPickupDetail = ''
          this.date = null
          phoneRouterControl.popPage()
        })
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 1)')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 25,
      top: 8,
      bottom: 8
    })
  }

  @Builder
  renderPriceCard() {
    Column() {
      Row() {
        Text('回收价格')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0,0,0,1)')
        Blank()
        Text('估价明细')
          .fontSize(12)
          .fontColor('rgba(0,0,0,0.6)')
          .onClick(() => {
            this.vm.showPriceSheet = !this.vm.showPriceSheet
          })
      }
      .height(24)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Image(this.getImageUrl).width(44).height(44).borderRadius(8)
        Column() {
          Text(`¥${this.vm.price}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4B4B')
            .margin({ bottom: 2 })
          Text() {
            Span('预计下周下跌价格：')
              .fontColor('rgba(0,0,0,0.5)')
            Span(`¥${this.vm.price - 543}`)
              .fontColor('#FF4B4B')

          }
          .fontSize(12)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .width('100%')
      }
      .margin({ top: 8 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('92%')
    .borderRadius(8)
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12
    })
    .margin({ left: '4%', right: '4%', top: 12 })
    .bindSheet($$this.vm.showPriceSheet, this.priceDetailSheet(),
      { detents: [400], preferType: SheetType.BOTTOM, showClose: false })
  }

  setStreet(data: AddressLike, candidate: RouterPopInfo, popInfo: PopInfo) {
    let street = data.street ?? ''
    let detail = data.detail ?? ''
    let address = data.address ?? ''
    let phone = data.phone ?? ''
    let name = data.name ?? ''
    // 解析json字符串
    this.getOrderInfoFromJson(data, candidate, popInfo, street, detail, address, phone, name)
  }

  // 从Json字符串读取订单信息
  getOrderInfoFromJson(data: AddressLike, candidate: RouterPopInfo, popInfo: PopInfo, street: string, detail: string,
    address: string, phone: string, name: string) {
    if (!(street || detail || address || phone || name)) {
      const s = JSON.stringify(candidate.popData ?? popInfo)
      street = this.extractField(s, 'street') ?? ''
      detail = this.extractField(s, 'detail') ?? ''
      address = this.extractField(s, 'address') ?? ''
      phone = this.extractField(s, 'phone') ?? ''
      name = this.extractField(s, 'name') ?? ''
    }
    // 判断信息字段为空
    this.checkFeildEmpty(street, detail, address, phone, name)
  }

  // 判断字段为空
  checkFeildEmpty(street: string, detail: string, address: string, phone: string, name: string) {
    // 姓名和电话
    if (name || phone) {
      this.store.selectedName = name
      this.store.selectedPhone = phone
    } else {
      this.store.selectedName = ''
      this.store.selectedPhone = ''
    }
    // 街道和详细地址
    if (street || detail) {
      this.store.selectedPickupRegion = street
      this.store.selectedPickupDetail = detail
      return
    }
    if (address) {
      this.store.selectedPickupRegion = address
      this.store.selectedPickupDetail = ''
    } else {
      const list = AddressManagerPageVM.instance.addressList
      if (!list || list.length === 0) {
        this.store.selectedPickupRegion = ''
        this.store.selectedPickupDetail = ''
        this.store.selectedName = ''
        this.store.selectedPhone = ''
      } else {
        const def = list.find(a => a.isDefault)
        if (def) {
          this.store.selectedPickupRegion = def.area
          this.store.selectedPickupDetail = def.detailAddress
          this.store.selectedName = def.name
          this.store.selectedPhone = def.phone
        }
      }
    }
  }

  appointment() {
    const addressManagerPage: NavPageInfo = {
      pageName: RouterMap.ADDRESS_MANAGER_PAGE,
      builder: wrapBuilder(AddressManagerPageBuilder),
      param: '修改预约信息',
      onPop: (popInfo: PopInfo) => {
        const candidate = popInfo as RouterPopInfo
        const data: AddressLike = (candidate.popData as AddressLike) ?? (popInfo as AddressLike)
        if (data) {
          this.setStreet(data, candidate, popInfo)
        } else {
          const list = AddressManagerPageVM.instance.addressList
          if (!list || list.length === 0) {
            this.store.selectedPickupRegion = ''
            this.store.selectedPickupDetail = ''
          } else {
            const def = list.find(a => a.isDefault)
            if (def) {
              this.store.selectedPickupRegion = def.area
              this.store.selectedPickupDetail = def.detailAddress
            }
          }
        }
      }
    }
    phoneRouterControl.jumpPage(addressManagerPage)
  }

  @Builder
  renderGetGoods() {
    Column({ space: 12 }) {
      Text('上门取件')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0,0,0,1)')
      Row() {
        Image($r('app.media.img_ring_red'))
          .width(15)
          .height(15)
        Text(this.computedAddrText)
          .fontSize(14)
          .textAlign(TextAlign.Start)
          .fontColor('rgba(0,0,0,0.95)')
          .margin({ left: 8, right: 8 })
          .width('80%')

        Blank()
        Text() {
          Span('更换')
            .fontSize(12)
            .fontColor('rgba(255,75,75,1)')
          ImageSpan($r('app.media.img_right_red'))
            .width(15)
            .height(15)
        }
      }
      .padding({
        left: 12,
        right: 12,
        top: 12,
        bottom: 12
      })
      .borderRadius(8)
      .borderWidth(1)
      .borderColor('rgba(247,248,250,1)')
      .margin({ bottom: 6 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.appointment()
      })

      Row() {
        Image($r('app.media.img_ring_blue'))
          .width(15)
          .height(15)
          .margin({ right: 8 })
        TimeSelect({
          label: this.getTimeText,
          selectedTimestamp: this.store.selectedPickupDate ?? null,
          timeOptions: {
            days: 7,
            startTime: '06:59:00',
            endTime: '19:30:00',
          },
          styleOptions: {
            dayFg: '#e6000000',
            dayFgSelected: '#FFFFFF',
            timeBg: '#FFFFFF',
            timeBgSelected: '#FFECEC',
            timeBorder: '#FFFFFF',
            timeBorderSelected: '#FFECEC',
          },
          onTimeSelect: (dateTime: Date) => {
            this.date = dateTime;
            this.store.selectedPickupDate = dateTime.getTime()
          },
        })
          .opacity(this.getTimeTextOpacity)
      }
      .padding({
        left: 12,
        right: 12,
        top: 12,
        bottom: 12
      })
      .borderRadius(8)
      .borderWidth(1)
      .borderColor('rgba(247,248,250,1)')
      .margin({ bottom: 4 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('92%')
    .alignItems(HorizontalAlign.Start)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12
    })
    .margin({
      left: '4%',
      right: '4%',
      top: 12,
      bottom: 12
    })
  }

  @Builder
  renderPriceInfo() {
    Column({ space: 12 }) {
      Text('收款信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0,0,0,1)')
      Column() {
        Row() {
          Image($r('app.media.img_card'))
            .width(24)
            .height(24)
          Text('银行卡')
            .fontSize(12)
            .fontColor('rgba(0,0,0,0.6)')
        }
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 16 })

        Divider()
          .color($r('sys.color.comp_divider'))
      }
      .alignItems(HorizontalAlign.Start)

      ForEach(this.store.bankCards, (card: BankCard, index: number) => {
        this.bankCardItem(card, index)
      }, (card: BankCard, index: number) => `${card.bankName}_${index}`)

      Text('添加银行卡')
        .fontSize(14)
        .fontColor('#000000')
        .backgroundColor(Color.White)
        .borderRadius(8)
        .height(40)
        .textAlign(TextAlign.Center)
        .width('100%')
        .borderWidth(1)
        .borderColor('#80707070')
        .onClick(() => {
          const addCardPage: NavPageInfo = {
            pageName: RouterMap.ADD_BANK_CARD_PAGE,
            builder: wrapBuilder(AddBankCardPageBuilder),
            onPop: (_pop) => {
              this.vm.selectedIndex = this.store.bankCards.length - 1
            }
          }
          phoneRouterControl.jumpPage(addCardPage)
        })

    }
    .width('92%')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12
    })
    .margin({ left: '4%', right: '4%', top: 0 })
  }

  @Builder
  renderScroll() {
    Scroll() {
      Column() {
        // 价格卡片
        this.renderPriceCard()

        // 上门取件
        this.renderGetGoods()

        // 收款信息
        this.renderPriceInfo()

      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
    .align(Alignment.Top)
  }

  submit() {
    if (!(this.store.selectedPickupRegion && this.store.selectedPickupDetail)) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择地址' })
      return
    }
    if (!this.store.selectedPickupDate) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择上门时间' })
      return
    }
    if (this.store.bankCards.length === 0) {
      this.getUIContext().getPromptAction().showToast({ message: '请添加并选择银行卡' })
      return
    }
    if (this.vm.selectedIndex < 0 || this.vm.selectedIndex >= this.store.bankCards.length) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择银行卡' })
      return
    }
    if (!this.vm.selectedAgreement) {
      this.getUIContext().getPromptAction().showToast({ message: '请阅读并勾选《用户回收须知》' })
      return
    }
    const d = new Date()
    const pad = (n: number) => `${n < 10 ? '0' : ''}${n}`
    const timeStr = `${d.getFullYear()}-${pad(d.getMonth() +
      1)}-${pad(d.getDate())}  ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
    const card = this.store.bankCards[this.vm.selectedIndex]
    const vm = MyOrderPageVM.instance
    const visitAddr = `${this.store.selectedPickupRegion || ''}${this.store.selectedPickupDetail || ''}`
    const visitTimeStr = (() => {
      const d2 = new Date(this.store.selectedPickupDate!)
      const pad2 = (n: number) => `${n < 10 ? '0' : ''}${n}`
      const m2 = d2.getMonth() + 1
      const day2 = d2.getDate()
      const hh2 = pad2(d2.getHours())
      const mm2 = pad2(d2.getMinutes())
      const end2 = new Date(d2.getTime() + 30 * 60 * 1000)
      const eh2 = pad2(end2.getHours())
      const em2 = pad2(end2.getMinutes())
      const weeks2 = ['日', '一', '二', '三', '四', '五', '六']
      const w2 = weeks2[d2.getDay()]
      return `${m2}月${day2}日(周${w2})${hh2}:${mm2}-${eh2}:${em2}`
    })()
    const cfg =
      new OrderMasterInfo(vm.orderConfig.orderId, vm.orderConfig.masterName, vm.orderConfig.masterAvatar,
        vm.orderConfig.masterLevel,
        vm.orderConfig.masterComment, visitTimeStr,
        new OrderLocationInfo(visitAddr, this.store.selectedPhone, this.store.selectedName),
        vm.orderConfig.orderProcess, vm.orderConfig.orderProcessBack1, vm.orderConfig.orderProcessBack2,
        vm.orderConfig.expressNo, vm.orderConfig.expressNoBack)
    const item =
      new OrderItem(Date.now(), this.vm.modelName, this.getImageUrl, 1, this.vm.price,
        'XXX的小店', '待发货',
        timeStr, '', `${card.bankName}|${card.cardNo}`, this.vm.price - 300, cfg, '待处理1')
    const selValues = (this.params.selections ?? []).map((s: SelectionPair) => s.value).join(' ')
    item.selections = selValues || ''
    vm.orderList = [item, ...vm.orderList]
    vm.selectedTabIndex = 0
    this.getUIContext().getPromptAction().showToast({ message: '提交成功' })
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MY_ORDER_PAGE,
      builder: wrapBuilder(BuildMyOrderPage),
      param: '提交订单'
    })
  }

  @Builder
  renderColumn() {
    Column() {
      Row() {
        Stack() {
          if (this.vm.selectedAgreement) {
            Image($r('app.media.img_select'))
              .width(14)
              .height(14)
          } else {
            Row()
              .borderRadius(4)
              .borderColor('#C6C6C6')
              .borderWidth(1)
              .width(14)
              .height(14)
          }
        }
        .onClick(() => {
          this.vm.selectedAgreement = !this.vm.selectedAgreement
        })

        Text() {
          Span('我已同意并阅读')
            .fontColor('rgba(0,0,0,0.6)')
          Span('《用户回收须知》')
            .fontColor('#FF4B4B')
            .onClick(() => {
              const page: NavPageInfo = {
                pageName: RouterMap.RECYCLE_NOTICE_PAGE,
                builder: wrapBuilder(RecycleNoticePageBuilder)
              }
              phoneRouterControl.jumpPage(page)
            })
        }
        .fontSize(12)
        .margin({ left: 8 })
      }
      .height(20)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 14, bottom: 12 })

      // 提交
      Row() {
        Button('提交订单')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('rgba(255,75,75,1)')
          .borderRadius(24)
          .height(48)
          .width('92%')
          .onClick(() => {
            this.submit()
          })
      }
      .width('100%')
      .height(72)
      .margin({ bottom: 28 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
  }

  // 渲染主页
  @Builder
  render() {
    RelativeContainer() {
      Column() {
        // 标题区域
        this.renderTitle()
        this.renderScroll()
        this.renderColumn()
      }
      .width('100%')
      .height('100%')

    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(242,243,245,1)')
  }

  @Builder
  priceDetailSheet(): CustomBuilder {
    Column() {
      Row() {
        Image($r('app.media.close_btn')).width(18).height(18).opacity(0)
        Text('估价明细')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6000000')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Image($r('app.media.ic_public_close_sheet'))
          .width(18)
          .height(18)
          .onClick(() => {
            this.vm.showPriceSheet = false
          })
      }
      .width('92%')
      .margin({ top: 12, bottom: 12 })

      Column() {
        Text('设备属性').fontSize(16).fontColor('#000000').margin({ bottom: 12 }).fontWeight(400)
        ForEach(this.vm.deviceAttrs, (it: SelectionPair, i: number) => {
          Row() {
            Text(it.title).fontSize(12).fontColor('#666666');
            Blank();
            Text(it.value).fontSize(12).fontColor('#191919')
          }
          .width('92%')
          .margin({ bottom: 12 })
        }, (it: SelectionPair, i: number) => `${it.title}_${i}`)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column() {
        Text('功能情况').fontSize(16).fontColor('#E6000000').margin({ top: 12, bottom: 12 }).fontWeight(400)
        ForEach(this.vm.functionStatus, (it: SelectionPair, i: number) => {
          Row() {
            Text(it.title).fontSize(12).fontColor('#666666');
            Blank();
            Text(it.value).fontSize(12).fontColor('#191919').textAlign(TextAlign.End)
          }
          .width('92%')
          .margin({ bottom: 12 })
        }, (it: SelectionPair, i: number) => `${it.title}_${i}`)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .padding({ left: 16 })
  }
}



