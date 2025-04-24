import { ArrivalType, DetailRate, SubmitComment } from '../types';

@ObservedV2
export class SubmitCommentModel implements SubmitComment {
  @Trace location: string = '';
  @Trace totalRate: number = 0;
  @Trace detailRate: DetailRate = new DetailRateModel();
  @Trace arrivalType: ArrivalType = new ArrivalTypeModel(); // 枚举替换
  @Trace desc: string = '';
  @Trace isAnonymous: number = 1;
  @Trace enableImg: boolean = false;
  @Trace img?: string = '';
}

@ObservedV2
export class DetailRateModel implements DetailRate {
  @Trace service: number = 0;
  @Trace environment: number = 0;
  @Trace device: number = 0;
  @Trace experience: number = 0;
}

@ObservedV2
export class ArrivalTypeModel implements ArrivalType {
  @Trace label: string = '';
}
