import { Constant, Logger } from 'common';
import { CommodityOrderListItem, TicketOrderListItem, GetTouristListResp, GetOrderDetailRequest, https } from 'network';
import { CommodityOrderInfo, TicketOrderInfo, TouristInfo } from 'types';

export function mapperTicketOrderList(getTicketOrderListResp: ESObject) {
  let ticketOrderList: TicketOrderListItem[] = [];
  getTicketOrderListResp.forEach((item: ESObject) => {
    // 订单为未支付状态
    if (item.orderStatus === 1) {
      let curStamp = new Date().getTime();
      let createStamp = new Date(item.orderTime).getTime();
      let count = createStamp + Constant.MAX_TO_PAY_TIME - curStamp;
      if (count < 0) {
        item.orderStatus = 3;
        let param = {
          category: 0,
          orderNo: item.orderNo,
          orderStatus: item.orderStatus,
        } as GetOrderDetailRequest;
        https.modifyOrderDetail(param).then((res: ESObject) => {
          if (res.code === 0) {
            Logger.info('update order status success');
          }
        });
      }
    }

    let ticketOrderInfo: TicketOrderListItem = {
      orderNo: item.orderNo,
      orderTime: item.orderTime,
      orderStatus: item.orderStatus,
      count: item.count,
      touristId: item.touristId,
      contactId: item.contactId,
      productName: item.productName,
      productPrice: item.productPrice,
      discount: item.discount,
      amount: item.amount,
      startTime: item.startTime,
      endTime: item.endTime,
    };

    ticketOrderList.push(ticketOrderInfo);
  });
  return ticketOrderList;
}

export function mapTicketOrderDetail(getTicketOrderDetailResp: ESObject) {
  let ticketOrderInfo = new TicketOrderInfo();
  ticketOrderInfo.orderNo = getTicketOrderDetailResp.orderNo;
  ticketOrderInfo.orderTime = getTicketOrderDetailResp.orderTime;
  ticketOrderInfo.orderStatus = getTicketOrderDetailResp.orderStatus;
  ticketOrderInfo.count = getTicketOrderDetailResp.count;
  ticketOrderInfo.touristId = getTicketOrderDetailResp.touristId;
  ticketOrderInfo.contactId = getTicketOrderDetailResp.contactId;
  ticketOrderInfo.productName = getTicketOrderDetailResp.productName;
  ticketOrderInfo.productPrice = getTicketOrderDetailResp.productPrice;
  ticketOrderInfo.discount = getTicketOrderDetailResp.discount;
  ticketOrderInfo.amount = getTicketOrderDetailResp.amount;
  ticketOrderInfo.startTime = getTicketOrderDetailResp.startTime;
  ticketOrderInfo.endTime = getTicketOrderDetailResp.endTime;
  return ticketOrderInfo;
}

export function mapCommodityOrderDetail(getCommodityOrderDetailResp: ESObject) {
  let commodityOrderInfo = new CommodityOrderInfo();
  commodityOrderInfo.orderNo = getCommodityOrderDetailResp.orderNo;
  commodityOrderInfo.orderTime = getCommodityOrderDetailResp.orderTime;
  commodityOrderInfo.orderStatus = getCommodityOrderDetailResp.orderStatus;
  commodityOrderInfo.count = getCommodityOrderDetailResp.count;
  commodityOrderInfo.productName = getCommodityOrderDetailResp.productName;
  commodityOrderInfo.discount = getCommodityOrderDetailResp.discount;
  commodityOrderInfo.amount = getCommodityOrderDetailResp.amount;
  commodityOrderInfo.disCountPrice = getCommodityOrderDetailResp.disCountPrice;
  commodityOrderInfo.spuName = getCommodityOrderDetailResp.spuName;
  commodityOrderInfo.banner = getCommodityOrderDetailResp.banner;
  commodityOrderInfo.originalPrice = getCommodityOrderDetailResp.originalPrice;
  commodityOrderInfo.phone = getCommodityOrderDetailResp.phone;
  return commodityOrderInfo;
}

export function mapperCommodityOrderList(getCommodityOrderListResp: ESObject) {
  let commodityOrderList: CommodityOrderListItem[] = [];
  getCommodityOrderListResp.forEach((item: ESObject) => {
    if (item.orderStatus === 1) {
      let curStamp = new Date().getTime();
      let createStamp = new Date(item.orderTime).getTime();
      let count = createStamp + Constant.MAX_TO_PAY_TIME - curStamp;
      if (count < 0) {
        item.orderStatus = 3;
        let param = {
          category: 1,
          orderNo: item.orderNo,
          orderStatus: item.orderStatus,
        } as GetOrderDetailRequest;
        https.modifyOrderDetail(param).then((res: ESObject) => {
          if (res.code === 0) {
            Logger.info('update order status success');
          }
        });
      }
    }


    let commodityOrderInfo: CommodityOrderListItem = {
      orderNo: item.orderNo,
      orderTime: item.orderTime,
      orderStatus: item.orderStatus,
      addressId: item.addressId,
      couponId: item.couponId,
      count: item.count,
      productName: item.productName,
      disCountPrice: item.disCountPrice,
      freight: 0,
      amount: item.amount,
      discount: item.discount,
      banner: item.banner,
      phone: item.phone,
      originalPrice: item.originalPrice,
      spuName: item.spuName,
    };
    commodityOrderList.push(commodityOrderInfo);
  });
  return commodityOrderList;
}

export function mapTouristList(getTouristListResp: GetTouristListResp) {
  let touristList: TouristInfo[] = [];
  getTouristListResp.forEach((item: ESObject) => {
    let touristInfo = new TouristInfo();
    touristInfo.id = item.id;
    touristInfo.name = item.name;
    touristInfo.phone = item.phone;
    touristInfo.cardType = item.cardType;
    touristInfo.cardNo = item.cardNo;
    touristList.push(touristInfo);
  });
  return touristList;
}

