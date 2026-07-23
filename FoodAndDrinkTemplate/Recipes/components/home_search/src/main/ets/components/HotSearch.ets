import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointType } from 'base_ui';
import { RecipeBriefInfo } from '../types/Index';

@ComponentV2
export struct HotSearch {
  @Param keys: RecipeBriefInfo[] = []
  @Param title: string = ''
  @Event goRecipeDetail: (id: number, index: number) => void = () => {

  };
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  @Computed
  get gitLanes() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  @Builder
  clearBuilder() {

  }

  @Builder
  itemBuilder(listItem: RecipeBriefInfo, index: number) {
    Row({ space: 12 }) {
      Text(`${index + 1}`)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .fontColor(Number(index) < 3 ? $r('sys.color.alert') : $r('sys.color.font_secondary'))
        .width(24)
        .textAlign(TextAlign.Center)

      if (listItem.thumbnail) {
        Image($r(`app.media.${listItem.thumbnail}`))
          .width(70)
          .height(70)
          .borderRadius(8)
          .objectFit(ImageFit.Fill)
      }

      Column() {
        Text(listItem.title)
          .textStyles()
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .height(24)

        if (listItem.description) {
          Text(listItem.description)
            .textStyles()
            .fontWeight(FontWeight.Regular)
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(60)
    }
    .alignItems(VerticalAlign.Center)
    .margin({ right: 12, left: 12 })
    .height(70)
    .layoutWeight(1)
  }

  build() {
    Column() {
      Row() {
        Text('热搜榜')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 8,
      })
      .margin({ bottom: 8 })

      List({ space: 8 }) {
        ForEach(this.keys, (item: RecipeBriefInfo, index: number) => {
          ListItem() {
            this.itemBuilder(item, index)
          }
          .id(`recipes_flow_${item.id}_${index}`)
          .onClick(() => {
            this.goRecipeDetail(item.id, index)
          })
        }, (item: RecipeBriefInfo) => JSON.stringify(item))
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .lanes(this.gitLanes)
      .width('100%')
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({ bottom: 14 })
    .margin({ top: 8 })
  }
}

@Extend(Text)
function textStyles() {
  .textAlign(TextAlign.Start)
  .width('100%')
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontSize($r('sys.float.Body_M'))
}
