import { MessageItem } from '../model/MessageModel';
import { OrderDetailInfo, OrderStatus, OrderType } from '../model/OrderModel';

export class OrderUtil {
  // 获取订单状态文本
  static getOrderStatusText(status: OrderStatus) {
    let statusText: string = ''
    switch (status) {
      case OrderStatus.FINISHED:
        statusText = '已完成'
        break;
      case OrderStatus.ISSUED:
        statusText = '已出票'
        break;
      case OrderStatus.BOOKED:
        statusText = '已预定'
        break;
      case OrderStatus.PENDING:
        statusText = '待付款'
        break;
      case OrderStatus.CANCEL:
        statusText = '已取消'
        break;
      case OrderStatus.REFUNDED:
        statusText = '已退票'
        break;
      default:
        break;
    }
    return statusText;
  }

  // 获取订单状态文本
  static getPayTypeText(payType: string) {
    let payTypeText: string = ''
    switch (payType) {
      case 'alipay':
        payTypeText = '支付宝'
        break;
      case 'huawei':
        payTypeText = '华为支付'
        break;
      case 'wechat':
        payTypeText = '微信支付'
        break;
      default:
        break;
    }
    return payTypeText;
  }

  static getMessageTitle(status: OrderStatus, orderType: OrderType) {
    let title: string = ''
    if (orderType === OrderType.SCENIC) {
      switch (status) {
        case OrderStatus.BOOKED:
          title = '出行提醒'
          break;
        case OrderStatus.REFUNDED:
          title = '旅游景点提醒'
          break;
        default:
          break;
      }
    } else if (orderType === OrderType.HOTEL) {
      switch (status) {
        case OrderStatus.BOOKED:
          title = '酒店行程提醒'
          break;
        case OrderStatus.REFUNDED:
          title = '酒店行程提醒'
          break;
        default:
          break;
      }
    }
    return title;
  }


  // 获取景点推送消息内容
  static getScenicOrderMessage(detailInfo: OrderDetailInfo, orderStatus: OrderStatus, orderStatusText: string) {
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const now = new Date();
    const id = `SCENICORDER${now.getTime().toString()}`;
    const date = `${now.getFullYear()}-${pad2(now.getMonth() + 1)}-${pad2(now.getDate())}`;
    const time = `${pad2(now.getHours())}:${pad2(now.getMinutes())}:${pad2(now.getSeconds())}`;
    const createTime = `${date} ${time}`
    let title: string = OrderUtil.getMessageTitle(orderStatus, OrderType.SCENIC)
    let scenicCreateDate: string = detailInfo?.scenicCreateDate || '';
    let priceText: string = ''
    if (orderStatus === OrderStatus.REFUNDED) {
      priceText = `退款金额：${detailInfo.scenicRefundPrice}元`
    } else if (orderStatus === OrderStatus.BOOKED) {
      priceText = `支付金额：${detailInfo.scenicPayTotalPrice}元`
    }
    let content: string = `${detailInfo.scenicTitle}，下单时间：${scenicCreateDate}` +
      `，订单号：${detailInfo.scenicOrderNum}，${priceText}，${orderStatusText}`
    let messageData: MessageItem = new MessageItem(id, title, createTime, content)
    return messageData
  }

  // 获取酒店推送消息内容
  static getHotelOrderMessage(detailInfo: OrderDetailInfo, orderStatus: OrderStatus, orderStatusText: string) {
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const now = new Date();
    const id = `SCENICORDER${now.getTime().toString()}`;
    const date = `${now.getFullYear()}-${pad2(now.getMonth() + 1)}-${pad2(now.getDate())}`;
    const time = `${pad2(now.getHours())}:${pad2(now.getMinutes())}:${pad2(now.getSeconds())}`;
    const createTime = `${date} ${time}`
    let title: string = OrderUtil.getMessageTitle(orderStatus, OrderType.HOTEL)
    let text = ''
    if (orderStatus === OrderStatus.REFUNDED) {
      text = '退款金额'
    }
    if (orderStatus === OrderStatus.BOOKED) {
      text = '支付金额'
    }
    let content: string =
      `${detailInfo.hotelName}，下单时间：${detailInfo.createDate}，订单号：${detailInfo.id}， ${text}：${detailInfo.totalPrice}元,${orderStatusText}`
    let messageData: MessageItem = new MessageItem(id, title, createTime, content)
    return messageData
  }

  // 获取车票推送消息内容
  static getTicketOrderMessage(type: OrderType, detailInfo: OrderDetailInfo, orderStatus: OrderStatus,
    orderStatusText: string) {
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const now = new Date();
    const id = `SCENICORDER${now.getTime().toString()}`;
    const date = `${now.getFullYear()}-${pad2(now.getMonth() + 1)}-${pad2(now.getDate())}`;
    const time = `${pad2(now.getHours())}:${pad2(now.getMinutes())}:${pad2(now.getSeconds())}`;
    const createTime = `${date} ${time}`
    let ticketCreateDate: string = ''
    let priceText: string = ''
    let content: string = ''
    let trainTypeContent: string = ''
    let returnPrice: string = ''
    let ticketOrderNum: string = ''
    if (type === OrderType.TRAIN) {
      trainTypeContent = `，车次：${detailInfo.planeGo?.trainNumber}，${detailInfo.planeGo?.seatClass}`
      returnPrice = detailInfo.planeGo?.returnPrice as string
      ticketOrderNum = detailInfo.planeGo?.ticketOrderNum as string
      ticketCreateDate = detailInfo.planeGo?.ticketCreateDate as string;
    } else if (type === OrderType.AIRPLANE) {
      returnPrice = detailInfo.ticketGo?.returnPrice as string
      ticketOrderNum = detailInfo.ticketGo?.ticketOrderNum as string
      ticketCreateDate = detailInfo.ticketGo?.ticketCreateDate as string;
      trainTypeContent = `，航班：${detailInfo.ticketGo?.aviation}，${detailInfo.ticketGo?.cabinClass}`
    } else {
      ticketOrderNum = detailInfo.busGo?.ticketOrderNum as string
      ticketCreateDate = detailInfo.busGo?.ticketCreateDate as string;
      returnPrice = detailInfo.busGo?.returnPrice as string
    }

    if (orderStatus === OrderStatus.REFUNDED) {
      priceText = `退款金额：${returnPrice}元`
      content = `出发地：${detailInfo.departurePlace}，目的地：${detailInfo.destination}，下单时间：${ticketCreateDate}` +
        `，订单号：${ticketOrderNum}，${priceText}，${orderStatusText}`
    }
    if (orderStatus === OrderStatus.ISSUED) {
      priceText = `支付金额：${returnPrice}元`
      content =
        `出发地：${detailInfo.departurePlace}，目的地：${detailInfo.destination}${trainTypeContent}，下单时间：${ticketCreateDate}` +
          `，订单号：${ticketOrderNum}，${priceText}，${orderStatusText}`
    }

    let messageData: MessageItem = new MessageItem(id, '出行提醒', createTime, content)
    return messageData
  }

  // 身份证证件号，中间数据使用*****代替
  static maskedIdCard(idCard: string) {
    const reg = /^(.{3})(?:\d+)(.{3})$/;
    const maskedIdCard = idCard.replace(reg, '$1******$2');
    return maskedIdCard
  }
}