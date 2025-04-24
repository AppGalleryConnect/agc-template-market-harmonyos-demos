import { GetBulletinListResp } from '../types/responseTypes/GetBulletinListResp';
import { BaseResponse } from '../types/ResponseTypes';
import { bulletinListMock } from './mockData/getBulletinList';
import { GetHomeInfoResp } from '../types/responseTypes/GetHomeRollUpInfoResp';
import { homeRollupInfoMock } from './mockData/getRollupInfo';
import { GetAttractionsInfoResp } from '../types/responseTypes/GetAttractionListResp';
import { attractionListMock } from './mockData/getAttractionList';
import { ticketListMock } from './mockData/getTicketList';
import { GetTicketListResp } from '../types/responseTypes/GetTicketListResp';
import { noteListMock } from './mockData/getNoteList';
import { GetNoteListResp } from '../types/responseTypes/GetNoteListResp';
import { GetRouteLineListResp } from '../types/responseTypes/GetRouteListResp';
import { routeListMock } from './mockData/getRouteList';
import { GetCommodityListResp } from '../types/responseTypes/GetCommodityListResp';
import { specialCommodityListMock } from './mockData/getSpecialCommodityList';
import { culturalCommodityListMock } from './mockData/getCulturalCommodityList';
import { GetBulletinDetailResp } from '../types/responseTypes/GetBulletinDetailResp';
import { bulletinDetailList } from './mockData/getBulletinDetail';
import { commodityDetailList } from './mockData/getCommodityDetail';
import { GetCommodityDetailResp } from '../types/responseTypes/GetCommodityDetailResp';
import { attractionDetailsMock } from './mockData/getAttractionDetail';
import { GetAttractionDetailResp } from '../types/responseTypes/GetAttractionDetailResp';
import { GetTicketDetailResp } from '../types/responseTypes/GetTicketDetailResp';
import { ticketDetailListMock } from './mockData/getTicketDetail';
import { GetNoteDetailResp } from '../types/responseTypes/GetNoteDetailResp';
import { noteDetailListMock } from './mockData/getNoteDetail';
import { routeDetailListMock } from './mockData/getRouteDetail';
import { GetRouteLineDetailResp } from '../types/responseTypes/GetRouteDetailResp';
import {
  AddressRequest,
  CreateCommodityOrderRequest,
  CreateTicketOrderRequest,
  GetOrderDetailRequest,
  TouristRequest,
} from '../types/AxiosRequestParam';
import { CommodityOrderListItem, GetCommodityOrderListResp } from '../types/responseTypes/GetCommodityOrderListResp';
import { GetTicketOrderListResp, TicketOrderListItem } from '../types/responseTypes/GetTicketOrderListResp';
import { AppStorageV2 } from '@kit.ArkUI';
import { GetTouristListResp, TouristListItem } from '../types/responseTypes/GetTouristListResp';
import { GetCateringDetailResp } from '../types/responseTypes/GetCateringDetailResp';
import { cateringDetailMock } from './mockData/getCateringDetail';
import { accommodationDetailMock } from './mockData/getAccommodationDetail';
import { GetAccommodationDetailResp } from '../types/responseTypes/GetAccommodationDetailResp';
import { AddressListItem, GetAddressListResp } from '../types/responseTypes/GetAddressListResp';

