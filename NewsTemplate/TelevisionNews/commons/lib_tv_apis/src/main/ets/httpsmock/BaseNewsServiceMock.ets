import { AuthorServiceMock } from './AuthorServiceMock';
import { MockTelevision } from './mockdata/MockTelevision';
import { AvResponse } from '../params/response/AvResponse';

/**
 * 基础Mock
 */
export class BaseNewsServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();

  /**
   * 查询电视数据库字段-不对外
   * @param newsId
   * @param authorId
   * @returns
   */
  public queryRawAv(newsId: string, authorId?: string): AvResponse | undefined {
    let list = [...MockTelevision.list];
    const authorInfo = this.authorMock.queryAuthorInfo(authorId);
    const avInfo = list.find(v => v.id === newsId);
    const copy = JSON.parse(JSON.stringify(avInfo)) as AvResponse;
    if (copy) {
      copy.isFollow = authorInfo?.subscribe?.includes(avInfo?.id ?? '') ?? false;
    }
    return copy;
  }
}