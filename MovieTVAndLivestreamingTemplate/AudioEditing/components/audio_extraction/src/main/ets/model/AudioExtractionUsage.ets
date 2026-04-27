import { PersistenceV2, Type } from '@kit.ArkUI';

@ObservedV2
export class AudioExtractionUsage {
  @Trace lastExtractDate: string = ''; // YYYY-MM-DD
  @Trace count: number = 0;
  @Trace freeCount: number = 0;
  @Trace vipCount: number = 0;
}
