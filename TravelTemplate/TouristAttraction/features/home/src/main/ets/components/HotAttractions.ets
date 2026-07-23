import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, BreakpointType, Constant, GridRowColSetting } from 'common';
import { AttractionInfo } from 'types';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HotAttractionsBuilder() {
  HotAttractions();
}

@ComponentV2
struct HotAttractions {
  vm: HomePageVM = HomePageVM.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      Grid() {
        LazyForEach(this.vm.hotAttractionList, (item: AttractionInfo) => {
          GridItem() {
            Stack() {
              Image(item.banner)
                .width('100%')
                .aspectRatio(4/3)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
                .mask(new ProgressMask(0, 1, $r('sys.color.mask_tertiary')));
              Text(item.name)
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'));
            }.width('100%');
          }.onClick(() => {
            this.mainPathStack.pushPathByName('AttractionDetail', item.attractionId);
          });
        });
      }
      .columnsTemplate(new BreakpointType({
        [BreakpointNameEnum.SM]: '1fr '.repeat(3),
        [BreakpointNameEnum.MD]: '1fr '.repeat(3),
        [BreakpointNameEnum.LG]: '1fr '.repeat(5),
        [BreakpointNameEnum.XL]: '1fr '.repeat(5),
      }).getValue(this.breakPointModel.currentBreakpoint))
      .columnsGap(GridRowColSetting.getGutter(this.breakPointModel.currentBreakpoint))
      .scrollBar(BarState.Off)
      .width(Constant.FULL_PERCENT)
      .align(Alignment.Start)
      .edgeEffect(EdgeEffect.Spring);
    }.backgroundColor($r('sys.color.background_secondary'));
  }
}