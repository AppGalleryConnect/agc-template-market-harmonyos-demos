import { AppStorageV2 } from '@kit.ArkUI';
import { GlobalContext, RouterMap, SecureRandomUtil } from 'common';
import { phoneRouterControl } from 'oh_router';
import { HotelDateModel } from './HotelDateModel';
import { HotelModel } from './HotelModel';
import { PassengerInfo } from './PassengerModel';
import { detailRouterParam, TourModel, TourOrderRouterParam } from './TourModel';
import { PlaneDetailListModel, PlanePageVM, TicketDetailListModel } from './TicketPriceModel';
import { MyMessageList } from './MessageModel';
import { OrderUtil } from '../util/OrderUtil';


// 订单类型
export enum OrderType {
  TRAIN = '火车票',
  SCENIC = '景区',
  HOTEL = '酒店',
  AIRPLANE = '机票',
  BUS = '汽车票'
}

// 订单状态
export enum OrderStatus {
  FINISHED = 3, // 已完成
  ISSUED = 2, // 已出票
  BOOKED = 1, // 已预定
  PENDING = 0, // 待付款
  CANCEL = -1, // 已取消
  REFUNDED = -2, // 已退票
}

@ObservedV2
export class OrderDetailInfo {
  // 酒店
  startTime?: string = '2025-11-02' // 开始时间
  endTime?: string = '2025-11-05' // 结束时间
  hotelModel?: HotelModel // 订单信息
  hotelDate?: HotelDateModel // 订单时间
  phoneNum?: string // 电话
  totalPrice?: number // 总价
  id?: string // 订单编号
  roomType?: string // 房间描述
  hotelLocation?: string = '龙冠镇南店村回龙观西三旗西路18号' // 酒店地址
  roomName?: string = '舒适大床房' // 房间名称
  roomDesc?: string = '3晚1间' // 房间描述
  totalDays?: number = 0 // 天数
  createTime?: string = '' //订单创建时间
  createDate?: string = '' //订单创建日期
  paymentDate?: string = '' //
  isPulUpPay?: boolean = false //是否拉起支付
  hotelName?: string = '' //酒店名称
  chooseStatus?: number = 0 // 住宿类型


  flightNumber?: string = 'HU7789' // 航班号
  seatNo?: string = '21J' // 座位号
  cabinClass?: string = '经济' // 舱位等级
  aircraftModel?: string = '波音787(大)' // 飞机型号
  onTimeRate?: string = '87%' // 准点率
  boardingGate?: string = '黄花2号航站楼' // 登机地点
  boardingGateNo?: string = '25' // 登机口
  trainNo?: string = 'G103' //火车号
  carriageNum?: string = '15车12A号' // 车厢号
  seatLevel?: string = '二等座' // 座位级别
  ticketCheckpoint?: string = '二层12，二层13，负一层2快速进站厅12、13' // 检票口
  departurePlace?: string = '长沙' // 出发地
  destination?: string = '济南' // 目的地
  departureTime: string = '2025-09-17 07:30' // 发车/起飞时间
  arrivalTime: string = '2025-09-17 10:00' // 到达时间
  busDuration: string = '2时30分'
  //景点
  scenicOrderNum?: string = '' // 订单编号
  scenicCreateTimestamp?: number = 0 // 创建时间戳
  scenicCreateDate?: string = '' // 创建日期年月日
  scenicCreateTime?: string = '' // 创建时间时分秒
  scenicPayTimestamp?: number = 0 // 付款时间戳
  scenicPayCreateDate?: string = '' // 付款日期年月日
  scenicPayCreateTime?: string = '' // 付款时间时分秒
  scenicRefundTimestamp?: number = 0 // 退款时间戳
  scenicRefundCreateDate?: string = '' // 退款日期年月日
  scenicRefundCreateTime?: string = '' // 退款时间时分秒
  scenicRefundAccount?: string = '' // 退款账号
  scenicRefundPrice?: string | number = '' // 退款金额
  scenicImage?: string = '' // 缩略图
  scenicPayType?: string = '' //支付方式
  scenicTitle?: string = '' // 标题
  scenicSchedulePrice?: number = 0 // 班期价格
  scenicScheduleDate?: string = '' // 班期时间
  scenicStarTime?: string = '' // 开始时间
  scenicEndTime?: string = '' // 结束时间
  scenicMockInfo?: TourModel | null = null // 景点mock数据
  scenicGrownManNum?: number // 成人数量
  scenicChildrenNum?: number // 儿童数量
  scenicContactPhone?: string | number // 联系电话
  scenicPayTotalPrice?: string | number // 订单总金额

