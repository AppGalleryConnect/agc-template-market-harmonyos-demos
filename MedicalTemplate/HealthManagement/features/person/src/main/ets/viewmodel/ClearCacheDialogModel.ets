import { OHDialogModel } from 'common';

@ObservedV2
export class ClearCacheDialogModel extends OHDialogModel {
  @Trace title: ResourceStr = '清除缓存';
}