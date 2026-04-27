import { BreakpointModel, BreakpointType, RouterMap, RouterModule } from 'commonlib';
import { RecipeItem } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import { VideoView } from 'featured_recipes';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

@ComponentV2
export struct Recipes {
  @Param @Require recipeList: RecipeItem[];
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  @Computed
  get getLanes() {
    let lanes = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return lanes;
  }

  private onColumnClicked(indexValue: string, snapShotComponentId: string): void {
    let param: Record<string, Object> = {};
    let clickedIndex = parseInt(indexValue);
    param.id = clickedIndex;
    param.indexValue = clickedIndex;
    param.snapShotId = snapShotComponentId;

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterModule.push(RouterMap.DISHES, param);
  }

  build() {
    Scroll() {
      if (this.recipeList.length) {
        Column({ space: 8 }) {
          List({ space: 8 }) {
            ForEach(this.recipeList, (item: RecipeItem, index: number) => {
              ListItem() {
                Row({ space: 8 }) {
                  if(typeof item.banner === 'string' && item.banner.startsWith('file://')) {
                    Image(item.banner)
                      .width(120)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                      .height(120)
                  } else {
                    if(item.video && item.video !== 'ic_avatar') {
                      Stack({alignContent: Alignment.TopEnd}) {
                        VideoView({
                          videoUrl: item.video,
                          isSlider: false,
                          isCover: true,
                          onClickCb: (id: number) => {
                            this.onColumnClicked(item.id.toString(), `recipes_flow_${item.id}_${index}`)
                          },
                        })
                          .width(120)
                          .height(120)
                        Image($r('app.media.ic_video_pause'))
                          .width(12)
                          .height(12)
                          .margin(14)
                          .onClick(() => {
                            this.onColumnClicked(item.id.toString(), `recipes_flow_${item.id}_${index}`)
                          })
                      }
                      .width(120)
                      .height(120)
                      .borderRadius(8)
                      .clip(true)

                    } else {
                      Image($r(`app.media.${item.banner}`))
                        .width(120)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                        .height(120)
                    }
                  }
                  Column() {
                    Text(item.title).maxLines(1).width(120).textOverflow({ overflow: TextOverflow.Ellipsis });
                    Row({ space: 6 }) {
                      ForEach(item.label, (item: string) => {
                        Text(item)
                          .fontSize(10)
                          .fontColor($r('sys.color.font_secondary'))
                          .backgroundColor($r('sys.color.comp_background_tertiary'))
                          .padding(this.breakPointModel.currentBreakpoint === 'md' ? 2 : 4)
                          .borderRadius(4)
                      }, (item: string) => item);
                    }

                    Column({ space: 6 }) {
                      Text(`${item.star}收藏`).fontSize(12).width(120).textAlign(TextAlign.Start);
                      Text(`${item.used}看过`).fontSize(12).width(120).textAlign(TextAlign.Start);
                    };

                    Row({ space: 4 }) {
                      Image($r(`app.media.${item.avatar}`)).size({ width: 20, height: 20 }).borderRadius(10);
                      Text(item.nickname).fontSize(12).opacity(0.6);
                    };
                  }
                  .height('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(HorizontalAlign.Start);

                  if(item.isVip) {
                    Text('VIP')
                      .width(32)
                      .height(16)
                      .fontSize(10)
                      .fontColor(Color.White)
                      .textAlign(TextAlign.Center)
                      .borderRadius({
                        topLeft: 8,
                        topRight: 0,
                        bottomRight: 8,
                        bottomLeft: 0
                      })
                      .backgroundColor('#fff9a01e')
                      .position({ x: 0, y: 0 })
                  }
                }
                .height(120)
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .onClick(() => {
                  this.onColumnClicked(item.id.toString(), `recipes_flow_${item.id}_${index}`)
                });

              }
              .id(`recipes_flow_${item.id}_${index}`)
            }, (item: RecipeItem) => item.title);
          }
          .lanes(this.getLanes)

          Text('~~我已经到底了~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
        };
      } else {
        Column() {
          Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
          Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
        }.margin({ top: 72 });
      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .padding({
      top: 12,
      left: 16,
      right: 16,
      bottom: 12,
    })
  }
}