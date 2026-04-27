import { AddMealEnum, DailyMeals, DietPlans, FoodPlanCalories } from '../model/Index';

@ComponentV2
export struct FoodDiary {
  @Param dietPlanList: DietPlans[] = [];
  @Local showAddSheet: boolean = false;
  @Local dailyMeals: DailyMeals[] =
    [new DailyMeals(0, $r('app.media.ic_breakfast'), '早餐'), new DailyMeals(1, $r('app.media.ic_lunch'), '午餐'),
      new DailyMeals(2, $r('app.media.ic_dinner'), '晚餐'), new DailyMeals(99, $r('app.media.ic_snack'), '加餐')];
  @Event addMeal: (id: number, isModify?: boolean) => void = () => {
  };

  @Monitor('dietPlanList')
  planChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      this.dailyMeals.forEach(item => {
        if (this.dietPlanList.some(i => i.name === item.title)) {
          item.isFinished = true;
        } else {
          item.isFinished = false;
        }
      });
    }
  }

  build() {
    Column() {
      Text('饮食计算').fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
      Grid() {
        ForEach(this.dailyMeals, (item: DailyMeals) => {
          GridItem() {
            Column() {
              Image(item.icon).width(24).height(24);
              Row() {
                Image(item.isFinished ? $r('app.media.ic_plan_checked') : $r('app.media.ic_plus_gray'))
                  .width(12)
                  .height(12);
                Text(item.title).fontSize(10).fontColor($r('sys.color.font_primary')).margin({ left: 2 });
              }.margin({ top: 4 });
            }
            .onClick(() => {
              if (item.id === AddMealEnum.ADD_MEAL) {
                this.showAddSheet = true;
              } else {
                if (item.isFinished) {
                  this.addMeal(item.id, true);
                } else {
                  this.addMeal(item.id);
                }
              }
            });
          };
        }, (item: DailyMeals) => item.id.toString());
      }
      .width('100%')
      .height(68)
      .rowsGap(10)
      .columnsGap(10)
      .padding(12)
      .borderRadius(16)
      .margin({ top: 12 })
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .backgroundColor($r('sys.color.background_primary'))
      .bindSheet($$this.showAddSheet, this.addSnackSheet(), {
        detents: [312, 313, 314],
        blurStyle: BlurStyle.Thick,
        showClose: true,
        title: { title: '加餐时间段' },
      });

      if (this.dietPlanList.length) {
        Column({ space: 12 }) {
          ForEach(this.dietPlanList, (meal: DietPlans) => {
            Column() {
              Row() {
                Column() {
                  Text(meal.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
                  Text(meal.desc).fontSize(10).fontColor($r('sys.color.font_secondary'));
                }.alignItems(HorizontalAlign.Start);

                Row() {
                  Text(`${meal.totalCalories}千卡`).fontSize(12).fontColor($r('sys.color.font_primary'));
                  Image($r('app.media.ic_plus')).width(16).margin({ left: 12 }).onClick(() => {
                    this.addMeal(meal.menuId, true);
                  });
                };
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider().margin({ top: 12, bottom: 12 });
              Column({ space: 14 }) {
                ForEach(meal.foodList, (food: FoodPlanCalories) => {
                  Row({ space: 8 }) {
                    Text(food.name)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_primary'))
                      .textAlign(TextAlign.Start)
                      .layoutWeight(1)
                      .height(36)
                      .borderRadius(8)
                      .padding({
                        top: 10,
                        bottom: 10,
                        left: 8,
                        right: 8,
                      })
                      .backgroundColor($r('sys.color.background_secondary'));
                    Text(`${food.weight}克`)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_primary'))
                      .textAlign(TextAlign.Start)
                      .width(80)
                      .height(36)
                      .borderRadius(8)
                      .padding({
                        top: 10,
                        bottom: 10,
                        left: 8,
                        right: 8,
                      })
                      .backgroundColor($r('sys.color.background_secondary'));
                    Text(`${food.calories}千卡`)
                      .fontSize(12)
                      .fontColor('#E84026')
                      .width(80)
                      .borderRadius(8)
                      .padding({
                        top: 10,
                        bottom: 10,
                        left: 8,
                        right: 8,
                      })
                      .textAlign(TextAlign.Start)
                      .backgroundColor($r('sys.color.background_secondary'));
                  }.width('100%');
                }, (food: FoodPlanCalories) => JSON.stringify(food));
              };

            }.padding(12).borderRadius(16).backgroundColor($r('sys.color.background_primary')).width('100%');
          }, (meal: DietPlans) => JSON.stringify(meal));
        }.margin({ top: 12, bottom: 12 });
      }
    }.alignItems(HorizontalAlign.Start);
  }

  @Builder
  addSnackSheet() {
    Column({ space: 12 }) {
      Text('上午加餐')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
        .borderRadius(12)
        .onClick(() => {
          this.addMeal(AddMealEnum.ADD_BREAKFAST);
          this.showAddSheet = false;
        });
      Text('中午加餐')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
        .borderRadius(12)
        .onClick(() => {
          this.addMeal(AddMealEnum.ADD_LUNCH);
          this.showAddSheet = false;
        });
      Text('晚上加餐')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
        .borderRadius(12)
        .onClick(() => {
          this.addMeal(AddMealEnum.ADD_DINNER);
          this.showAddSheet = false;
        });
    }.padding({ left: 28, right: 28 }).margin({ top: 17 });
  }
}
