import { MeasureModule } from '../model/Index';

export enum MeasureType {
  VOLUME = 1,
  SPACE = 2
}

export const MEASURE_TYPE_LIST: MeasureModule[] = [
  {
    id: MeasureType.VOLUME,
    defaultIcon: $r('app.media.volume_inactive'),
    activeIcon: $r('app.media.volume_active'),
  },
  {
    id: MeasureType.SPACE,
    defaultIcon: $r('app.media.space_inactive'),
    activeIcon: $r('app.media.space_active'),
  },
];

export const SPACE_MAP: Map<number, string> = new Map([[0, '上'], [1, '下'], [2, '左'], [3, '右'], [4, '后']]);

export const ENGINE_UPDATE_INTERVAL = 33;