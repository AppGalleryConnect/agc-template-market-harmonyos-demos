import { DeliveryRecord } from './DeliveryRecord';
import { Type } from '@kit.ArkUI';

@ObservedV2
export class DeliveryDatabase {
  @Type(DeliveryRecord)
  @Trace deliveryList: Array<DeliveryRecord> = []
  @Trace isSubscribe: boolean = false
}