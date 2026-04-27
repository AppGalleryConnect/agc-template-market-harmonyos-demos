import { BreakpointModel, BreakpointType } from 'commonlib';
import { RecipesTypes } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class HealthyPageVM {
  listScroller: Scroller = new Scroller();
  @Trace currentIndex: number = 0;
  @Trace showBgColor: boolean = false;
  @Trace healthyRecipes: RecipesTypes[] = [
    {
      id: 1,
      icon: 'ic_reduce_fat_icon1',
      type: '减脂食谱',
      img: 'ic_reduce_fat1',
      fontColor: 'rgba(100, 187, 92, 1)',
      bgColor: 'rgba(100, 187, 92, 0.1)'
    },
    {
      id: 2,
      icon: 'ic_reduce_fat_icon2',
      type: '糖尿病食谱',
      img: 'ic_reduce_fat2',
      fontColor: 'rgba(86, 74, 247, 1)',
      bgColor: 'rgba(86, 74, 247, 0.1)'
    },
    {
      id: 3,
      icon: 'ic_reduce_fat_icon3',
      type: '心脏病食谱',
      img: 'ic_reduce_fat3',
      fontColor: 'rgba(232, 64, 38, 1)',
      bgColor: 'rgba(232, 64, 38, 0.1)'
    },
    {
      id: 4,
      icon: 'ic_reduce_fat_icon1',
      type: '心血管食谱',
      img: 'ic_reduce_fat1',
      fontColor: 'rgba(100, 187, 92, 1)',
      bgColor: 'rgba(100, 187, 92, 0.1)'
    },
    {
      id: 5,
      icon: 'ic_reduce_fat_icon2',
      type: '补血食谱',
      img: 'ic_reduce_fat2',
      fontColor: 'rgba(86, 74, 247, 1)',
      bgColor: 'rgba(86, 74, 247, 0.1)'
    }
  ];
  @Trace todayCalories = 0;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get getLines() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}