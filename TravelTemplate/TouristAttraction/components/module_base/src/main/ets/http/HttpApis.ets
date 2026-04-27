import { BaseResponse } from './ResponseTypes';
import { GetAccommodationDetailResp } from './responseTypes/GetAccommodationDetailsResp';
import { GetCateringDetailResp } from './responseTypes/GetCateringDetailsResp';
import { cateringDetailMock } from './mockData/getCateringDetail';
import { accommodationDetailMock } from './mockData/getAccommodationDetail';

class HttpApi {
  public getCateringDetail(siteId: string): Promise<BaseResponse<GetCateringDetailResp>> {
    const resp: BaseResponse<GetCateringDetailResp> = {
      code: 0,
      data: cateringDetailMock,
    };
    return Promise.resolve(resp);
  }

  public getAccommodationDetail(siteId: string): Promise<BaseResponse<GetAccommodationDetailResp>> {
    const resp: BaseResponse<GetAccommodationDetailResp> = {
      code: 0,
      data: accommodationDetailMock,
    };
    return Promise.resolve(resp);
  }
}

const https = new HttpApi();

export { https };