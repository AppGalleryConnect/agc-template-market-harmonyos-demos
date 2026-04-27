import { AvoidAreaUtil } from '../util/AvoidAreaUtil';
import { FoodCalories } from '../model/Calories';
import { MyMenuItem } from '../model/Index';
import { SearchFoodPageVM } from '../viewmodel/SearchFoodPageVM';
import { getInstance } from '../common/RouteStack';

@Builder
export function SearchFoodPageBuilder() {
  SearchFoodPage();
}

@ComponentV2
struct SearchFoodPage {
  @Local vm: SearchFoodPageVM = new SearchFoodPageVM();

  aboutToAppear(): void {
    this.vm.init();
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBarBuilder();

        if (this.vm.searchResul.length) {
          List({ space: 12 }) {
            ForEach(this.vm.searchResul, (item: FoodCalories) => {
              ListItem() {
                Column() {
                  Column() {
                    Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
                    Text(`${item.calories}千卡/${item.weight ?? 100}克`)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                      .margin({ top: 2 });
                  }.width('100%').alignItems(HorizontalAlign.Start);

                  Divider().margin({ top: 4 });
                }
                .onClick(() => {
                  this.vm.foodCalories = item;
                  this.vm.showAddFoodSheet = true;
                });
              };
            }, (item: FoodCalories) => JSON.stringify(item));
          }
          .bindSheet($$this.vm.showAddFoodSheet, this.addFoodSheet(this.vm.foodCalories!!), {
            height: 533,
            blurStyle: BlurStyle.Thick,
            showClose: false,
          })
          .margin({ left: 16, right: 16 })
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .padding({ left: 12, right: 12 })
          .contentStartOffset(10)
          .contentEndOffset(10)
          .scrollBar(BarState.Off);
        } else {
          Column() {
            Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
            Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
          }.margin({ top: 72 }).width('100%');
        }
      };
    }.hideTitleBar(true);
  }

  @Builder
  titleBarBuilder() {
    Row({ space: 8 }) {
      Image($r('app.media.chevron_left'))
        .size({ height: 40, width: 40 })
        .onClick(() => {
          getInstance().pop();
        });
      Search({ value: $$this.vm.searchText, placeholder: '请输入食物名称' })
        .textFont({ size: $r('sys.float.Body_L') })
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .maxLength(20)
        .layoutWeight(1)
        .onChange(() => {
          this.vm.searchFood();
        });
    }
    .margin({ top: AvoidAreaUtil.getTopHeight() })
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({
      left: 12,
      right: 12,
    });
  }

  @Builder
  addFoodSheet(item: FoodCalories) {
    Column() {
      Column() {
        Row().width(48).height(4).backgroundColor($r('sys.color.icon_fourth')).borderRadius(2);
        Row() {
          Select(this.vm.menuList)
            .selected(this.vm.selectIndex)
            .value(this.vm.selectText)
            .font({ size: 16, weight: FontWeight.Medium })
            .fontColor($r('sys.color.font_primary'))
            .space(16)
            .width(124)
            .optionWidth(224)
            .optionHeight(296)
            .menuItemContentModifier(new MyMenuItem())
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index);
              this.vm.selectIndex = index;
              if (text) {
                this.vm.selectText = text;
              }
            });
          Image($r('app.media.ic_close')).width(40).onClick(() => {
            this.vm.showAddFoodSheet = false;
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      };

      Column() {
        Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
        Text(`${item.calories}千卡/${item.weight ?? 100}克`)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 2 });
        Divider().strokeWidth(1).margin({ top: 4 });
        Text('请输入重量/容量')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 24 });
        Stack() {
          TextInput({ text: $$this.vm.inputText, placeholder: '100' })
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .placeholderColor($r('sys.color.font_secondary'))
            .enabled(false);
          Text('克').fontSize(16).fontColor($r('sys.color.font_secondary')).margin({ right: 13 });
        }.alignContent(Alignment.End).margin({ top: 12 });

      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('sys.color.background_primary'))
      .margin({ top: 8 })
      .padding(12)
      .borderRadius(16);

      Row({ space: 12 }) {
        Grid() {
          ForEach(this.vm.keyboardList, (item: string) => {
            GridItem() {
              Button(item, { type: ButtonType.Normal })
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .width(72)
                .height(48)
                .borderRadius(8)
                .backgroundColor($r('sys.color.background_primary'))
                .shadow({
                  offsetX: 0,
                  offsetY: 1,
                  color: '#90949C',
                  radius: 0,
                })
                .onClick(() => {
                  this.vm.btnClick(item);
                });
            };
          }, (item: string) => item);
        }
        .width(240)
        .height(228)
        .rowsGap(12)
        .columnsGap(12)
        .columnsTemplate('1fr 1fr 1fr');

        Column({ space: 12 }) {
          Button({ type: ButtonType.Normal }) {
            Image($r('app.media.ic_close')).width(24);
          }
          .layoutWeight(1)
          .width('100%')
          .borderRadius(8)
          .backgroundColor($r('sys.color.background_primary'))
          .onClick(() => {
            this.vm.deleteBtn();
          });

          Button('确定', { type: ButtonType.Normal })
            .layoutWeight(1)
            .borderRadius(8)
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#E84026')
            .onClick(() => {
              this.vm.confirmBtn(item, this.getUIContext());
            });
        }.layoutWeight(1).height(228);
      }.margin({ top: 24 });
    }
    .width('100%')
    .height(533)
    .padding({ left: 16, right: 16, top: 8 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: '100%' });
  }

  @Builder
  buildTitleBar() {
    Row() {
      Search({ value: $$this.vm.searchText, placeholder: '请输入食物名称' })
        .textFont({ size: $r('sys.float.Body_L') })
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .maxLength(20)
        .layoutWeight(1)
        .onChange(() => {
          this.vm.searchFood();
        });
    }
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
    .padding({ left: 8, right: 12 });
  }
}