  // 飞机票/汽车票/飞机票
  ticketGo?: TicketDetailListModel //去程及单程
  ticketBack?: TicketDetailListModel //返程
  planeGo?: PlaneDetailListModel //去程及单程
  planeBack?: PlaneDetailListModel //返程
  busGo?: PlaneDetailListModel //汽车
}

@ObservedV2
export class OrderInfo {
  @Trace messageList: MyMessageList = AppStorageV2.connect(MyMessageList, () => new MyMessageList())!
  @Trace id: string = SecureRandomUtil.getRandomString(15)
  // 订单状态
  @Trace status: OrderStatus = OrderStatus.PENDING
  // 订单类型
  @Trace type: OrderType
  // 订单金额
  @Trace price: number
  // 订单名称
  @Trace name: string
  // 订单详情
  @Trace detailInfo: OrderDetailInfo = new OrderDetailInfo()
  // 订单返程详情
  @Trace returnDetailInfo?: OrderDetailInfo = undefined
  // 订单人
  @Trace passengerInfo: PassengerInfo[] = []
  // 订单图标
  icon: ResourceStr = ''
  // 订单状态文本
  statusText: string = ''
  // 订单置灰状态
  grayStatusList: number[] = [OrderStatus.CANCEL, OrderStatus.REFUNDED]
  // 订单来源标识 1 从TicketOrderPage跳转过来的
  tag: number = 0;
  context = GlobalContext.getUIAbilityContext()

  constructor(type: OrderType, price: number, name: string, status?: OrderStatus, detailInfo?: OrderDetailInfo) {
    this.type = type
    this.price = price
    this.name = name
    this.status = status || this.status
    this.detailInfo = detailInfo || this.detailInfo
    this.getIcon()
    this.getStatusText()
  }
  // 是否是灰色订单
  isShowGray() {
    return this.grayStatusList.includes(this.status)
  }

  // 去付款
  goPayOrder(data: OrderInfo) {
    if (this.type === OrderType.SCENIC) {
      this.scenicGoPay(data)
    } else if (this.type === OrderType.HOTEL) {
      this.hotelGoPay(data)
    } else {
      if (this.type === OrderType.TRAIN) {
        this.ticketGoPay(OrderType.TRAIN, data)
      }
      if (this.type === OrderType.AIRPLANE) {
        this.ticketGoPay(OrderType.AIRPLANE, data)
      }
      if (this.type === OrderType.BUS) {
        this.ticketGoPay(OrderType.BUS, data)
      }
    }
  }

  // 申请退款
  applyRefund() {
    if (this.type === OrderType.SCENIC) {
      this.scenicApplyRefund()
    } else {
      this.status = OrderStatus.REFUNDED
      this.getStatusText()
      const pad2 = (n: number) => n.toString().padStart(2, '0');
      // 退款时间
      let refundTime = new Date();
      const refundCreateDate =
        `${refundTime.getFullYear()}-${pad2(refundTime.getMonth() + 1)}-${pad2(refundTime.getDate())}`;
      if (this.type === OrderType.BUS) {
        if (this.detailInfo && this.detailInfo.busGo) {
          this.detailInfo.busGo.status = OrderStatus.REFUNDED
          this.detailInfo.busGo.returnPrice = this.price.toString()
          this.detailInfo.busGo.scenicRefundCreateDate = refundCreateDate
          this.pushTicketOrderMessage(OrderType.BUS, this.detailInfo)
        }
      }
      if (this.type === OrderType.TRAIN) {
        if (this.detailInfo && this.detailInfo.planeGo) {
          this.detailInfo.planeGo.status = OrderStatus.REFUNDED
          this.detailInfo.planeGo.returnPrice = this.price.toString()
          this.detailInfo.planeGo.scenicRefundCreateDate = refundCreateDate
          this.pushTicketOrderMessage(OrderType.TRAIN, this.detailInfo)
        }
      }
      if (this.type === OrderType.AIRPLANE) {
        if (this.detailInfo && this.detailInfo.ticketGo) {
          this.detailInfo.ticketGo.status = OrderStatus.REFUNDED
          this.detailInfo.ticketGo.returnPrice = this.price.toString()
          this.detailInfo.ticketGo.scenicRefundCreateDate = refundCreateDate
          this.pushTicketOrderMessage(OrderType.AIRPLANE, this.detailInfo)
        }
      }
    }
    this.context.eventHub.emit('orderStatusChange');
  }

