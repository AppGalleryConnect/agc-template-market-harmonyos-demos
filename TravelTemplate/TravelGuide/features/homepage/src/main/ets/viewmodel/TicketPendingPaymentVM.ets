import {
  MyOrderList,
  OrderInfo,
  OrderStatus,
  OrderType,
  PlaneDetailListModel,
  PlaneReturnDetailListModel,
  TicketReturnDetailListModel,
  TravelerModel,
  TicketDetailListModel
} from 'common_travel_guide'
import { AppStorageV2 } from '@kit.ArkUI';


@ObservedV2
export class TicketPendingPaymentVM {
  @Trace orderInfo: OrderInfo = new OrderInfo(OrderType.AIRPLANE, 406, '', OrderStatus.ISSUED);
  @Trace orderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Trace dataInfo: TicketReturnDetailListModel = new TicketReturnDetailListModel()
  @Trace dataPlaneInfo: PlaneReturnDetailListModel = new PlaneReturnDetailListModel()
  @Trace dataBusInfo: PlaneDetailListModel = new PlaneDetailListModel()
  @Trace clickIndex: number = 0
  @Trace clickReturnIndex: number = 0
  @Trace totalPrice: number = 0
  @Trace goPrice: number = 0
  @Trace backPrice: number = 0
  @Trace phoneText: string | null = null
  @Trace peopleList: TravelerModel[] = []
  @Trace paymentTime: string = '30:00'
  @Trace interval: number = 0;
  @Trace goIconBoolen: boolean = false
  @Trace backIconBoolen: boolean = false
  @Trace countdownMinutes: number = 30; // 设置倒计时为30分钟
  @Trace goHeight: number = 170
  @Trace backHeight: number = 170
  @Trace laterPayTime: Date = new Date()
  @Trace countDownTime: string = ''
  @Trace isPayment:boolean = false

  // 取消订单
  cancelOrder() {
    this.getTime(0)
    if (this.orderInfo.type === OrderType.AIRPLANE) {
      this.orderInfo.status = OrderStatus.CANCEL
      this.dataInfo.ticketGo.status = OrderStatus.CANCEL
      if (this.orderInfo.detailInfo && this.orderInfo.detailInfo.ticketGo) {
        this.orderInfo.detailInfo.ticketGo.status = OrderStatus.CANCEL as OrderStatus
      }
    }
    if (this.orderInfo.type === OrderType.TRAIN) {
      this.orderInfo.status = OrderStatus.CANCEL
      this.dataPlaneInfo.planeGo.status = OrderStatus.CANCEL
      if (this.orderInfo.detailInfo && this.orderInfo.detailInfo.planeGo) {
        this.orderInfo.detailInfo.planeGo.status = OrderStatus.CANCEL as OrderStatus
      }
    }
    if (this.orderInfo.type === OrderType.BUS) {
      this.orderInfo.status = OrderStatus.CANCEL
      this.dataBusInfo.status = OrderStatus.CANCEL
      if (this.orderInfo.detailInfo && this.orderInfo.detailInfo.busGo) {
        this.orderInfo.detailInfo.busGo.status = OrderStatus.CANCEL as OrderStatus
      }
    }
    this.orderInfo.ticketCancelOrder()
  }

  // 30分钟倒计时
  getTime(time: number) {
    if (time > 0) {
      let countdownTime = time * 60; // 转换为秒
      this.interval = setInterval(() => {
        if (countdownTime > 0) {
          countdownTime--;
          this.paymentTime =
            `${Math.floor(countdownTime / 60)}:${(countdownTime % 60).toString().padStart(2, '0')}`
        } else {
          clearInterval(this.interval);
          this.paymentTime = ''
        }
      }, 1000);
    } else {
      clearInterval(this.interval);
      this.paymentTime = ''
    }
  }

