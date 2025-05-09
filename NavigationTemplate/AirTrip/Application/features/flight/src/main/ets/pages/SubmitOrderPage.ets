import {
  AppRouter,
  CardMap,
  checkPhoneValid,
  Constants,
  DataStorage,
  DayFormat,
  getDayLabel,
  LoadingStatus,
  OrderApi,
  OrderInfo,
  PassengerInfo,
  WebPageParams,
} from 'common'
import { AppStorageV2 } from '@kit.ArkUI'
import { BaseTitle, CreateOrderDialogParam, GlobalDialog } from 'components'
import { FlightInfo, FlightOrderInfo, FlightPageModel, FlightSpaceInfo, Instruct } from '../model/FlightPageModel';
import { BaggageAndRefundSheet } from '../components/BaggageAndRefundSheet';

@Builder
export function submitOrderPageBuilder() {
  SubmitOrderPage()
}

@ComponentV2
export struct SubmitOrderPage {
  // 应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!
  // 航班和机票信息
  @Local flightInfo: FlightInfo = new FlightInfo()
  @Local spaceInfo: FlightSpaceInfo = new FlightSpaceInfo()
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  // passenger列表
  @Local passengerList: PassengerInfo[] = []
  // 选择的乘机人个数
  @Local selectedCount: number = 0
  // 是否勾选预订须知
  @Local isCheckedInstruct: boolean = true
  @Local showInstructMode: boolean = false
  private instructionList: Instruct[] = FlightPageModel.getInstructionList()
  // 联系人姓名
  @Local contactName: string = ''
  // 联系人手机号
  @Local contactPhone: string = ''
  // 半模态
  @Local isShowMode: boolean = false

  // 获取出发日期是星期几
  getWeekDay(): string {
    return `${getDayLabel(new Date(this.flightInfo.takeoffTime))}`
  }
  // 获取舱位
  getSpaceLabel(): string {
    return this.spaceInfo.spaceType === 'ECONOMY_CLASS' ? '经济舱' : '公务舱/头等舱'
  }
  // 获取起飞和降落时间
  getFlyTime(): string {
    return this.flightInfo.takeoffTime.split(' ')[1] + ' - ' + this.flightInfo.landingTime.split(' ')[1]
  }
  // 是否是次日到达
  isNextDay(flight: FlightInfo): boolean {
    const depDate = new Date(flight.takeoffTime).toDateString();
    const arrDate = new Date(flight.landingTime).toDateString();
    return depDate !== arrDate;
  }

  // 添加乘机人
  addPassenger() {
    let selectedList = this.passengerList.filter((item: PassengerInfo) => item.isChecked)
    AppRouter.navStack.pushPathByName('SelectPassengerPage', selectedList, (popInfo) => {
      let resData = popInfo.result as Record<string, PassengerInfo[] | string>
      if (resData.selectedPassengers ) {
        let list: PassengerInfo[] = resData.selectedPassengers as PassengerInfo[]
        let resList: PassengerInfo[] = []
        for (let i = 0; i < list.length; i++) {
          let resItem: PassengerInfo = new PassengerInfo()
          let item = list[i]
          resItem.id = item.id
          resItem.name = item.name
          resItem.certificateType = item.certificateType
          resItem.certificateNo = item.certificateNo
          resItem.phone = item.phone
          resItem.isChecked = true
          resList.push(resItem)
        }
        this.passengerList = resList
        this.selectedCount = this.passengerList.filter((item: PassengerInfo) => item.isChecked).length
      }
    })
  }
  // 删除所选的乘机人
  deletePassenger(data: PassengerInfo, index: number) {
    this.passengerList.splice(index, 1)
    this.selectedCount = this.passengerList.filter((item: PassengerInfo) => item.isChecked).length
  }

