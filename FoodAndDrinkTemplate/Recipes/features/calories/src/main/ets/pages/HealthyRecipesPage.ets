import { RouterMap, RouterModule } from 'commonlib';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { RecipeBriefInfo } from 'network';
import { HealthyRecipesPageVM } from '../viewModels/HealthyRecipesPageVM';

@Builder
export function HealthyRecipesPageBuilder() {
  HealthyRecipesPage()
}

@Preview
@ComponentV2
struct HealthyRecipesPage {
  @Local vm: HealthyRecipesPageVM = new HealthyRecipesPageVM();

  aboutToAppear(): void {
    let params = RouterModule.getNavParam<Record<string, string>>(RouterMap.HEALTHY_RECIPES_PAGE)
    this.vm.title = params?.keyword || '';
    this.vm.icon = params?.icon || '';
    this.vm.fontColor = params?.fontColor || '';
    this.vm.getDishesList('减脂餐')
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
    RouterModule.push(RouterMap.DISHES, param)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Row() {
              Image($r(`app.media.${this.vm.icon}`))
                .width(20)
                .height(20)
              Text(`${this.vm.title}吃什么效果最佳`)
                .fontSize(18)
                .fontFamily('HarmonyHeiTi')
                .fontWeight(700)
                .fontColor(this.vm.fontColor)
                .margin({ left: 4 })
            }
            .width('100%')

            Row() {
              Swiper() {
                ForEach(this.vm.healthyRecipes, (item: Array<string>, index: number) => {
                  Column({ space: 12 }) {
                    ForEach(item, (it: string, index: number) => {
                      Row() {
                        Image($r('app.media.ic_reduce_fat1'))
                          .width(70)
                          .height(70)
                          .borderRadius(8)
                        Column() {
                          Text(it)
                            .width('100%')
                            .fontSize(14)
                            .fontFamily('HarmonyHeiTi')
                            .fontColor($r('sys.color.font_primary'))
                            .fontWeight(500)
                          Text('西蓝花富含维生素C、膳食纤维和硫代葡萄糖苷，具有抗氧化、增强免疫力的作用。其低热量高纤维的特性有助于体重管理，所含的钙、叶酸、钾等营养素对骨骼、心血管和神经系统健康有一定辅助作用。')
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .width('100%')
                            .fontSize(12)
                            .fontFamily('HarmonyHeiTi')
                            .fontWeight(400)
                            .fontColor($r('sys.color.font_secondary'))
                            .margin({ top: 8 })
                        }
                        .layoutWeight(1)
                        .width('100%')
                        .margin({ left: 12 })
                      }
                    }, (it: string, index: number) => `${it}`)

                  }
                  .padding({ bottom: 20 })
                }, (item: Array<string>, index: number) => JSON.stringify(item))
              }
              .height(260)
              .itemSpace(12)
              .autoPlay(true)
              .displayCount(this.vm.getLanes === 3 ? 3 : 1)
              .indicator(new DotIndicator()
                .color($r('sys.color.comp_background_secondary'))
                .selectedColor($r('sys.color.multi_color_04'))
                .top(250)
              )
            }
            .margin({ top: 12 })
          }
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding(12)
          .borderRadius(20)

          Column() {
            Text(`${this.vm.title}推荐`)
              .fontSize(20)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(700)
              .fontColor($r('sys.color.font_primary'))
          }
          .margin({ top: 16 })
          .width('100%')

          Row() {
            Column({ space: 8 }) {
              List({ space: 8 }) {
                ForEach(this.vm.recipeList, (item: RecipeBriefInfo, index: number) => {
                  ListItem() {
                    Row({ space: 8 }) {
                      Image($r(`app.media.${item.thumbnail}`)).width(120).borderRadius(8);
                      Column() {
                        Text(item.title).maxLines(1).width(120).textOverflow({ overflow: TextOverflow.Ellipsis });
                        Row({ space: 6 }) {
                          ForEach(item.category.split('、'), (item: string) => {
                            Text(item)
                              .fontWeight(FontWeight.Regular)
                              .fontSize($r('sys.float.Caption_M'))
                          }, (item: string) => item);
                        }

                        Column({ space: 6 }) {
                          Text(`${item.likes}收藏`).fontSize(12).width(120).textAlign(TextAlign.Start);
                          Text(`${item.views}看过`).fontSize(12).width(120).textAlign(TextAlign.Start);
                        };

                        Row({ space: 4 }) {
                          Image($r(`app.media.${item.authorAvatar}`)).size({ width: 20, height: 20 }).borderRadius(10);
                          Text(item.author).fontSize(12).opacity(0.6);
                        };
                      }.height('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Start);
                    }.height(120).width('100%').justifyContent(FlexAlign.Start)
                    .onClick(() => {
                      this.onColumnClicked(item.id.toString(), `recipes_flow_${item.id}_${index}`)
                    });
                  }
                  .id(`recipes_flow_${item.id}_${index}`)
                  .clip(true)
                }, (item: RecipeBriefInfo) => item.title);
              }
              .lanes(this.vm.getLanes)
            }
          }
          .margin({ top: 16 })
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ bottom: 28 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .padding({ top: 40 })
    .title(`${this.vm.title}`)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
