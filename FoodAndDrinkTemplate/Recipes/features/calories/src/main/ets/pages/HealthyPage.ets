import { BaseHeader, RouterMap, RouterModule } from 'commonlib';
import { RecipesTypes, PopResult } from '../types/Index';
import { HealthyPageVM } from '../viewModels/HealthyPageVM';

@Builder
export function HealthyPageBuilder() {
  HealthyPage()
}

@Preview
@ComponentV2
struct HealthyPage {
  @Local vm: HealthyPageVM = new HealthyPageVM();

  aboutToAppear(): void {
  }

  @Builder
  CategoryHeaderBuilder(isHeader: boolean, hasStartMargin?: boolean) {
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll(this.vm.listScroller) {
          Column() {
            Column() {
              Stack({ alignContent: Alignment.Bottom }) {
                Stack({ alignContent: Alignment.Bottom }) {
                  Image($r('app.media.ic_banner'))
                    .objectFit(ImageFit.Cover)
                    .width('100%')
                    .height('100%')
                  Column() {
                    Row() {
                      Column({ space: 4 }) {
                        Text('你的热量计算')
                          .fontFamily('HarmonyHeiTi')
                          .fontSize(16)
                          .fontColor($r('sys.color.font_primary'))
                          .fontWeight(700)
                        Text('热量统计与规划')
                          .fontFamily('HarmonyHeiTi')
                          .fontSize(12)
                          .fontColor($r('sys.color.font_secondary'))
                          .fontWeight(400)
                      }

                      Column() {
                        Row() {
                          Row() {
                            Image($r('app.media.ic_eating'))
                              .width(14)
                              .height(14)
                              .objectFit(ImageFit.Cover)
                          }
                          .width(24)
                          .height(24)
                          .backgroundColor('rgba(100, 187, 92, 1)')
                          .borderRadius(24)
                          .justifyContent(FlexAlign.Center)

                          Text('今日摄入')
                            .fontFamily('HarmonyHeiTi')
                            .fontSize(12)
                            .fontColor($r('sys.color.font_primary'))
                            .fontWeight(500)
                            .margin({ left: 4 })
                        }

                        Row() {
                          Text(this.vm.todayCalories.toString())
                            .fontFamily('HarmonyHeiTi')
                            .fontSize(14)
                            .fontColor($r('sys.color.font_primary'))
                            .fontWeight(500)
                          Text(' / ')
                            .fontFamily('HarmonyHeiTi')
                            .fontSize(10)
                            .fontWeight(400)
                            .fontColor($r('sys.color.font_primary'))
                            .margin({ top: 4 })
                          Text('2000千卡')
                            .fontSize(10)
                            .fontWeight(400)
                            .fontColor($r('sys.color.font_tertiary'))
                            .margin({ top: 4 })
                        }
                        .margin({ top: 6 })
                      }
                    }
                    .width('100%')
                    .height(72)
                    .backgroundColor($r('sys.color.comp_background_primary'))
                    .borderRadius(16)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding({ left: 12, right: 20 })
                    .onClick(() => {
                      let param: Record<string, Object> = {};
                      param.todayCalories = this.vm.todayCalories;
                      RouterModule.push(RouterMap.CALORIES_PAGE, param,
                        (popInfo: PopInfo) => {
                          let result = popInfo.result as PopResult;
                          this.vm.todayCalories = result.todayCalories;
                        })
                    })
                  }
                  .height(160)
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .alignItems(HorizontalAlign.Center)
                  .padding({ left: 16, right: 16 })
                }
                .renderGroup(true)
                .backgroundColor($r('sys.color.background_secondary'))
                .clip(true)
              }
            }
            .height(442)

            List({ space: 20 }) {
              ForEach(this.vm.healthyRecipes, (item: RecipesTypes, index: number) => {
                ListItem() {
                    Column() {
                      Row() {
                        Image($r(`app.media.${item.icon}`))
                          .width(20)
                          .height(20)
                        Text(item.type)
                          .margin({ left: 4 })
                          .fontSize(18)
                          .fontFamily('HarmonyHeiTi')
                          .fontWeight(700)
                          .fontColor(item.fontColor)
                      }
                      .width('100%')
                      .height(24)

                      Row() {
                        Row() {
                          Column() {
                            Image($r(`app.media.${item.img}`))
                              .width(120)
                              .height(92)
                              .borderRadius(8)
                          }
                          .height(98)
                        }
                        .width(120)

                        Row() {
                          Column() {
                            Text(`${item.type}吃什么？`)
                              .fontSize(16)
                              .fontFamily('HarmonyHeiTi')
                              .fontWeight(500)
                              .fontColor(item.fontColor)
                            Text('精选食谱100篇')
                              .width(172)
                              .height(40)
                              .backgroundColor(item.fontColor)
                              .fontSize(16)
                              .fontFamily('HarmonyHeiTi')
                              .fontWeight(500)
                              .fontColor(Color.White)
                              .width('100%')
                              .borderRadius(20)
                              .textAlign(TextAlign.Center)
                              .margin({ top: 8 })
                          }
                          .padding({ left: '9%', right: '9%' })
                          .width('100%')
                        }
                        .layoutWeight(1)
                      }
                      .margin({ top: 6 })
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .height(140)
                    .width('100%')
                    .borderRadius(20)
                    .backgroundColor(item.bgColor)
                    .padding({
                      left: 12,
                      right: 12,
                      top: 12,
                      bottom: 12
                    })
                }
                .onClick(() => {
                  RouterModule.push(RouterMap.HEALTHY_RECIPES_PAGE,
                    {
                      'keyword': item.type,
                      'icon': item.icon,
                      'fontColor': item.fontColor
                    } as Record<string, string>)
                })
              }, (item: RecipesTypes) => JSON.stringify(item))
            }
            .padding({ left: 16, right: 16 })
            .width('100%')
            .lanes(this.vm.getLines, 12)
            .margin({top: 12})
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
        .clip(false)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .backgroundColor($r('sys.color.background_secondary'))
        .onDidScroll(() => {
          const yOffset = this.vm.listScroller.currentOffset().yOffset;
          if (yOffset > 70) {
            this.vm.showBgColor = true;
          } else {
            this.vm.showBgColor = false;
          }
        })

        Column() {
          Row() {
            Text('健康')
              .fontSize(26)
              .fontColor(this.vm.showBgColor ? $r('sys.color.font_primary') : $r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .layoutWeight(1)

            if(this.vm.getLines === 2 && !this.vm.showBgColor) {
              Search({ placeholder: '搜索食物热量和营养' })
                .width(400)
                .backgroundColor('#1AFFFFFF')
                .backgroundBlurStyle(BlurStyle.Thin)
                .shadow({
                  radius: 8,
                  color: $r('sys.color.comp_background_secondary'),
                  offsetX: 2,
                  offsetY: 2
                })
                .onClick(() => {
                  RouterModule.push(RouterMap.SEARCH_FOOD_PAGE)
                })
            }

            Image($r('app.media.ic_title_search')).width(40).height(40).onClick(() => {
              RouterModule.push(RouterMap.SEARCH_FOOD_PAGE)
            })
              .visibility(this.vm.showBgColor ? Visibility.Visible : Visibility.None)
          }
          .alignItems(VerticalAlign.Center)
          .height(56)
          .width('100%')
          .margin({ left: 16 })

          if (!this.vm.showBgColor && this.vm.getLines !== 2) {
            Row() {
              Search({ value: $$this.vm.searchText, placeholder: '搜索食物热量和营养' })
                .textFont({ size: $r('sys.float.Body_L') })
                .placeholderFont({ size: $r('sys.float.Body_L'), family: 'HarmonyHeiTi' })
                .maxLength(20)
                .enabled(false)
                .backgroundColor('#1AFFFFFF')
                .backgroundBlurStyle(BlurStyle.Thin)
                .shadow({
                  radius: 8,
                  color: $r('sys.color.comp_background_secondary'),
                  offsetX: 2,
                  offsetY: 2
                })
            }
            .onClick(() => {
              RouterModule.push(RouterMap.SEARCH_FOOD_PAGE)
            })
          }
        }
        .width('100%')
        .height(96)
        .padding({ top: 40, left: 16, right: 16 })
        .backgroundColor(this.vm.showBgColor ? $r('sys.color.comp_background_gray') : '')
        .linearGradient({
          angle: 180,
          colors: this.vm.showBgColor ?
            [['rgba(0, 0, 0, 0)', 0],['rgba(0, 0, 0, 0)', 1]] : [['rgba(0, 0, 0, 0.6)', 0],['rgba(0, 0, 0, 0)', 1]],
        })
      }
      .backgroundColor($r('sys.color.comp_background_gray'))
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ bottom: 88 })
  }
}