  // 提交订单
  submitOrder() {
    if (this.selectedCount === 0) {
      GlobalDialog.showToast('请选择乘机人')
      return
    }
    if (this.contactName === '') {
      GlobalDialog.showToast('请输入联系人姓名')
      return
    }
    if (this.contactPhone === '') {
      GlobalDialog.showToast('请输入手机号')
      return
    }
    if (this.contactPhone && !checkPhoneValid(this.contactPhone)) {
      GlobalDialog.showToast('请输入正确的手机号')
      return
    }
    if (!this.isCheckedInstruct) {
      GlobalDialog.showToast('请阅读并勾选预订须知')
      return
    }

    let orderData: OrderInfo = new OrderInfo()
    let now = new Date().getTime() + ''
    orderData.id = 'orderId_' + now
    orderData.orderNo = now
    orderData.flightId = this.spaceInfo.flightId
    orderData.flightNo = this.flightInfo.flightNo
    orderData.createTime = new Date().getTime()
    orderData.airlineName = this.flightInfo.airlineName
    orderData.aircraftType = this.flightInfo.aircraftType
    orderData.takeoffTime = this.flightInfo.takeoffTime
    orderData.landingTime = this.flightInfo.landingTime
    orderData.departureCity = this.flightInfo.departureCity
    orderData.departureAirport = this.flightInfo.departureAirport
    orderData.destinationCity = this.flightInfo.destinationCity
    orderData.destinationAirport = this.flightInfo.destinationAirport
    orderData.mealType = this.flightInfo.mealType
    orderData.spaceType = this.spaceInfo.spaceType
    orderData.spacePrice = Number(this.spaceInfo.spacePrice)
    orderData.airportConstructionPrice = 50
    orderData.fuelPrice = 10
    orderData.includeTaxPrice = Number(this.spaceInfo.spacePrice)
    orderData.contactName = this.contactName
    orderData.contactPhone = this.contactPhone
    orderData.status = 1
    let passengerList = this.passengerList.map((item: PassengerInfo) => {
      let passenger = {
        id: item.id,
        name: item.name,
        certificateType: item.certificateType,
        certificateNo: item.certificateNo,
        phone: item.phone,
      } as PassengerInfo
      return passenger
    })
    orderData.passengerList = JSON.stringify(passengerList)

    let dialogParam = {
      okList: [false, false, false, false],
      departureCity: orderData.departureCity,
      destinationCity: orderData.destinationCity,
      takeoffTime: orderData.takeoffTime,
      passengerList: orderData.passengerList,
      view: () => {
        GlobalDialog.close()
        AppRouter.push({
          url: 'OrderDetailPage',
          param: orderData.orderNo
        })
      },
      pay: () => {
        GlobalDialog.close()
        AppRouter.push({
          url: 'PayPage',
          param: orderData
        })
      }
    } as CreateOrderDialogParam
    GlobalDialog.showDialogForCreateOrder(dialogParam)
    // 模拟订单生成
    let setIn = setInterval(() => {
      if (GlobalDialog.globalDialogInstance) {
        let okList = dialogParam.okList
        for (let i = 0; i < okList.length; i++) {
          let okItem = okList[i]
          if (!okItem) {
            okList[i] = true
            break
          }
        }
        dialogParam.okList = okList
        GlobalDialog.globalDialogInstance.update(dialogParam)
      }
    }, 1000)
    OrderApi.addOrUpdateOrder(orderData).then((res) => {
      setTimeout(() => {
        clearInterval(setIn)
      }, 5000)
      let times = new Date().getTime() + Constants.PAY_COUNT_DOWN
      this.dataStorage.payOrderTime = new DayFormat(new Date(times)).format('YYYY-MM-DD HH:mm:ss')
    })
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '确认订单信息',
          showBackBtn: true,
          bgColor: $r('sys.color.white'),
          onBack: () => {
            AppRouter.pop()
          }
        })

        List({ space: 12 }) {
          ListItem() {
            this.TicketInfoView()
          }

          ListItem() {
            this.PassengerInfoView()
          }

          ListItem() {
            this.ContactInfoView()
          }

          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.ic_safe')).width(18).height(18)
                Text() {
                  Span('安心预订')
                  Span(' ')
                  Span('放心出行')
                }
                .fontSize(16)
                .fontColor($r('sys.color.ohos_id_color_emphasize'))
                .fontWeight(600)
              }
            }
            .height(240)
            .width('100%')
            .padding(16)
          }
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
        .scrollBar(BarState.Off)

        Column({ space: 10 }) {
          Row({ space: 4 }) {
            Image(this.isCheckedInstruct ? $r('app.media.ic_checked') : $r('app.media.icon_noselect'))
              .width(18)
              .height(18)
              .onClick(() => {
                this.isCheckedInstruct = !this.isCheckedInstruct
              })
            Text() {
              Span('点击去支付表示您已阅读并同意').fontColor('#999')
              Span('《预订须知》、《锂电池运输安全规定》、《民航旅客禁止、限制随身携带和托运物品目录》').fontColor('#cc007dff')
            }
            .fontSize(12)
            .fontWeight(400)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .onClick(() => {
              this.showInstructMode = !this.showInstructMode
            })
          }
          .bindSheet($$this.showInstructMode, this.InstructSheetBuilder(), {
            height: 260,
            blurStyle: BlurStyle.COMPONENT_THICK,
            preferType: SheetType.BOTTOM,
            showClose: false,
          })

          Divider().strokeWidth(0.5).width('100%').color($r('sys.color.ohos_id_color_button_divider'))

          Row() {
            Row({ space: 4 }) {
              Text('在线支付').fontWeight(400).fontSize(13).fontWeight(400)
              Text() {
                Span('¥').fontSize(10)
                Span(String((Number(this.spaceInfo.spacePrice ?? 0) + 60) * this.selectedCount)).fontSize(16)
              }
              .fontWeight(600)
              .fontColor(Color.Red)
            }

            Row({ space: 8 }) {
              Row() {
                Text('明细').fontSize(12).fontColor('#999')
                Image($r('app.media.ic_up_arrow')).width(14).height(14)
              }
              .visibility(this.selectedCount > 0 ? Visibility.Visible : Visibility.Hidden)
              .onClick(() => {
                if (this.selectedCount > 0) {
                  GlobalDialog.showDialogForCostDetail({
                    title: '费用明细',
                    totalCost: String(Number(this.spaceInfo.spacePrice ?? 0) + 60),
                    taxPrice: this.spaceInfo.spacePrice,
                    airportConstructionPrice: '50',
                    fuelPrice: '10',
                    passengerNum: this.selectedCount
                  })
                }
              })

              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text('提交订单').fontSize(16).fontColor($r('sys.color.white')).fontWeight(FontWeight.Medium)
              }
              .width(110)
              .padding({ top: 12, bottom: 12 })
              .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
              .onClick(() => {
                this.submitOrder()
              })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding({
          left: 16,
          top: 10,
          right: 16,
          bottom: 10 + px2vp(91)
        })
        .backgroundColor($r('sys.color.white'))
        .borderRadius(6)
        .position({
          bottom: px2vp(-91),
          left: 0
        })
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor('#fff5f3f3')
    .onReady((cxt) => {
      let params: FlightOrderInfo = cxt.pathInfo.param as FlightOrderInfo
      this.flightInfo = params.flightInfo
      this.spaceInfo = params.spaceInfo
    })
  }

  // 机票航班信息
  @Builder
  TicketInfoView() {
    Column() {
      Row({ space: 10 }) {
        Image($r('app.media.ic_air_logo')).width(24).height(24).borderRadius(24)

        Column({ space: 8 }) {
          Row({space: 8}) {
            Text(new DayFormat(new Date(this.flightInfo.takeoffTime)).format('MM月DD日'))
            Text(this.getWeekDay())
          }
          Text() {
            Span(this.flightInfo.departureAirport)
            Span(' - ')
            Span(this.flightInfo.destinationAirport)
          }

          Row({space: 8}) {
            Text(this.flightInfo.airlineName + this.flightInfo.flightNo).fontSize(10).fontColor('#99000000')
            Text(this.flightInfo.aircraftType).fontSize(10).fontColor('#99000000')
            Text(this.getSpaceLabel()).fontSize(10).fontColor('#99000000')
            Text() {
              Span(this.getFlyTime()).fontSize(10).fontColor('#99000000')
              if (this.isNextDay(this.flightInfo)) {
                Span('次日').fontSize(8).fontColor('#E8442A')
              }
            }
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding(12)
      .alignItems(VerticalAlign.Top)

      List() {
        ListItem() {
          TicketInfoItem({
            label: '票价',
            value: `¥${Number(this.spaceInfo.spacePrice).toFixed(0)}+ 机建¥50+ 燃油¥10`,
          })
        }

        ListItem() {
          TicketInfoItem({
            label: '退改',
            value: this.spaceInfo.refundChangePolicy,
            showRightArrow: true,
            clickEvent: () => {
              this.isShowMode = !this.isShowMode
            }
          })
        }
        ListItem() {
          TicketInfoItem({
            label: '行李',
            value: this.spaceInfo.baggagePolicy,
            showRightArrow: true,
            clickEvent: () => {
              this.isShowMode = !this.isShowMode
            }
          })
        }
        ListItem() {
          TicketInfoItem({
            label: '出票',
            value: '支付成功后60分钟内出票',
          })
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14 })
      .borderRadius(8)
      .backgroundColor($r('sys.color.white'))
      .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
      .bindSheet($$this.isShowMode, this.SheetBuilder(), {
        height: '70%',
        blurStyle: BlurStyle.COMPONENT_THICK,
        preferType: SheetType.BOTTOM,
        title: {
          title: '改退签及行李额'
        },
      })
    }
    .width('100%')
    .margin({top: 18})
    .alignItems(HorizontalAlign.Start)
    .borderRadius(16)
    .backgroundColor('#E5E5EA')
  }
  @Builder
  PassengerInfoView() {
    Column({ space: 14 }) {
      Row() {
        Text('乘机人信息').fontWeight(FontWeight.Medium).fontSize(16)
        Text() {
          Span('已选：')
          Span(this.selectedCount + '').fontColor($r('sys.color.ohos_id_color_emphasize'))
        }
        .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider().vertical(false).strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider')).width('100%')

      // 乘机人
      List({space: 16}) {
        ForEach(this.passengerList, (item: PassengerInfo, index: number) => {
          ListItem() {
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text(item.name).fontWeight(FontWeight.Regular).fontSize(14)

                Row({ space: 4 }) {
                  Text(CardMap[item.certificateType]).fontSize(12).fontColor('#99000000')
                  Text(item.certificateNo).fontSize(12).fontColor('#99000000')
                }
              }
              .alignItems(HorizontalAlign.Start)

              Image($r('app.media.ic_delete')).width(16).height(16)
                .onClick(() => {
                  this.deletePassenger(item, index)
                })
            }
            .width('100%')
            .backgroundColor($r('sys.color.white'))
            .borderRadius(6)
            .justifyContent(FlexAlign.SpaceBetween)
          }
        })
      }
      .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })

      // 添加乘机人
      Button({ type: ButtonType.Capsule, stateEffect: true }) {
        Row({ space: 12 }) {
          Image($r('app.media.ic_add_passenger')).width(16).height(17)
          Text('添加乘机人').fontSize(16).fontColor($r('sys.color.ohos_id_color_emphasize'))
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .backgroundColor('#DAE2FE')
      .onClick(() => {
        this.addPassenger()
      })
    }
    .width('100%')
    .padding(14)
    .alignItems(HorizontalAlign.Start)
    .borderRadius(18)
    .backgroundColor($r('sys.color.white'))
  }
  // 联系人
  @Builder
  ContactInfoView() {
    Column({ space: 16 }) {
      Row({ space: 16 }) {
        Row({space: 8}) {
          Text('*').fontSize(16).fontColor('#E84026')
          Text('联系人').fontSize(16).fontWeight(FontWeight.Medium)
        }

        TextInput({ text: this.contactName, placeholder: '请输入联系人' })
          .placeholderColor('#66000000')
          .placeholderFont({ size: 12, weight: FontWeight.Regular })
          .type(InputType.Normal)
          .maxLength(32)
          .padding(0)
          .layoutWeight(1)
          .borderRadius(0)
          .backgroundColor(Color.Transparent)
          .caretColor($r('sys.color.ohos_id_color_emphasize'))
          .inputFilter(Constants.NAME_REG, () => {})
          .onChange((value: string) => {
            this.contactName = value
          })
      }

      Divider().vertical(false).strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider')).width('100%')

      Row({ space: 12 }) {
        Row({space: 8}) {
          Text('*').fontSize(16).fontColor('#E84026')
          Text('联系人电话').fontSize(16).fontWeight(FontWeight.Medium)
        }

        Text('+86').fontSize(12).fontWeight(FontWeight.Regular).fontColor('#66000000')
        Divider().vertical(true).strokeWidth(0.5).height(13).color($r('sys.color.ohos_id_color_button_divider'))

        TextInput({ text: this.contactPhone, placeholder: '请输入手机号码' })
          .placeholderColor('#66000000')
          .placeholderFont({ size: 12, weight: FontWeight.Regular })
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .padding(0)
          .layoutWeight(1)
          .borderRadius(0)
          .backgroundColor(Color.Transparent)
          .caretColor($r('sys.color.ohos_id_color_emphasize'))
          .onChange((value: string) => {
            this.contactPhone = value
          })
      }
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .borderRadius(18)
    .backgroundColor($r('sys.color.white'))
  }
  // 预订须知
  @Builder
  InstructSheetBuilder() {
    List() {
      ForEach(this.instructionList, (item: Instruct) => {
        ListItem() {
          Row() {
            Text(item.name)
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .padding({top: 18, bottom: 18})
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.showInstructMode = false
            const params: WebPageParams = {
              linkUrl: item.linkUrl,
              title: item.name,
            };
            AppRouter.push({
              url: 'WebPage',
              param: params
            })
          });
        }
      })

      ListItem() {
        Row() {}.width(Constants.FULL_PERCENT_WIDTH).height(12).backgroundColor('#E5E5EA')
      }
      ListItem() {
        Row() {
          Text('取消').fontColor('#466DFA')
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .padding({top: 18, bottom: 18})
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showInstructMode = !this.showInstructMode
        })
      }
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .alignListItem(ListItemAlign.Center)
    .divider({strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
  }

  // 半模态
  @Builder
  SheetBuilder() {
    BaggageAndRefundSheet()
  }
}

@ComponentV2
struct TicketInfoItem {
  @Param label: string = ''
  @Param value: string = ''
  @Param showRightArrow?: boolean = false
  @Event clickEvent: () => void = () => {
  }

  build() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.ic_checked')).width(20).height(20)
        Text(this.label).fontSize(12).fontColor('#99000000')
        Text(this.value).fontSize(12)
      }

      if (this.showRightArrow) {
        Image($r('app.media.ic_right_arrow')).width(20).height(20).fillColor('#999')
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.clickEvent && this.clickEvent()
    })
  }
}