  getDate() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1; // 月份从0开始，需要加1
    const day = now.getDate();
    return `${year}-${month}-${day}`
  }

  creatOrderNumber() {
    const now = new Date().getTime().toString();
    return now
  }

  getThirtyMinutes() {
    // 获取30分钟后的时间
    const now = new Date();
    const futureTime = new Date(now.getTime() + 30 * 60 * 1000); // 当前时间 + 30分钟
    // 获取小时和分钟
    const hours = futureTime.getHours().toString().padStart(2, '0');
    const minutes = futureTime.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`
  }

  // 身份证脱敏
  maskedIdCard(idCard: string) {
    const reg = /^(.{3})(?:\d+)(.{3})$/;
    const maskedIdCard = idCard.replace(reg, '$1******$2');
    return maskedIdCard
  }

  // 判断车票是否过了预定期
  getIsExpirt() {
    // 获取当前年份
    let currentYear = new Date().getFullYear();
    let targetTime: string = ''
    if (this.orderInfo.type === OrderType.TRAIN) {
      // 设定一个具体时间
      targetTime = `${currentYear}-${this.dataPlaneInfo.planeGo.timeDate}T${this.dataPlaneInfo.planeGo.startDate}:00`
    }
    if (this.orderInfo.type === OrderType.AIRPLANE) {
      // 设定一个具体时间
      targetTime = `${currentYear}-${this.dataInfo.ticketGo.timeDate}T${this.dataInfo.ticketGo.startDate}:00`;
    }
    if (this.orderInfo.type === OrderType.BUS) {
      // 设定一个具体时间
      targetTime = `${currentYear}-${this.dataBusInfo.timeDate}T${this.dataBusInfo.startDate}:00`
    }
    // 获取当前时间
    const currentTime = new Date().getTime();
    // 比较时间
    if (currentTime > new Date(targetTime).getTime()) {
      return true
    } else {
      return true
    }
  }

  // 获取行程时间
  getTripTime() {
    // 定义开始时间和结束时间
    // 格式为 ISO 8601
    let startTime = ''
    let endTime = ''
    if (this.orderInfo.type === OrderType.AIRPLANE) {
      startTime = `2025-${this.dataInfo.ticketGo.timeDate}T${this.dataInfo.ticketGo.startDate}:00`;
      endTime = `2025-${this.dataInfo.ticketGo.timeDate}T${this.dataInfo.ticketGo.endDate}:00`; // 注意，这里是21:00，因为9点是晚上9点
    }
    if (this.orderInfo.type === OrderType.TRAIN) {
      startTime = `2025-${this.dataPlaneInfo.planeGo.timeDate}T${this.dataPlaneInfo.planeGo.startDate}:00`;
      endTime =
        `2025-${this.dataPlaneInfo.planeGo.timeDate}T${this.dataPlaneInfo.planeGo.endDate}:00`; // 注意，这里是21:00，因为9点是晚上9点
    }
    if (this.orderInfo.type === OrderType.BUS) {
      startTime = `2025-${this.dataBusInfo.timeDate}T${this.dataBusInfo.startDate}:00`;
      endTime = `2025-${this.dataBusInfo.timeDate}T${this.dataBusInfo.endDate}:00`; // 注意，这里是21:00，因为9点是晚上9点
    }
    // 转换为Date对象
    let start = new Date(startTime);
    let end = new Date(endTime);
    // 计算时间差（毫秒）
    let timeDiff = end.getTime() - start.getTime();
    // 将毫秒转换为小时（考虑到一天的毫秒数是24*60*60*1000）
    let hoursDiff = timeDiff / (1000 * 60 * 60) as number
    let data = hoursDiff.toFixed(1).toString().split('.');
    let timeData = data[0] + '小时' + Number(data[1]) * 6 + '分'
    return timeData
  }

  // 初始化数据
  initData() {
    this.dataInfo = {
      ticketGo: this.orderInfo?.detailInfo?.ticketGo as TicketDetailListModel,
      ticketBack: this.orderInfo?.detailInfo?.ticketBack as TicketDetailListModel
    } as TicketReturnDetailListModel
    if (this.orderInfo.getIsFinish()) {
      this.dataInfo.ticketGo.status = OrderStatus.FINISHED
      this.orderInfo.ticketFinish()
    }
    this.goPrice = Number(this.dataInfo?.ticketGo?.price)
    this.backPrice = Number(this.dataInfo?.ticketBack?.price)
    this.getTime(this.countdownMinutes)
    if (this.dataInfo?.ticketGo?.type === 1) {
      this.totalPrice =
        Number(this.dataInfo?.ticketGo?.price) + Number(this.dataInfo?.ticketBack?.price)
    } else {
      this.totalPrice = Number(this.dataInfo.ticketGo?.price)
    }
    // 如果是已取消状态，处理倒计时
    if (this.orderInfo.status === OrderStatus.PENDING) {
      this.getLaterPayTime()
      this.countTargetTime(this.laterPayTime)
    }
  }

  // 获取已取消状态时，需要在mm:ss之前完成交付
  getLaterPayTime() {
    // 对指定时间操作
    let beginTime = `${this.orderInfo.detailInfo.createDate} ${this.orderInfo.detailInfo.createTime}`
    let time = new Date(beginTime);
    time.setMinutes(time.getMinutes() + 30);
    this.laterPayTime = time;
    let hours = String(time.getHours()).padStart(2, '0');
    let minutes = String(time.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 到指定时间的倒计时
  countTargetTime(targetTime: Date) {
    const target = new Date(targetTime).getTime();
    const timer = setInterval(() => {
      const now = new Date().getTime();
      const distance = target - now;
      if (distance <= 0) {
        clearInterval(timer);
        // 倒计时结束，取消订单
        this.orderInfo.status = OrderStatus.CANCEL
        this.orderInfo.cancelOrder()
        return;
      }
      // 分、秒
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);
      this.countDownTime = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    }, 1000);
  }

  // 拉起支付后更新数据
  payFinishedUpdate() {
    this.dataInfo.ticketGo.status = OrderStatus.ISSUED
    this.orderInfo.status = OrderStatus.ISSUED
    this.orderInfo.upTicketDetail()
    this.orderInfo.ticketPayedData(OrderType.AIRPLANE)
  }
}
