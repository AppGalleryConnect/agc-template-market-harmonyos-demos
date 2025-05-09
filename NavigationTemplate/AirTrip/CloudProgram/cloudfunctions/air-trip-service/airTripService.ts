import { CloudDbZoneWrapper } from './CloudDBZoneWrapper';

let myHandler = async function (event, context, callback, logger) {
  logger.info(event);

  let result;
  let operation = event.body ? JSON.parse(event.body).operation:event.operation;
  // 用户登录token
  let authorizationCode = event.body?JSON.parse(event.body).authorizationCode : event.authorizationCode;
  // 用户信息
  let userData = event.body?JSON.parse(event.body).userData : event.userData;
  // 乘机人
  let passengerData = event.body ? JSON.parse(event.body).passengerData : event.passengerData;
  // 查询订单列表
  let status = event.body ? JSON.parse(event.body).status : event.status;
  // 订单
  let orderData = event.body ? JSON.parse(event.body).orderData : event.orderData;
  // 订单编号
  let orderNo = event.body ? JSON.parse(event.body).orderNo : event.orderNo;
  // 行程
  let tripData = event.body ? JSON.parse(event.body).tripData : event.tripData;
  // 查询行程详情
  let tripId = event.body ? JSON.parse(event.body).tripId : event.tripId;
  // 查询航班动态列表
  let flightParamData = event.body ? JSON.parse(event.body).flightParamData : event.flightParamData;
  // 查询航班动态详情
  let flightNo = event.body ? JSON.parse(event.body).flightNo : event.flightNo;

  let cloudDBZoneWrapper = new CloudDbZoneWrapper();
  switch (operation) {
    // 用户登录
    case "userLogin":
      result = await cloudDBZoneWrapper.userLogin(authorizationCode);
      break;
    case 'upsertUserInfo':
      result = await cloudDBZoneWrapper.upsertUserInfo(userData);
      break;
      // 查询乘机人列表
    case "queryPassengerList":
      result = await cloudDBZoneWrapper.queryPassengers();
      break;
      // 新增或修改乘机人
    case "upsertPassenger":
      result = await cloudDBZoneWrapper.upsertPassenger(passengerData);
      break;
    case "update":
      result = await cloudDBZoneWrapper.updatePassenger(passengerData);
      break;
      // 删除乘机人
    case "deletePassenger":
      result = await cloudDBZoneWrapper.deletePassenger(passengerData);
      break;
      // 查询订单列表
    case "queryOrderList":
      result = await cloudDBZoneWrapper.queryOrderList(status);
      break;
      // 查询订单详情
    case "queryOrderDetail":
      result = await cloudDBZoneWrapper.queryOrderDetail(orderNo);
      break;
      // 新增或修改订单
    case "upsertOrder":
      result = await cloudDBZoneWrapper.upsertOrder(orderData);
      break;
      // 删除订单
    case "deleteOrder":
      result = await cloudDBZoneWrapper.deleteOrder(orderData);
      break;
      // 取消订单
    case "cancelOrder":
      result = await cloudDBZoneWrapper.cancelOrder(orderData);
      break;
      // 查询行程列表
    case "queryTripList":
      result = await cloudDBZoneWrapper.queryTripList();
      break;
      // 新增行程
    case "upsertTrip":
      result = await cloudDBZoneWrapper.upsertTrip(tripData);
      break;
      // 查询行程详情
    case "queryTripDetail":
      result = await cloudDBZoneWrapper.queryTripDetail(tripId);
      break;
      // 查询航班动态列表
    case "queryFlightList":
      result = await cloudDBZoneWrapper.queryFlightList(flightParamData);
      break;
      // 查询航班动态详情
    case "queryFlightDetail":
      result = await cloudDBZoneWrapper.queryFlightDetail(flightNo);
      break;
    default:
      callback({
        ret: {
          code: -1,
          desc: "no such operation."
        }
      });
      break;
  }

  callback({
    ret: {
      code: 0,
      desc: "Success."
    },
    result
  });
};

export { myHandler };