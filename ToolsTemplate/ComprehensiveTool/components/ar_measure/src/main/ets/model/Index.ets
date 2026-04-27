import { Type } from '@kit.ArkUI';
import { MeasureType } from '../constant/Constant';

export interface MeasureModule {
  id: MeasureType;
  defaultIcon: ResourceStr;
  activeIcon: ResourceStr;
}

@ObservedV2
export class History {
  @Trace type: MeasureType = MeasureType.VOLUME;
  @Trace record: string[] = [];
  @Trace time: Date = new Date();
}

@ObservedV2
export class Hint {
  @Trace message: string = '';
  @Trace confirmCallBack: () => void = () => {
  };
  @Trace cancelCallBack: () => void = () => {
  };
}

@ObservedV2
export class MeasureRecord {
  @Trace type: MeasureType = MeasureType.VOLUME;
  @Trace record: string = '';
  @Trace copyCallBack: () => void = () => {
  };
}

@ObservedV2
export class HistoryList {
  @Type(History)
  @Trace list: History[] = [];
}