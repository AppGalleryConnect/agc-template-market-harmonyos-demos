import { OHDialogModel } from 'common';

@ObservedV2
export class ChooseDateModel extends OHDialogModel {
  @Trace title: ResourceStr = '出生年月';
}