class HttpApiMock {
  static addressListMock: GetAddressListResp =
    AppStorageV2.connect(GetAddressListResp, 'GetAddressListResp', () => new GetAddressListResp()) ?? [];
  static touristListMock: GetTouristListResp =
    AppStorageV2.connect(GetTouristListResp, 'GetTouristListResp', () => new GetTouristListResp()) ?? [];
  static commodityOrderListMock: GetCommodityOrderListResp =
    AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp',
      () => new GetCommodityOrderListResp()) ?? [];
  static ticketOrderListMock: GetTicketOrderListResp =
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => new GetTicketOrderListResp()) ?? [];

  public getBulletinList(): Promise<BaseResponse<GetBulletinListResp>> {
    return Promise.resolve(bulletinListMock);
  }

  public getBulletinDetail(bulletinId: number): Promise<BaseResponse<GetBulletinDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: bulletinDetailList.find((item) => item.id === bulletinId),
    } as BaseResponse<GetBulletinDetailResp>);
  }

  public getHomeRollupInfo(): Promise<BaseResponse<GetHomeInfoResp>> {
    return Promise.resolve(homeRollupInfoMock);
  }

  public getAttractionList(): Promise<BaseResponse<GetAttractionsInfoResp>> {
    return Promise.resolve(attractionListMock);
  }

  public getAttractionDetail(attractionId: number): Promise<BaseResponse<GetAttractionDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: attractionDetailsMock.find(item => item.attractionId === attractionId),
    } as BaseResponse<GetAttractionDetailResp>);
  }

  public getTicketList(): Promise<BaseResponse<GetTicketListResp>> {
    return Promise.resolve(ticketListMock);
  }

  public getTicketDetail(ticketId: number): Promise<BaseResponse<GetTicketDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: ticketDetailListMock.find(item => item.ticketId === ticketId),
    } as BaseResponse<GetTicketDetailResp>);
  }

  public getNoteList(): Promise<BaseResponse<GetNoteListResp>> {
    return Promise.resolve(noteListMock);
  }

  public getNoteDetail(nodeId: number): Promise<BaseResponse<GetNoteDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: noteDetailListMock.find(item => item.noteId === nodeId),
    } as BaseResponse<GetNoteDetailResp>);
  }

  public getRouteList(): Promise<BaseResponse<GetRouteLineListResp>> {
    return Promise.resolve(routeListMock);
  }

  public getRouteDetail(routeId: number): Promise<BaseResponse<GetRouteLineDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: routeDetailListMock.find(item => item.routeId === routeId),
    } as BaseResponse<GetRouteLineDetailResp>);
  }

  public getCommodityList(category: number): Promise<BaseResponse<GetCommodityListResp>> {
    return category === 0 ? Promise.resolve(specialCommodityListMock) : Promise.resolve(culturalCommodityListMock);
  }

  public getCommodityDetail(commodityId: number): Promise<BaseResponse<GetCommodityDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: commodityDetailList.find((item) => item.commodityId === commodityId),
    } as BaseResponse<GetCommodityDetailResp>);
  }

  public createCommodityOrder(data: CreateCommodityOrderRequest) {
    let commodityOrderList: GetCommodityOrderListResp =
      AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp',
        () => new GetCommodityOrderListResp())!;
    let commodityOrder: CommodityOrderListItem = {
      banner: data.banner,
      orderNo: data.orderNo,
      orderTime: data.orderTime,
      orderStatus: data.orderStatus,
      addressId: data.addressId,
      couponId: 0,
      count: data.count,
      productName: data.productName,
      disCountPrice: data.disCountPrice,
      originalPrice: data.originalPrice,
      spuName: data.spuName,
      freight: 0,
      amount: data.amount,
      discount: 0,
      phone: '12345678911',
    };

    if (commodityOrderList) {
      commodityOrderList.unshift(commodityOrder);
      AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp', () => commodityOrderList);
    } else {
      AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp', () => [commodityOrder]);
    }
    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public getCateringDetail(siteId: string) {
    const resp: BaseResponse<GetCateringDetailResp> = {
      code: 0,
      data: cateringDetailMock,
    };
    return Promise.resolve(resp);
  }

  public getAccommodationDetail(siteId: string) {
    const resp: BaseResponse<GetAccommodationDetailResp> = {
      code: 0,
      data: accommodationDetailMock,
    };
    return Promise.resolve(resp);
  }

  public createTicketOrder(data: CreateTicketOrderRequest) {
    let ticketOrderList: GetTicketOrderListResp =
      AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => new GetTicketOrderListResp())!;
    let ticketOrder: TicketOrderListItem = {
      orderNo: data.orderNo,
      orderTime: data.orderTime,
      orderStatus: data.orderStatus,
      count: data.count,
      touristId: data.touristId,
      contactId: data.contactId,
      productName: data.productName,
      productPrice: data.productPrice,
      discount: 0,
      amount: data.productPrice * data.count,
      startTime: data.startTime,
      endTime: data.endTime,
    };

    if (ticketOrderList) {
      ticketOrderList.unshift(ticketOrder);
      AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => ticketOrderList);
    } else {
      AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => [ticketOrder]);
    }

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  static getTouristDetail(touristsId: string[]): GetTouristListResp {
    let touristList: GetTouristListResp = [];
    touristsId.forEach(item => {
      let list = HttpApiMock.touristListMock.filter((touristId) => touristId.id === item);
      touristList.push(...list);
    });
    return touristList;
  }

  public getOrderList(param: GetOrderDetailRequest) {
    const resp: BaseResponse<ESObject> = {
      code: 0,
      data: param.category === 0 ? HttpApiMock.getTicketOrderList(param.orderStatus ?? 0) :
      HttpApiMock.getCommodityOrderList(param.orderStatus ?? 0),
    };

    return Promise.resolve(resp);
  }

  public modifyOrderDetail(param: GetOrderDetailRequest) {
    param.category === 0 ? HttpApiMock.modifyTicketOrderDetail(param.orderStatus ?? 0, param.orderNo ?? '') :
    HttpApiMock.modifyCommodityOrderDetail(param.orderStatus ?? 0, param.orderNo ?? '');

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };

    return Promise.resolve(resp);
  }

  static modifyTicketOrderDetail(orderStatus: number, orderNo: string) {
    let list = HttpApiMock.ticketOrderListMock.filter(item => item.orderNo !== orderNo);
    let item = HttpApiMock.ticketOrderListMock.filter(item => item.orderNo === orderNo);
    item[0].orderStatus = orderStatus;
    list.unshift(item[0]);
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => list)!;
  }

  static modifyCommodityOrderDetail(orderStatus: number, orderNo: string) {
    let list = HttpApiMock.commodityOrderListMock.filter(item => item.orderNo !== orderNo);
    let item = HttpApiMock.commodityOrderListMock.filter(item => item.orderNo === orderNo);
    item[0].orderStatus = orderStatus;
    list.unshift(item[0]);
    AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp', () => list)!;
  }

  public getOrderDetail(param: GetOrderDetailRequest) {
    const resp: BaseResponse<ESObject> = {
      code: 0,
      data: param.category === 0 ? HttpApiMock.getTicketOrderDetail(param.orderNo ?? '') :
      HttpApiMock.getCommodityOrderDetail(param.orderNo ?? ''),
    };
    return Promise.resolve(resp);
  }

  static getCommodityOrderList(orderStatus: number) {
    if (orderStatus === 0) {
      return HttpApiMock.commodityOrderListMock;
    } else {
      return HttpApiMock.commodityOrderListMock.filter((item: CommodityOrderListItem) => item.orderStatus ===
        orderStatus);
    }
  }

  static getTicketOrderList(orderStatus: number) {
    if (orderStatus === 0) {
      return HttpApiMock.ticketOrderListMock;
    } else {
      return HttpApiMock.ticketOrderListMock.filter((item: TicketOrderListItem) => item.orderStatus === orderStatus);
    }
  }

  static getCommodityOrderDetail(orderNo: string) {
    return HttpApiMock.commodityOrderListMock.filter((item: CommodityOrderListItem) => item.orderNo === orderNo);
  }

  static getTicketOrderDetail(orderNo: string) {
    return HttpApiMock.ticketOrderListMock.filter((item: TicketOrderListItem) => item.orderNo === orderNo);
  }

  public modifyTourist(data: TouristRequest) {
    let tourist: TouristListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      cardType: data.cardType,
      cardNo: data.cardNo,
      isChecked: data.isChecked,
    };

    let index = HttpApiMock.touristListMock.findIndex(item => item.id === tourist.id);

    HttpApiMock.touristListMock.splice(index, 1, tourist);

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public deleteTourist(id: string) {
    let list = HttpApiMock.touristListMock.filter((item: TouristListItem) => item.id !== JSON.stringify(id));
    HttpApiMock.touristListMock = list;

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public createTourist(data: TouristRequest) {
    let tourist: TouristListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      cardType: data.cardType,
      cardNo: data.cardNo,
      isChecked: data.isChecked,
    };

    let isExist = HttpApiMock.touristListMock.some((item => item.id === tourist.id));

    if (HttpApiMock.touristListMock && !isExist) {
      HttpApiMock.touristListMock.push(tourist);
    } else {
      HttpApiMock.touristListMock = [tourist];
    }

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public createAddress(data: AddressRequest) {
    // 为默认地址，清空当前默认状态
    HttpApiMock.addressListMock.map((item) => {
      item.type = 0;
    });

    let address: AddressListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      district: data.district,
      detail: data.detail,
      type: data.type,
    };

    if (HttpApiMock.addressListMock) {
      HttpApiMock.addressListMock.push(address);
    } else {
      HttpApiMock.addressListMock = [address]
      AppStorageV2.connect(GetAddressListResp, 'GetAddressListResp', () => [address])!;
    }

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public modifyAddress(data: AddressRequest) {
    // 为默认地址，清空当前默认状态
    HttpApiMock.addressListMock.map((item) => {
      item.type = 0;
    });

    let address: AddressListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      district: data.district,
      detail: data.detail,
      type: data.type,
    };

    let index = HttpApiMock.addressListMock.indexOf(address);

    HttpApiMock.addressListMock.splice(index, 1, address);

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public deleteAddress(id: string) {
    let list = HttpApiMock.addressListMock.filter((item: AddressListItem) => item.id !== JSON.stringify(id));
    HttpApiMock.addressListMock = list;

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public getAddressList() {
    const resp: BaseResponse<GetAddressListResp> = {
      code: 0,
      data: HttpApiMock.addressListMock,
    };
    return Promise.resolve(resp);
  }

  public getTouristList(touristsId?: string[]) {
    const resp: BaseResponse<GetTouristListResp> = {
      code: 0,
      data: touristsId?.length ? HttpApiMock.getTouristDetail(touristsId) : HttpApiMock.touristListMock,
    };
    return Promise.resolve(resp);
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
