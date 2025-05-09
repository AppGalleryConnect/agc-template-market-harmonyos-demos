import { BaseResponse } from '../types/ResponseTypes';

export function getFormattedResp<T>(data: T): BaseResponse<T> {
  const resp: BaseResponse<T> = {
  code: 0,
  data,
};
return resp;
}