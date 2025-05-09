import { ComponentEntryProxy } from '@common/customtypes';

export interface TabSwiperRenderUnit {
  id: string,
  tab: ComponentEntryProxy;
  tabContent: ComponentEntryProxy;
}

export type TabSwiperViewData = TabSwiperRenderUnit[];

export type TabLayoutMode = 'Start' | 'Center' | 'End' | 'SpaceBetween' | 'SpaceAround' | 'SpaceEvenly';

export interface TabLayoutInfo {
  x: number,    // Tab 与容器左边缘的距离
  width: number // Tab 自身的宽度
}

export interface IndicatorMoveStatus {
  from: number,
  to: number,
  progress: number
}
