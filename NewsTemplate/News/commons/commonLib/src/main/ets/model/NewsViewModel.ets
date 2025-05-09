import { HomeConstants as Const } from '../constants/HomeConstants';
import { NewsTypeModel } from './NewsTypeModel';

export class NewsViewModel {
  getDefaultTypeList(): NewsTypeModel[] {
    return Const.TAB_BARS_DEFAULT_NEWS_TYPES;
  }
}