import { RetBean } from '../common/RetBean';

export class SearchTipRes {
  ret: RetBean;
  data: string[];
  total: number;

  constructor(searchTipRes?: SearchTipRes) {
    this.ret = new RetBean(searchTipRes?.ret);
    this.data = (searchTipRes?.data || []);
    this.total = searchTipRes?.total || 0;
  }
}
