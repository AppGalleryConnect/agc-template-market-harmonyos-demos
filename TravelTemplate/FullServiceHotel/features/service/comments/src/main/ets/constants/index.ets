import { ArrivalType } from '../types';

export class Constants {
  static readonly RATING_LABEL: string[] = ['1分/很差', '2分/较差', '3分/一般', '4分/不错', '5分/非常好'];
  static readonly RATING_TYPE: RatingLayoutType;
  static readonly ARRIVAL_TYPE_LIST: ArrivalType[] = [
    { label: '商务出差' },
    { label: '朋友出游' },
    { label: '情侣出游' },
    { label: '家庭亲子' },
    { label: '代人预订' },
    { label: '其他' },
  ];
}

export enum RatingLayoutType {
  VERTICAL,
  HORIZONTAL,
}
