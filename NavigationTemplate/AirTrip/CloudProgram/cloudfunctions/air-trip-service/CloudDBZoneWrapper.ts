import { cloud, CloudDBCollection, CloudDBZoneGenericObject,
  CloudDBZoneObjectOperator } from '@hw-agconnect/cloud-server';
import { getUserInfoByAccessToken } from './AxiosApi'
import { UserInfoRes } from './AxiosApi'
import { PassengerInfo } from './PassengerInfo';
import { OrderInfo } from './OrderInfo';
import { TripInfo } from './TripInfo';
import { UserInfo } from './UserInfo';
import { FlightInfo } from './FlightInfo';

// 这里的zone name必须与DataEntry中的CloudDBZoneName一致
const ZONE_NAME = "AirTripZone";

export class CloudDbZoneWrapper {
  passengerCollection: CloudDBCollection<PassengerInfo>;
  orderCollection: CloudDBCollection<OrderInfo>;
  tripCollection: CloudDBCollection<TripInfo>;
  userCollection: CloudDBCollection<UserInfo>;
  flightCollection: CloudDBCollection<FlightInfo>;

  constructor() {
    // 多个表需要有多个 collection
    this.passengerCollection = cloud.database({ zoneName: ZONE_NAME }).collection(PassengerInfo);
    this.orderCollection = cloud.database({ zoneName: ZONE_NAME }).collection(OrderInfo);
    this.tripCollection = cloud.database({ zoneName: ZONE_NAME }).collection(TripInfo);
    this.userCollection = cloud.database({ zoneName: ZONE_NAME }).collection(UserInfo);
    this.flightCollection = cloud.database({ zoneName: ZONE_NAME }).collection(FlightInfo);
  }

  // 用户登录
  async userLogin(authorizationCode: string) {
    const userInfo: UserInfoRes = await getUserInfoByAccessToken(authorizationCode)
    let query = this.userCollection.query().equalTo('authCode', userInfo.unionID+userInfo.mobileNumber);
    let queryRes = await query.get()
    if (queryRes.length) {
      return queryRes
    } else {
      await this.upsertUserInfo({
        idToken: userInfo.unionID+userInfo.mobileNumber,
        authCode: userInfo.unionID+userInfo.mobileNumber,
        userName: "华为用户",
        avatar: "",
        phoneNumber: userInfo.mobileNumber
      } as UserInfo)
      let query = this.userCollection.query().equalTo('authCode', userInfo.unionID+userInfo.mobileNumber);
      return await query.get()
    }
  }

  async upsertUserInfo(record: UserInfo) {
    return await this.userCollection.upsert(record);
  }

  // 查询
  async queryPassengers() {
    let query = this.passengerCollection.query();
    return await query.get();
  }

  // 新增
  async upsertPassenger(record: PassengerInfo) {
    return await this.passengerCollection.upsert(record);
  }

  // 更新
  async updatePassenger(record: PassengerInfo) {
    const passengerInfo = CloudDBZoneGenericObject.build("PassengerInfo");
    const operator = CloudDBZoneObjectOperator.build(passengerInfo)
      .update("name", record.name)
      .update("certificateType", record.certificateType)
      .update("certificateNo", record.certificateNo)
      .update("phone", record.phone)
    return await this.passengerCollection.update(operator);
  }

  // 删除乘机人
  async deletePassenger(record: PassengerInfo) {
    return await this.passengerCollection.delete(record);
  }

  // 查询订单列表
  async queryOrderList(status: string) {
    let query = this.orderCollection.query().orderByDesc('createTime')
    if (status) {
      return await query.equalTo('status', Number(status)).get();
    }
    return await query.get();
  }

  // 查询订单详情
  async queryOrderDetail(orderNo: string) {
    let query = this.orderCollection.query().equalTo("orderNo", orderNo)
    return await query.get();
  }

  // 新增或编辑订单
  async upsertOrder(record: OrderInfo) {
    return await this.orderCollection.upsert(record);
  }

  // 删除订单
  async deleteOrder(record: OrderInfo) {
    return await this.orderCollection.delete(record);
  }

  // 取消订单
  async cancelOrder(record: OrderInfo) {
    record.status = 0
    return await this.orderCollection.upsert(record);
  }

  // 查询行程列表
  async queryTripList() {
    let query = this.tripCollection.query();
    return await query.get();
  }

  // 新增行程
  async upsertTrip(record: TripInfo) {
    return await this.tripCollection.upsert(record);
  }

  // 查询订单详情
  async queryTripDetail(id: string) {
    let query = this.tripCollection.query().equalTo("id", id)
    return await query.get();
  }

  // 查询航班动态列表
  async queryFlightList(flightParamData: Record<string, string>) {
    let query = this.flightCollection.query()
      .equalTo("departureCity", flightParamData['departureCity'])
      .equalTo("destinationCity", flightParamData['destinationCity'])
      .contains("takeoffTime", flightParamData['departureDate'])
    return await query.get();
  }

  // 查询航班动态详情
  async queryFlightDetail(flightNo: string) {
    let query = this.flightCollection.query().contains("flightNo", flightNo)
    return await query.get();
  }
}