  // 判断已预定或者已出票订单结束时间有无超时
  getIsFinish() {
    try {
      // 获取当前年份
      let currentYear = new Date().getFullYear();
      let targetTime: string = ''
      if (this.type === OrderType.TRAIN) {
        // 设定一个具体时间
        if (this.detailInfo?.planeGo?.type === 0) {
          targetTime = `${currentYear}-${this.detailInfo.planeGo.timeDate}T${this.detailInfo.planeGo.endDate}:00`
        } else {
          targetTime =
            `${currentYear}-${this.detailInfo.planeBack?.timeDate}T${this.detailInfo.planeBack?.endDate}:00`
        }
      }
      if (this.type === OrderType.AIRPLANE) {
        // 设定一个具体时间
        if (this.detailInfo.ticketGo?.type === 0) {
          targetTime = `${currentYear}-${this.detailInfo.ticketGo.timeDate}T${this.detailInfo.ticketGo.endDate}:00`;
        } else {
          targetTime = `${currentYear}-${this.detailInfo.ticketBack?.timeDate}T${this.detailInfo.ticketBack?.endDate}:00`;
        }
      }
      if (this.type === OrderType.BUS) {
        // 设定一个具体时间
        targetTime = `${currentYear}-${this.detailInfo.busGo?.timeDate}T${this.detailInfo.busGo?.endDate}:00`
      }
      // 景点已完成状态
      if(this.type === OrderType.SCENIC){
        targetTime =`${this.detailInfo.scenicEndTime} 23:59:59`
      }
      // 获取当前时间
      const currentTime = new Date().getTime();
      // 比较时间
      if (currentTime > new Date(targetTime).getTime()) {
        this.context.eventHub.emit('orderStatusChange');
        return true
      } else {
        return false
      }
    }
    catch (e){
      return false
    }
  }

  // 判断未付款订单有无超时
  getIsCancel(){
    try {
     return false
    }
    catch (e){
      return false
    }
  }


