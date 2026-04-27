import { buildTitleBar, CommonConstants, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';
import { LengthMetrics } from '@kit.ArkUI';
import { DietPlanPageVM } from '../viewModels/DietPlanPageVM';
import { FoodCalories, FoodCategory, MyMenuItem } from '../types/Index';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function DietPlanPageBuilder() {
  DietPlanPage()
}

@ComponentV2
struct DietPlanPage {
  @Local vm: DietPlanPageVM = new DietPlanPageVM();
  @Local colorMode: number = -1

  aboutToAppear(): void {
    this.vm.init()
    try {
      let colorMode = Number(PreferenceUtil.getInstance().get(CommonConstants.LIGHT_DARK_KEY, 1))
      this.colorMode = colorMode;
      emitter.on('colorModeChange', (event: emitter.EventData) => {
        let colorMode = event.data!.colorMode as number;
        this.colorMode = colorMode;
      });
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    emitter.off('colorModeChange');
  }

  @Computed
  get foodCategoryFilterList() {
    if (!this.vm.searchText) {
      return this.vm.foodCategories
    } else {
      return this.vm.foodCategories.map(item => new FoodCategory(item.id, item.name,
        item.foodList.filter(food => food.name.includes(this.vm.searchText))))
    }
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Column()
        .width(4)
        .height(28)
        .borderRadius({ topRight: 4, bottomRight: 4 })
        .backgroundColor(this.vm.currentIndex === index ? '#FD4238' : '#00000000')
      Text(typeName)
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .width(68 * this.vm.getLines)
        .margin({
          left: 12,
          right: 8,
          top: 12,
          bottom: 12,
        })
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.vm.currentIndex === index ? $r('sys.color.comp_background_primary') :
      '')
    .width('100%')
    .height(40)
    .constraintSize({ maxWidth: '100%' })
    .onClick(() => {
      this.vm.currentIndexChangeAction(index, true);
    })
  }

  build() {
    NavDestination() {
      Column() {
        Row({ space: 12 }) {
          Select(this.vm.menuList)
            .selected(this.vm.selectIndex)
            .value(this.vm.selectText)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('sys.color.font_primary'))
            .width(124)
            .optionWidth(224)
            .optionHeight(296)
            .menuItemContentModifier(new MyMenuItem())
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index)
              this.vm.selectIndex = index;
              if (text) {
                this.vm.selectText = text;
              }
            })

          Row() {
            Search({ value: $$this.vm.searchText, placeholder: '请输入食物名称' })
              .textFont({ size: $r('sys.float.Body_L') })
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .maxLength(20)
              .enabled(false)
              .hitTestBehavior(HitTestMode.Transparent)
          }.layoutWeight(1)
          .onClick(() => {
            let data: Record<string, Object> = {
              'id': this.vm.selectIndex,
              'selectFoods': this.vm.selectFoods
            }
            RouterModule.push(RouterMap.SEARCH_FOOD_PAGE, data, (popInfo: PopInfo) => {
              if (popInfo.result) {
                RouterModule.pop(popInfo.result)
              }
            })
          })
        }.width('100%').padding({ left: 16, right: 16 })

        Divider()
        // 列表页
        Row({ space: 8 }) {
          List({ scroller: this.vm.titleItemScroller }) {
            ForEach(this.foodCategoryFilterList, (item: FoodCategory, index: number) => {
              ListItem() {
                this.leftListBuilder(item.name, index)
              }
            }, (item: FoodCategory, index: number) => item.name + index)
          }
          .width(92 * this.vm.getLines)
          .height('100%')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .listDirection(Axis.Vertical) // 排列方向
          .scrollBar(BarState.Off)

          List({ scroller: this.vm.scroller }) {
            ForEach(this.foodCategoryFilterList, (item: FoodCategory) => {
              ListItemGroup() {
                ForEach(item.foodList, (listItem: FoodCalories) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Column() {
                          Text(listItem.name)
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                          Text(`${listItem.calories}千卡/${listItem.weight}克`)
                            .fontSize(12)
                            .fontColor($r('sys.color.font_secondary'))
                            .margin({ top: 2 })
                        }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                        Checkbox({ name: `${listItem.id}`, group: `foodGroup` })
                          .select(this.vm.selectFoods.some(food => food.id === listItem.id))
                          .height(20)
                          .width(20)
                          .selectedColor('#64BB5C')
                          .shape(CheckBoxShape.CIRCLE)
                          .onClick(() => {
                            this.vm.changeFood(listItem)
                          })
                      }
                      .justifyContent(FlexAlign.SpaceBetween)
                      .width(CommonConstants.FULL_WIDTH)
                      .padding({ top: 12, bottom: 4, left: 4 })

                      Divider().strokeWidth('1px').margin({ bottom: 12 })
                    }
                  }.onClick(() => {
                  })
                }, (listItem: FoodCalories) => `${item.id}${listItem.id}`)
              }
            }, (item: FoodCategory) => JSON.stringify(item))
            ListItem() {
              Column() {
                Text('添加食物').fontSize(12).fontColor('#E84026').onClick(() => {
                  this.vm.showAddFoodSheet = true
                })
              }.width('100%')
            }
          }
          .layoutWeight(1)
          .height('100%')
          .margin({ left: 8, right: 16 })
          .scrollBar(BarState.Off)
          .sticky(StickyStyle.None)
          .contentEndOffset(12)
          .onScrollIndex((start: number) => this.vm.currentIndexChangeAction(start, false))
          .bindSheet($$this.vm.showAddFoodSheet, this.addFoodSheet(), {
            height: this.vm.breakPointModel.currentBreakpoint === 'sm' ? 400 : 560,
            blurStyle: BlurStyle.Thick,
            preferType: SheetType.CENTER,
            showClose: false,
          });
        }.layoutWeight(1)

        Row({ space: 16 }) {
          if (this.vm.selectFoods.length) {
            Badge({
              count: this.vm.selectFoods.length,
              style: { fontSize: 10, badgeSize: 16 },
            }) {
              Image($r('app.media.ic_dish'))
                .width(40)
                .height(40)
                .onClick(() => {
                  this.vm.showCheckedFoods = true;
                })
            }
          } else {
            Image($r('app.media.ic_dish_off')).width(40).height(40)
          }

          Button('确定')
            .backgroundColor(this.vm.selectFoods.length ? '#E84026' : '#1A000000')
            .fontColor(this.vm.selectFoods.length ? '' : $r('sys.color.font_tertiary'))
            .onClick(() => {
              this.vm.addDietPlan()
            })
            .width(this.vm.getLines === 1 ? 256 : 448)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 24,
          right: 24,
          bottom: 24,
          top: 12
        })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .bindSheet($$this.vm.showCheckedFoods, this.checkedFoods(), {
          blurStyle: BlurStyle.Thick,
          height: 330,
          preferType: SheetType.CENTER,
          showClose: true,
          title: { title: '已添加' },
          backgroundColor: '#F1F3F5',
        });
      }
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .title(buildTitleBar('饮食计划'), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: 40 })
  }

  @Builder
  addFoodSheet() {
    Column() {
      Column() {
        Row().width(48).height(4).backgroundColor($r('sys.color.icon_fourth')).borderRadius(2)
        Row() {
          Select(this.vm.menuList)
            .selected(this.vm.selectIndex)
            .value(this.vm.selectText)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('sys.color.font_primary'))
            .space(16)
            .width(124)
            .optionWidth(224)
            .optionHeight(296)
            .menuItemContentModifier(new MyMenuItem())
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index)
              this.vm.selectIndex = index;
              if (text) {
                this.vm.selectText = text;
              }
            })
          Image($r('app.media.ic_close')).width(40).onClick(() => {
            this.vm.showAddFoodSheet = false
          })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
      }

      Column() {
        Text('自定义添加食物').fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
        Column({ space: 12 }) {
          TextInput({ text: $$this.vm.inputName, placeholder: '输入食品名称' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .borderRadius(12)
            .maxLength(20)
            .maxLength(10)
            .backgroundColor($r('sys.color.comp_background_tertiary'))

          TextInput({ text: $$this.vm.inputWeight, placeholder: '输入食品重量（克 /毫升）' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .type(InputType.Number)
            .borderRadius(12)
            .maxLength(10)
            .maxLength(10)
            .backgroundColor($r('sys.color.comp_background_tertiary'))

          TextInput({ text: $$this.vm.inputCalories, placeholder: '输入食品热量（千卡）' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .type(InputType.Number)
            .borderRadius(12)
            .maxLength(10)
            .maxLength(10)
            .backgroundColor($r('sys.color.comp_background_tertiary'))

        }
        .alignItems(HorizontalAlign.Start)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .margin({ top: 16 })
        .padding(12)
        .borderRadius(16)
      }.margin({ top: 24 })

      Row({ space: 16 }) {
        Button('取消')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .layoutWeight(1)
          .onClick(() => {
            this.vm.showAddFoodSheet = false
          })
        Button('确定')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E84026')
          .layoutWeight(1)
          .onClick(() => {
            this.vm.confirmBtn()
          })
      }.margin({ top: this.vm.breakPointModel.currentBreakpoint === 'sm' ? 24 : 220 })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(this.vm.breakPointModel.currentBreakpoint === 'sm' ? 400 : 560)
    .padding({ left: 16, right: 16, top: 8 })
    .backgroundColor(this.colorMode === 1 ? $r('sys.color.comp_background_gray') : '')
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
  }

  @Builder
  checkedFoods() {
    Column({ space: 12 }) {
      Row() {
        Blank().layoutWeight(1)
        Row() {
          Image($r('app.media.ic_delete'))
            .size({ width: 20, height: 20 })
            .align(Alignment.End)
            .margin({ right: 8 })
          Text('清空')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .padding({ top: 12, bottom: 12 })
            .textAlign(TextAlign.End)
            .borderRadius(12)
        }.onClick(() => {
          this.vm.selectFoods = [];
          this.vm.addDietPlan()
          this.vm.showCheckedFoods = false;
        })
      }

      Divider().strokeWidth('1px').margin({ bottom: 4 })
      List({ scroller: this.vm.checkedScroller }) {
        ForEach(this.vm.selectFoods, (item: FoodCalories) => {
          ListItem() {
            Column() {
              Row() {
                Column() {
                  Text(item.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`${item.calories}千卡/${item.weight}克`)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Checkbox({ name: `${item.id}`, group: `foodGroup` })
                  .select(this.vm.selectFoods.some(food => food.id === item.id))
                  .height(20)
                  .width(20)
                  .selectedColor('#64BB5C')
                  .shape(CheckBoxShape.CIRCLE)
                  .onClick(() => {
                    this.vm.changeFood(item);
                    if (this.vm.selectFoods.length === 0) {
                      this.vm.showCheckedFoods = false;
                    }
                  })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width(CommonConstants.FULL_WIDTH)
              .padding({ top: 12, bottom: 4, left: 4 })

              Divider().strokeWidth('1px').margin({ bottom: 12 })
            }
          }
        }, (item: FoodCalories) => item.id.toString())
      }
    }
    .backgroundColor(this.colorMode === 1 ? $r('sys.color.comp_background_gray') : '')
    .padding({ left: 28, right: 28 })
    .margin({ top: 6 })
  }
}
