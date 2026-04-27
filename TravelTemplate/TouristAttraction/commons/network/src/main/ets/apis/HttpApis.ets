import { AxiosRequestHeaders } from '@ohos/axios';
import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import {
  AddressRequest,
  CreateCommodityOrderRequest,
  CreateTicketOrderRequest,
  GetOrderDetailRequest,
  PrepayResp,
  TouristRequest
} from '../types/AxiosRequestParam';
import { BaseResponse } from '../types/ResponseTypes';
import { GetAccommodationDetailResp } from '../types/responseTypes/GetAccommodationDetailResp';
import { GetAddressListResp } from '../types/responseTypes/GetAddressListResp';
import { GetAttractionDetailResp } from '../types/responseTypes/GetAttractionDetailResp';
import { GetAttractionsInfoResp } from '../types/responseTypes/GetAttractionListResp';
import { GetBulletinDetailResp } from '../types/responseTypes/GetBulletinDetailResp';
import { GetBulletinListResp } from '../types/responseTypes/GetBulletinListResp';
import { GetCateringDetailResp } from '../types/responseTypes/GetCateringDetailResp';
import { GetCommodityDetailResp } from '../types/responseTypes/GetCommodityDetailResp';
import { GetCommodityListResp } from '../types/responseTypes/GetCommodityListResp';
import { GetHomeInfoResp } from '../types/responseTypes/GetHomeRollUpInfoResp';
import { GetNoteDetailResp } from '../types/responseTypes/GetNoteDetailResp';
import { GetNoteListResp } from '../types/responseTypes/GetNoteListResp';
import { GetRouteLineDetailResp } from '../types/responseTypes/GetRouteDetailResp';
import { GetRouteLineListResp } from '../types/responseTypes/GetRouteListResp';
import { GetTicketDetailResp } from '../types/responseTypes/GetTicketDetailResp';
import { GetTicketListResp } from '../types/responseTypes/GetTicketListResp';
import { GetTouristListResp } from '../types/responseTypes/GetTouristListResp';

class HttpApi {
  public getBulletinList(): Promise<BaseResponse<GetBulletinListResp>> {
    return request.get({ url: RequestUrl.BULLETIN_GET_LIST, headers: {} as AxiosRequestHeaders });
  }

  public getBulletinDetail(bulletinId: number): Promise<BaseResponse<GetBulletinDetailResp>> {
    return request.post({
      url: RequestUrl.BULLETIN_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: bulletinId
    });
  }

  public getHomeRollupInfo(): Promise<BaseResponse<GetHomeInfoResp>> {
    return request.get({ url: RequestUrl.HOME_GET_INFO, headers: {} as AxiosRequestHeaders });
  }

  public getAttractionList(): Promise<BaseResponse<GetAttractionsInfoResp>> {
    return request.get({ url: RequestUrl.ATTRACTION_GET_LIST, headers: {} as AxiosRequestHeaders, });
  }

  public getAttractionDetail(attractionId: number): Promise<BaseResponse<GetAttractionDetailResp>> {
    return request.post({
      url: RequestUrl.ATTRACTION_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: attractionId
    });
  }

  public getTicketList(): Promise<BaseResponse<GetTicketListResp>> {
    return request.get({ url: RequestUrl.TICKET_GET_LIST, headers: {} as AxiosRequestHeaders });
  }

  public getTicketDetail(ticketId: number): Promise<BaseResponse<GetTicketDetailResp>> {
    return request.post({
      url: RequestUrl.TICKET_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: ticketId
    });
  }

  public getNoteList(): Promise<BaseResponse<GetNoteListResp>> {
    return request.get({ url: RequestUrl.NOTE_GET_LIST, headers: {} as AxiosRequestHeaders });
  }

  public getNoteDetail(nodeId: number): Promise<BaseResponse<GetNoteDetailResp>> {
    return request.post({
      url: RequestUrl.NOTE_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: nodeId
    });
  }

  public getRouteLineList(): Promise<BaseResponse<GetRouteLineListResp>> {
    return request.get({ url: RequestUrl.ROUTE_GET_LIST, headers: {} as AxiosRequestHeaders, });
  }

  public getRouteDetail(routeId: number): Promise<BaseResponse<GetRouteLineDetailResp>> {
    return request.post({
      url: RequestUrl.ROUTE_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: routeId
    });
  }

  public getCommodityList(category: number): Promise<BaseResponse<GetCommodityListResp>> {
    return request.post({
      url: RequestUrl.COMMODITY_GET_LIST,
      headers: {} as AxiosRequestHeaders,
      data: category
    });
  }

  public getCommodityDetail(commodityId: number): Promise<BaseResponse<GetCommodityDetailResp>> {
    return request.post({
      url: RequestUrl.COMMODITY_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: commodityId
    });
  }

  public createTourist(data: TouristRequest): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.TOURIST_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public modifyTourist(data: TouristRequest): Promise<BaseResponse<undefined>> {
    return request.put({
      url: RequestUrl.TOURIST_MODIFY,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public deleteTourist(id: string): Promise<BaseResponse<undefined>> {
    return request.delete({
      url: RequestUrl.TOURIST_DELETE,
      headers: {} as AxiosRequestHeaders,
      data: id
    });
  }

  public getTouristList(touristsId?: string[]): Promise<BaseResponse<GetTouristListResp>> {
    return request.get({
      url: RequestUrl.TOURIST_GET_LIST,
      headers: {} as AxiosRequestHeaders,
      data: touristsId
    });
  }

  public createAddress(data: AddressRequest): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.ADDRESS_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public modifyAddress(data: AddressRequest): Promise<BaseResponse<undefined>> {
    return request.put({
      url: RequestUrl.ADDRESS_MODIFY,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public deleteAddress(id: string): Promise<BaseResponse<undefined>> {
    return request.delete({
      url: RequestUrl.ADDRESS_DELETE,
      headers: {} as AxiosRequestHeaders,
      data: id
    });
  }

  public getAddressList(): Promise<BaseResponse<GetAddressListResp>> {
    return request.get({
      url: RequestUrl.ADDRESS_GET_LIST,
      headers: {} as AxiosRequestHeaders,
    });
  }

  public createTicketOrder(data: CreateTicketOrderRequest): Promise<BaseResponse<PrepayResp>> {
    return request.post({
      url: RequestUrl.TICKET_ORDER_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public createCommodityOrder(data: CreateCommodityOrderRequest): Promise<BaseResponse<PrepayResp>> {
    return request.post({
      url: RequestUrl.COMMODITY_ORDER_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public modifyOrderDetail(data: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    return request.put({
      url: RequestUrl.ORDER_MODIFY,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public getOrderList(data: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    return request.get({
      url: RequestUrl.ORDER_LIST,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public getOrderDetail(data: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    return request.post({
      url: RequestUrl.ORDER_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public getCateringDetail(siteId: string): Promise<BaseResponse<GetCateringDetailResp>> {
    return request.post({
      url: RequestUrl.CATERING_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: siteId
    });
  }

  public getAccommodationDetail(siteId: string): Promise<BaseResponse<GetAccommodationDetailResp>> {
    return request.post({
      url: RequestUrl.ACCOMMODATION_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: siteId
    });
  }
}

const https = new HttpApi();

export { https };