  // 再次预定
  bookAgain() {
    if (this.type === OrderType.HOTEL) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.SUBMIT_ORDER_PAGE,
        param: this.detailInfo
      })
    } else if (this.type === OrderType.SCENIC) {
      // 景点再次预定
      this.scenicBookAgain()
    } else {
      let vm: PlanePageVM = new PlanePageVM()
      if (this.detailInfo.planeGo) {
        vm.returnSatus = this.detailInfo.planeGo.type
      }
      if (this.type === OrderType.TRAIN) {
        vm.chooseStatus = 1
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PLANE_TICKET_PAGE,
          param: '火车票'
        })
      }
      if (this.type === OrderType.AIRPLANE) {
        vm.chooseStatus = 0
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PLANE_TICKET_PAGE,
          param: '机票'
        })
      }
      if (this.type === OrderType.BUS) {
        vm.chooseStatus = 2
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PLANE_TICKET_PAGE,
          param: '汽车票'
        })
      }
    }
  }

  // 取消订单
  cancelOrder() {
    if (this.type === OrderType.SCENIC) {
      // 景点取消订单
      this.scenicCancelOrder()
    } else if (this.type === OrderType.HOTEL) {
      this.hotelApplyRefund()
    } else if (this.type === OrderType.TRAIN || this.type === OrderType.AIRPLANE || this.type === OrderType.BUS) {
      this.ticketCancelOrder()
    }
    this.context.eventHub.emit('orderStatusChange');
  }

  // 报销发票
  reimburseInvoice() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.REIMBURSEMENT_VOUCHER_PAGE,
      param: this.detailInfo.totalPrice || this.detailInfo.ticketGo?.price || this.detailInfo.planeGo?.price
    })
  }

  // 景点取消订单
  scenicCancelOrder() {
    this.status = OrderStatus.CANCEL
    this.getStatusText()
  }

  // 酒店取消订单
  hotelApplyRefund() {
    if (this.status === OrderStatus.PENDING) {
      this.status = OrderStatus.CANCEL
      this.getStatusText()
    } else {
      this.status = OrderStatus.REFUNDED
      const pad2 = (n: number) => n.toString().padStart(2, '0');
      // 退款时间
      let refundTime = new Date();
      const createTimestamp = refundTime.getTime();
      const refundCreateTime =
        `${pad2(refundTime.getHours())}:${pad2(refundTime.getMinutes())}:${pad2(refundTime.getSeconds())}`;
      const refundCreateDate =
        `${refundTime.getFullYear()}-${pad2(refundTime.getMonth() + 1)}-${pad2(refundTime.getDate())}`;
      this.detailInfo.scenicRefundTimestamp = createTimestamp
      this.detailInfo.scenicRefundCreateTime = refundCreateTime
      this.detailInfo.scenicRefundCreateDate = refundCreateDate
      this.hotelPayedData()
      this.getStatusText()
    }

  }

  // 车票取消订单
  ticketCancelOrder() {
    this.status = OrderStatus.CANCEL
    if (this.detailInfo && this.detailInfo.busGo) {
      this.detailInfo.busGo.status = OrderStatus.CANCEL as OrderStatus
    }
    if (this.detailInfo && this.detailInfo.planeGo) {
      this.detailInfo.planeGo.status = OrderStatus.CANCEL as OrderStatus
    }
    if (this.detailInfo && this.detailInfo.ticketGo) {
      this.detailInfo.ticketGo.status = OrderStatus.CANCEL as OrderStatus
    }
    this.getStatusText()
  }

  // 更新三种车票订单数据
  upTicketDetail() {
    if (this.type === OrderType.TRAIN) {
      this.updateTrainData()
    }
    if (this.type === OrderType.BUS) {
      this.updateBusData()
    }
    if (this.type === OrderType.AIRPLANE) {
      this.updateAirData()
    }
    this.getStatusText()
  }

  // 更新火车票订单数据
  updateTrainData() {
    let planeGo = this.detailInfo.planeGo
    let planeBack = this.detailInfo.planeBack
    this.price = Number(this.detailInfo.planeGo?.returnPrice)
    this.detailInfo.totalPrice = this.price
    this.name = '火车票'
    this.detailInfo = this.upDateTrainDetail(this.detailInfo.planeGo)
    this.detailInfo.planeGo = planeGo
    this.detailInfo.planeBack = planeBack
    // 有返程
    if (this.detailInfo.planeGo?.type === 1) {
      this.returnDetailInfo = this.upDateTrainDetail(this.detailInfo.planeBack)
    }
    this.detailInfo.planeGo?.peopleList.forEach((item) => {
      let people: PassengerInfo = new PassengerInfo()
      people.name = item.name
      people.phone = item.phone
      people.idNumber = item.maskedIdNumber as string
      people.seatNo = this.detailInfo.planeGo?.seatClass + ' ' + this.detailInfo.planeGo?.carriageNum
      this.passengerInfo.push(people)
    })
  }

  // 更新汽车票订单数据
  updateBusData() {
    this.price = Number(this.detailInfo.busGo?.returnPrice)
    this.detailInfo.totalPrice = this.price
    this.name = '汽车票'
    this.detailInfo.trainNo = this.detailInfo.busGo?.trainNumber
    this.detailInfo.departurePlace = this.detailInfo.busGo?.startLocation || ''
    this.detailInfo.destination = this.detailInfo.busGo?.endLocation || ''
    this.detailInfo.departureTime = this.detailInfo.busGo?.startDate || ''
    this.detailInfo.arrivalTime = this.detailInfo.busGo?.endDate || ''
    this.detailInfo.ticketCheckpoint = '一层大厅检票候车'
    this.detailInfo.busDuration = this.detailInfo.busGo?.duration || '2时30分'
    this.detailInfo.startTime = this.detailInfo.busGo?.timeDate + ' ' + this.detailInfo.busGo?.startDate
    this.detailInfo.endTime = this.detailInfo.busGo?.timeDate + ' ' + this.detailInfo.busGo?.endDate
    this.detailInfo.busGo?.peopleList.forEach((item) => {
      let people: PassengerInfo = new PassengerInfo()
      people.name = item.name
      people.phone = item.phone
      people.idNumber = item.maskedIdNumber as string
      this.passengerInfo.push(people)
    })
  }

  // 更新飞机订单数据
  updateAirData() {
    let ticketGo = this.detailInfo.ticketGo
    let ticketBack = this.detailInfo.ticketBack
    this.price = Number(this.detailInfo.ticketGo?.returnPrice)
    this.detailInfo.totalPrice = this.price
    this.name = '飞机票'
    this.detailInfo = this.upDateAirplaneDetail(this.detailInfo.ticketGo)
    this.detailInfo.ticketGo = ticketGo
    this.detailInfo.ticketBack = ticketBack
    // 有返程
    if (this.detailInfo.ticketGo?.type === 1) {
      this.returnDetailInfo = this.upDateAirplaneDetail(this.detailInfo.ticketBack)
    }
    this.detailInfo.ticketGo?.peopleList.forEach((item) => {
      let people: PassengerInfo = new PassengerInfo()
      people.name = item.name
      people.phone = item.phone
      people.idNumber = item.maskedIdNumber as string
      this.passengerInfo.push(people)
    })
  }

  // 更新火车票数据
  upDateTrainDetail(data?: PlaneDetailListModel) {
    let detailInfo = new OrderDetailInfo()
    if (!data) {
      return detailInfo
    }
    detailInfo.trainNo = data.trainNumber
    detailInfo.carriageNum = data.carriageNum
    detailInfo.seatLevel = data.seatClass
    detailInfo.ticketCheckpoint = data.ticketCheckpoint
    detailInfo.departurePlace = data.startLocation
    detailInfo.departureTime = data.startDate
    detailInfo.arrivalTime = data.endDate
    detailInfo.destination = data.endLocation
    detailInfo.startTime = data.timeDate + ' ' + data.startDate as string
    detailInfo.endTime = data.timeDate + ' ' + data.endDate as string
    return detailInfo
  }

  // 更新飞机票数据
  upDateAirplaneDetail(data?: TicketDetailListModel) {
    let detailInfo = new OrderDetailInfo()
    if (!data) {
      return detailInfo
    }
    detailInfo.departurePlace = data.startLocation
    detailInfo.destination = data.endLocation
    detailInfo.flightNumber = data.aviation
    detailInfo.cabinClass = data.cabinClass
    detailInfo.aircraftModel = data.boeing
    detailInfo.seatNo = data.seatNo // 座位号
    detailInfo.onTimeRate = '87%' // 准点率
    detailInfo.boardingGate = data.boardingGate // 登机地点
    detailInfo.boardingGateNo = data.boardingGateNo // 登机口
    detailInfo.departureTime = data.startDate
    detailInfo.arrivalTime = data.endDate
    detailInfo.startTime = data.timeDate + ' ' + data.startDate as string
    detailInfo.endTime = data.timeDate + ' ' + data.endDate as string
    return detailInfo
  }

  // 景点申请退款
  scenicApplyRefund() {
    this.status = OrderStatus.REFUNDED
    this.getStatusText()
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    // 退款时间
    let refundTime = new Date();
    const createTimestamp = refundTime.getTime();
    const refundCreateTime =
      `${pad2(refundTime.getHours())}:${pad2(refundTime.getMinutes())}:${pad2(refundTime.getSeconds())}`;
    const refundCreateDate =
      `${refundTime.getFullYear()}-${pad2(refundTime.getMonth() + 1)}-${pad2(refundTime.getDate())}`;
    this.detailInfo.scenicRefundTimestamp = createTimestamp
    this.detailInfo.scenicRefundCreateTime = refundCreateTime
    this.detailInfo.scenicRefundCreateDate = refundCreateDate
    // 退款账号
    this.detailInfo.scenicRefundAccount = '中国银行（8888）'
    // 退款金额
    this.detailInfo.scenicRefundPrice = this.price
    this.pushScenicOrderMessage(this.detailInfo)
  }

  //景点再次预定，跳转到景点的下单页面
  scenicBookAgain() {
    let param: detailRouterParam = {
      scenicMockInfo: this.detailInfo?.scenicMockInfo || null,
      price: this.detailInfo.scenicSchedulePrice || 0,
      starTime: this.detailInfo?.scenicStarTime || '',
      endTime: this.detailInfo?.scenicEndTime || '',
      scheduleDateCode: this.detailInfo?.scenicScheduleDate || '',
      grownManNum: this.detailInfo.scenicGrownManNum || 0,
      childrenNum: this.detailInfo.scenicChildrenNum || 0,
      passengerInfo: this.passengerInfo,
      contactPhone: this.detailInfo.scenicContactPhone || '',
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TOUR_ORDER_PAGE,
      param: param
    })
  }

  // 车票付款跳转详情页
  ticketGoPay(type: OrderType, data: OrderInfo) {
    let param: TourOrderRouterParam = {
      orderInfo: data,
      isPulUpPay: true
    }
    if (type === OrderType.TRAIN) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PLANE_PENDING_PAYMENT_PAGE,
        param: param
      })
    }
    if (type === OrderType.AIRPLANE) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.TICKET_PENDING_PAYMENT_PAGE,
        param: param
      })
    }
    if (type === OrderType.BUS) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CITY_SELECT_RETURN_PAGE,
        param: param
      })
    }
  }

  // 酒店去付款，跳转到订单详情页，拉起支付弹框
  hotelGoPay(data: OrderInfo) {
    let param: TourOrderRouterParam = {
      orderInfo: data,
      isPulUpPay: true
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.HOTEL_ORDER_DETAIL_PAGE,
      param: param
    })
  }

  // 景点去付款，跳转到景点订单详情页，拉起支付弹框
  scenicGoPay(data: OrderInfo) {
    data.passengerInfo = this.passengerInfo
    let param: TourOrderRouterParam = {
      orderInfo: data,
      isPulUpPay: true
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TOUR_ORDER_DETAIL_PAGE,
      param: param
    })
  }

  // 支付成功后更新数据
  hotelPayedData() {
    this.getStatusText()
    this.context.eventHub.emit('orderStatusChange');
    this.pushHotelOrderMessage(this.detailInfo)
  }

  // 酒店消息推送
  pushHotelOrderMessage(detailInfo: OrderDetailInfo) {
    let messageData = OrderUtil.getHotelOrderMessage(detailInfo, this.status, this.statusText)
    this.messageList.add(messageData)
  }

  hotelFinish() {
    this.status = OrderStatus.FINISHED
    this.getStatusText()
    this.context.eventHub.emit('orderStatusChange');
  }

  // 景点去付款，支付成功后更新数据
  scenicPayedData() {
    this.status = OrderStatus.BOOKED
    this.getStatusText()
    this.context.eventHub.emit('orderStatusChange');
    this.pushScenicOrderMessage(this.detailInfo)
  }

  // 景点已完成
  scenicFinish() {
    this.status = OrderStatus.FINISHED
    this.getStatusText()
    this.context.eventHub.emit('orderStatusChange');
  }

  // 车票已完成
  ticketFinish() {
    this.status = OrderStatus.FINISHED
    this.getStatusText()
    this.context.eventHub.emit('orderStatusChange');
  }

  // 车票支付成功后更新数据
  ticketPayedData(type: OrderType) {
    this.status = OrderStatus.ISSUED
    this.getStatusText()
    this.context.eventHub.emit('orderStatusChange');
    // 推送车票支付成功的消息
    if (this.status === OrderStatus.ISSUED) {
      this.pushTicketOrderMessage(type, this.detailInfo)
    }
  }

  // 车票消息推送
  pushTicketOrderMessage(type: OrderType, detailInfo: OrderDetailInfo) {
    let messageData = OrderUtil.getTicketOrderMessage(type, detailInfo, this.status, this.statusText)
    this.messageList.add(messageData)
  }

  // 景点推送消息(状态为已退款、已预订是需要推送消息)
  pushScenicOrderMessage(detailInfo: OrderDetailInfo) {
    let messageData = OrderUtil.getScenicOrderMessage(detailInfo, this.status, this.statusText)
    this.messageList.add(messageData)
  }

  // 获取订单状态文本
  private getStatusText() {
    switch (this.status) {
      case OrderStatus.FINISHED:
        this.statusText = '已完成'
        break;
      case OrderStatus.ISSUED:
        this.statusText = '已出票'
        break;
      case OrderStatus.BOOKED:
        this.statusText = '已预定'
        break;
      case OrderStatus.PENDING:
        this.statusText = '待付款'
        break;
      case OrderStatus.CANCEL:
        this.statusText = '已取消'
        break;
      case OrderStatus.REFUNDED:
        this.statusText = '已退票'
        break;
    }
  }

  // 获取图标
  getIcon() {
    switch (this.type) {
      case OrderType.TRAIN:
        this.icon = this.isShowGray() ? $r('app.media.ic_train_gray') : $r('app.media.ic_train')
        break;
      case OrderType.BUS:
        this.icon = this.isShowGray() ? $r('app.media.ic_train_gray') : $r('app.media.ic_train')
        break;
      case OrderType.SCENIC:
        this.icon = this.isShowGray() ? $r('app.media.ic_scenic_gray') : $r('app.media.ic_scenic')
        break;
      case OrderType.HOTEL:
        this.icon = this.isShowGray() ? $r('app.media.ic_hotel_gray') : $r('app.media.ic_hotel')
        break;
      case OrderType.AIRPLANE:
        this.icon = this.isShowGray() ? $r('app.media.ic_airplane_gray') : $r('app.media.ic_airplane')
        break;
    }
  }
}


