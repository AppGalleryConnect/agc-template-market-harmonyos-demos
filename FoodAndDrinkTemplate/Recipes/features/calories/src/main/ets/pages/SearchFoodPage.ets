import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstants, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';
import { FoodCalories, MyMenuItem } from '../types/Index';
import { SearchFoodPageVM } from '../viewModels/SearchFoodPageVM';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function SearchFoodPageBuilder() {
  SearchFoodPage()
}

@ComponentV2
struct SearchFoodPage {
  @Local vm: SearchFoodPageVM = new SearchFoodPageVM();
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

  build() {
    NavDestination() {
      if (this.vm.searchResul.length) {
        List({ space: 12 }) {
          ForEach(this.vm.searchResul, (item: FoodCalories, index: number) => {
            ListItem() {
              Column() {
                Column() {
                  Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
                  Text(`${item.calories}千卡/${item.weight ?? 100}克`)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 2 })
                }.width('100%').alignItems(HorizontalAlign.Start)

                Divider().strokeWidth('1px').margin({ top: 4 })
              }.onClick(() => {
                this.vm.isShowArray[index] = true
              })
            }.bindSheet($$this.vm.isShowArray[index], this.addFoodSheet(item, index), {
              height: 533,
              blurStyle: BlurStyle.Thick,
              preferType: SheetType.CENTER,
              showClose: false,
            });
          }, (item: FoodCalories, index: number) => JSON.stringify(item.name + index))
        }
        .margin({ left: 16, right: 16 })
        .width('100%')
        .constraintSize({ maxWidth: '100%' })
        .padding({ left: 12, right: 12 })
        .contentStartOffset(10)
        .contentEndOffset(10)
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
          Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
        }.margin({ top: 72 }).width(CommonConstants.FULL_WIDTH);
      }
    }
    .title(this.buildTitleBar(), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: 40 })
  }

  @Builder
  addFoodSheet(item: FoodCalories, index: number) {
    Column() {
      Column() {
        Row().width(48).height(4).backgroundColor($r('sys.color.icon_fourth')).borderRadius(2)
        Row() {
          Select(this.vm.menuList)
            .selected(this.vm.selectIndex)
            .value(this.vm.selectText)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .fontColor($r('sys.color.font_primary'))
            .space(8)
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
            // this.vm.showAddFoodSheet = false
            this.vm.isShowArray[index] = false
          })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
      }

      Column() {
        Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
        Text(`${item.calories}千卡/${item.weight ?? 100}克`)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 2 })
        Divider().strokeWidth('1px').margin({ top: 4 })
        Text('请输入重量/容量')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 24 })
        Stack() {
          TextInput({ text: $$this.vm.inputText, placeholder: '100' })
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .placeholderColor($r('sys.color.font_secondary'))
            .enabled(false)
          Text('克').fontSize(16).fontColor($r('sys.color.font_tertiary')).margin({ right: 13 })
        }.alignContent(Alignment.End).margin({ top: 12 })
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .margin({ top: 8 })
      .padding(12)
      .borderRadius(16)

      Row({ space: 12 }) {
        Grid() {
          ForEach(this.vm.keyboardList, (item: string) => {
            GridItem() {
              Button(item, { type: ButtonType.Normal })
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .width(this.vm.getWidth)
                .height(this.vm.getHeight)
                .borderRadius($r('sys.float.corner_radius_level4'))
                .backgroundColor($r('sys.color.comp_background_primary'))
                .border({
                  width: { bottom: 1 },
                  color: { bottom: $r('sys.color.font_secondary') },
                  radius: 10,
                  style: BorderStyle.Solid
                })
                .onClick(() => {
                  this.vm.btnClick(item)
                })
            }
          }, (item: string) => item)
        }
        .width(this.vm.breakPointModel.currentBreakpoint === 'sm' ? 240 : 330)
        .height(this.vm.breakPointModel.currentBreakpoint === 'sm' ? 228 : 290)
        .rowsGap(12)
        .columnsGap(12)
        .columnsTemplate('1fr 1fr 1fr')

        Column({ space: 12 }) {
          Button({ type: ButtonType.Normal }) {
            Column() {
              SymbolGlyph($r('sys.symbol.delete_left'))
                .fontColor([$r('sys.color.icon_primary')])
                .fontSize(24)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
          .layoutWeight(1)
          .width('100%')
          .borderRadius($r('sys.float.corner_radius_level4'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .border({
            width: { bottom: 1 },
            color: { bottom: $r('sys.color.font_secondary') },
            radius: 10,
            style: BorderStyle.Solid
          })
          .onClick(() => {
            this.vm.deleteBtn()
          })

          Button('确定', { type: ButtonType.Normal })
            .layoutWeight(1)
            .width('100%')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .borderRadius($r('sys.float.corner_radius_level4'))
            .backgroundColor('#E84026')
            .border({
              width: { bottom: 1 },
              color: { bottom: $r('sys.color.font_secondary') },
              radius: 10,
              style: BorderStyle.Solid
            })
            .onClick(() => {
              this.vm.confirmBtn(item, index)
            })
        }
        .layoutWeight(1)
        .height(this.vm.breakPointModel.currentBreakpoint === 'sm' ? 228 : 290)
      }.margin({ top: 24 })
    }
    .backgroundColor(this.colorMode === 0 ? '' : $r('sys.color.comp_background_gray'))
    .width(CommonConstants.FULL_WIDTH)
    .height(533)
    .padding({ left: 16, right: 16, top: 8 })
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
  }

  @Builder
  buildTitleBar() {
    Row() {
      Search({ value: $$this.vm.searchText, placeholder: '请输入食物名称' })
        .textFont({ size: $r('sys.float.Body_L') })
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .maxLength(20)
        .layoutWeight(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onChange(() => {
          this.vm.searchFood()
        })
    }
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
    .padding({ left: 8, right: 12 })
  }
}
