import { OHDialogModel } from 'common';
import { weightRange } from '../constants/constants';

@ObservedV2
export class WeightDialogModel extends OHDialogModel {
  @Trace range: string[] = weightRange;
}