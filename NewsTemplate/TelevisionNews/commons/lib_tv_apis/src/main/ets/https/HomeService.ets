import request from '../common/BaseRequest';
import { AvResponse, VideoProgramResponse } from '../params/response/AvResponse';
import { NewsResponse } from '../params/response/NewsResponse';

/**
 * 首页
 */
export class HomeService {
  /**
   * 查询电视视频流
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryTelevisionList(currentIndex: number = 10,
    currentPage = 0): Promise<AvResponse[]> {
    return request.get('/home/television/list', { params: { currentIndex, currentPage } });
  }

  /**
   * 查询首页电视节目单
   * @param id
   * @returns
   */
  public queryHomeTelevisionProgram(id: string): Promise<VideoProgramResponse[]> {
    return request.get('/home/television/program/list', { params: { id } });
  }

  /**
   * 查询电视节目详情
   * @param id
   * @returns
   */
  public queryHomeTelevisionDetails(id: string): Promise<AvResponse> {
    return request.get('/home/television/program/details', { params: { id } });
  }

  /**
   * 查询电视猜你喜欢
   * @returns
   */
  public queryTelevisionLikes(): Promise<AvResponse[]> {
    return request.get('/home/television/like');
  }

  /**
   * 查询所有视频
   * @returns
   */
  public queryAllNewsList(search: string): Promise<NewsResponse[]> {
    return request.get('/all/news/list', { params: { search } });
  }

  /**
   * 查询服务卡片-电视台
   */
  public queryFormNewsList(): Promise<AvResponse[]> {
    return request.get('/form/news/list');
  }
}

const instance = new HomeService();

export { instance as HomeServiceApi };