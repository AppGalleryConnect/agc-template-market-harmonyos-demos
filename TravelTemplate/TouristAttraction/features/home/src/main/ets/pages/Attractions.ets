import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, BreakpointType, LazyDataSource } from 'common';
import { AttractionInfo } from 'module_base';
import { TitleBar } from 'uicomponents';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function AttractionsBuilder() {
  Attractions();
}

@ComponentV2
export struct Attractions {
  vm: HomePageVM = HomePageVM.instance;
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  AttractionItemBuilder(attraction: AttractionInfo) {
    Row({ space: 16 }) {
      Image(attraction.banner).size({ width: 80, height: 80 }).borderRadius(8);
      Column() {
        Text(attraction.name)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'));
        Row({ space: 8 }) {
          ForEach(attraction.labels, (item: string) => {
            Text(item)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .border({ width: 1, radius: 4, color: $r('sys.color.comp_divider') })
              .height(16)
              .padding({
                top: 1,
                bottom: 1,
                left: 4,
                right: 4,
              });
          }, (item: string) => item);
        }.margin({ top: 4, bottom: 8 });

        Row({ space: 8 }) {
          ForEach(attraction.detailImages, (item: ResourceStr) => {
            Image(item).size({ height: 32, width: 32 }).borderRadius(4);
          }, (item: ResourceStr) => item.toString());
        };
      }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      this.mainPathStack.pushPathByName('AttractionDetail', attraction.attractionId);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '热门景区', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        List({ space: 12 }) {
          LazyForEach(this.vm.attractionList, (item: AttractionInfo) => {
            this.AttractionItemBuilder(item);
          });
        }
        .lanes(new BreakpointType<number>({
          [BreakpointNameEnum.SM]: 1,
          [BreakpointNameEnum.MD]: 1,
          [BreakpointNameEnum.LG]: 2,
          [BreakpointNameEnum.XL]: 2,
        }).getValue(this.breakPointModel.currentBreakpoint), 16)
        .contentStartOffset(12)
        .contentEndOffset(12)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .margin({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding });
      }.backgroundColor($r('sys.color.comp_background_secondary'));
    }.hideTitleBar(true);
  }
}