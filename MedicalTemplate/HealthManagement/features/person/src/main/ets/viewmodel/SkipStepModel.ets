import { OHDialogModel } from 'common';

@ObservedV2
export class SkipStepModel extends OHDialogModel {
  @Trace title: ResourceStr = '确认跳过吗？';
  @Trace subtitle: ResourceStr = '跳过后会影响展现真实身体数据';
}