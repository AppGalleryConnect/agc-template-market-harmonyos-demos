import { Exchange } from '../../httpsmock/Exchange';
import request from '../Request';
// 启动mock
import('../../httpsmock/MockAdapter');

export class ExchangeService {
  /**
   * 查询汇率列表
   * @returns
   */
  public queryExchangeList(): Promise<Exchange>{
    const url = '/exchange/list';
    return request.get(url);
  };
}

const instance = new ExchangeService();

export { instance as ExchangeServiceApi };