// 我的订单
@ObservedV2
export class MyOrderList {
  @Trace list: OrderInfo[] = []

  initMockData() {
    this.list =
      [
        new OrderInfo(OrderType.SCENIC, 2654, '丽江+大理市4日3晚拼小团·【9人小团新升级】雪山下的纳西古村落【玉湖村&】',
          OrderStatus.BOOKED),
        new OrderInfo(OrderType.HOTEL, 703, '惠众涌祥酒店（北京育新地铁站店）', OrderStatus.FINISHED),
        new OrderInfo(OrderType.HOTEL, 703, '惠众涌祥酒店（北京育新地铁站店）', OrderStatus.CANCEL),
        new OrderInfo(OrderType.AIRPLANE, 406, '', OrderStatus.ISSUED),
        new OrderInfo(OrderType.AIRPLANE, 406, '', OrderStatus.REFUNDED),
        new OrderInfo(OrderType.TRAIN, 406, ''),
        new OrderInfo(OrderType.TRAIN, 406, '北京-上海', OrderStatus.ISSUED),
        new OrderInfo(OrderType.BUS, 406, '', OrderStatus.ISSUED),
      ]
  }

  add(data: OrderInfo) {
    this.list.unshift(data)
  }

  deleteById(id: string) {
    this.list = this.list.filter(item => item.id !== id)
  }

  // 获取待付款订单数量
  getPendingOrderNum() {
    return this.list.filter(item => item.status === OrderStatus.PENDING).length
  }

  // 获取未出行订单数量
  getUntraveledOrderNum() {
    return this.list.filter(item => [OrderStatus.BOOKED, OrderStatus.ISSUED].includes(item.status)).length
  }
}