import { CommonConstants, RouterMap, RouterModule } from 'commonlib'
import { RecipeDetail } from 'network'
import { promptAction } from '@kit.ArkUI'
import { ShoppingBasketPageVM } from '../viewModels/ShoppingBasketPageVM'
import { BasketItem, IngredientItem } from '../types/Index'
import { BusinessError } from '@kit.BasicServicesKit'

@ComponentV2
export struct IngredientsComp {
  @Param @Require todoList: IngredientItem[]
  @Param @Require finishedList: IngredientItem[]
  @Param index: number = 9999
  @Param isAllTab: boolean = false
  @Local isExpand: boolean = true
  @Event todoCb: (item: IngredientItem) => void = () => {
  }
  @Event finishedCb: (item: IngredientItem) => void = () => {
  }

  build() {
    Column() {
      IngredientsList({
        list: this.todoList,
        isFinished: false,
        index: this.index,
        isAllTab: this.isAllTab,
        callback: (item: IngredientItem) => {
          this.todoCb(item)
        },
      })
      Row() {
        Row() {
          Text('已完成').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#E84026')
          Text(this.finishedList.length.toString())
            .fontSize(10)
            .fontColor($r('sys.color.font_on_primary'))
            .padding({
              top: 1,
              bottom: 1,
              left: 6,
              right: 6,
            })
            .backgroundColor('#E84026')
            .margin({ left: 12 })
            .borderRadius(8)
        }

        Image(this.isExpand ? $r('app.media.ic_expand') : $r('app.media.ic_collect'))
          .width(20)
          .height(20)
          .onClick(() => {
            this.isExpand = !this.isExpand
          })
      }
      .width(CommonConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: this.todoList.length ? 0 : 12, bottom: this.finishedList.length ? 0 : 12 })

      IngredientsList({
        list: this.finishedList,
        isFinished: true,
        index: this.index,
        callback: (item: IngredientItem) => {
          this.finishedCb(item)
        },
      }).visibility(this.isExpand ? Visibility.Visible : Visibility.None)
    }
  }
}

@ComponentV2
struct IngredientsList {
  @Param @Require list: IngredientItem[]
  @Param @Require isFinished: boolean
  @Param @Require index: number
  @Param isAllTab: boolean = false
  @Event callback: (item: IngredientItem) => void = () => {
  }

  build() {
    List({ space: 8 }) {
      ForEach(this.list, (item: IngredientItem) => {
        ListItem() {
          Row() {
            Checkbox({ name: item.name, group: `group${this.isFinished}${this.index}` })
              .select(this.isFinished)
              .height(24)
              .width(24)
              .selectedColor('#E84026')
              .shape(CheckBoxShape.CIRCLE)
              .onChange(() => {
                this.callback(item)
              })
            Text(item.name)
              .fontSize(12)
              .fontColor(this.isFinished ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
              .layoutWeight(1)
              .decoration(this.isFinished ? {
                type: TextDecorationType.LineThrough,
                color: $r('sys.color.font_secondary'),
                style: TextDecorationStyle.SOLID,
              } : {
                type: TextDecorationType.None,
                color: Color.Black,
                style: TextDecorationStyle.SOLID,
              })
              .margin({ left: 8 })
            Text() {
              Span(this.isAllTab && item.unit ? item.sum : item.quantity)
              Span(item.unit)
            }
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 12 })
            .visibility(this.isFinished ? Visibility.None : Visibility.Visible)
          }
          .width(CommonConstants.FULL_WIDTH)
          .padding({
            top: 8,
            bottom: 8,
            left: 12,
            right: 12,
          })
          .backgroundColor('#F1F3F5')
          .borderRadius(16)
        }
      }, (item: IngredientItem) => JSON.stringify(item))
    }.contentStartOffset(12)
    .contentEndOffset(12)
  }
}

@ComponentV2
export struct RecipeIngredientsComp {
  @Param @Require vm: ShoppingBasketPageVM

  build() {
    Column({ space: 12 }) {
      ForEach(this.vm.basketList.list, (item: BasketItem, index: number) => {
        RecipeIngredientComp({
          item,
          index,
          todoCb: (param: IngredientItem) => {
            item.todoList = item.todoList.filter(i => i.name !== param.name)
            item.finishedList.push(param)
          },
          finishedCb: (param: IngredientItem) => {
            item.finishedList = item.finishedList.filter(i => i.name !== param.name)
            item.todoList.push(param)
          },
          removeRecipe: (param: BasketItem) => {
            this.vm.basketList.list = this.vm.basketList.list.filter(i => i.id !== param.id)
          },
        })
      }, (item: BasketItem) => JSON.stringify(item))
    }
  }
}

@ComponentV2
struct RecipeIngredientComp {
  @Param @Require item: BasketItem
  @Param @Require index: number
  @Local showAddSheet: boolean = false
  @Local nameTemp: string = ''
  @Local quantityTemp: string = ''
  customDialogComponentId: number = 0
  @Event todoCb: (item: IngredientItem) => void = () => {
  }
  @Event finishedCb: (item: IngredientItem) => void = () => {
  }
  @Event removeRecipe: (item: BasketItem) => void = () => {
  }

  build() {
    Column({ space: 12 }) {
      Column({ space: 12 }) {
        Row() {
          Text(this.item.title).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
          Row() {
            Text('查看详情').fontSize(12).fontColor($r('sys.color.font_secondary'))
            Image($r('app.media.ic_right')).width(20).height(20).margin({ left: 4 })
          }.onClick(() => {
            RouterModule.push({ url: RouterMap.DISHES, param: { id: this.item.id } as RecipeDetail })
          })
        }.width(CommonConstants.FULL_WIDTH).justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 8 }) {
          Button({ controlSize: ControlSize.SMALL }) {
            Row() {
              Image($r('app.media.ic_add_white')).width(16).height(16)
              Text('添加用料')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_on_primary'))
                .margin({ left: 4 })
            }
          }
          .height(28)
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8,
          })
          .backgroundColor('#E84026')
          .onClick(() => {
            this.nameTemp = ''
            this.quantityTemp = ''
            this.showAddSheet = true
          })

          Button('删除', { controlSize: ControlSize.SMALL })
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .width(72)
            .padding({
              top: 4,
              bottom: 4,
              left: 8,
              right: 8,
            })
            .backgroundColor('#E84026')
            .onClick(() => {
              promptAction.openCustomDialog({
                builder: () => {
                  this.customDialogComponent(this.item, (item: BasketItem) => {
                    this.removeRecipe(item)
                  })
                },
                onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                  console.info('reason' + JSON.stringify(dismissDialogAction.reason))
                  console.log('dialog onWillDismiss')
                  if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                    dismissDialogAction.dismiss()
                  }
                  if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                    dismissDialogAction.dismiss()
                  }
                },
              }).then((dialogId: number) => {
                this.customDialogComponentId = dialogId
              })
                .catch((error: BusinessError) => {
                  console.error(`openCustomDialog error code is ${error.code}, message is ${error.message}`)
                })
            })
        }
        .bindSheet($$this.showAddSheet, this.addIngredientSheet(), {
          detents: [400, 401],
          title: { title: '添加用料' },
        })
      }.alignItems(HorizontalAlign.Start)

      Column() {
        IngredientsComp({
          todoList: this.item.todoList,
          finishedList: this.item.finishedList,
          index: this.index,
          todoCb: (param: IngredientItem) => {
            this.todoCb(param)
          },
          finishedCb: (param: IngredientItem) => {
            this.finishedCb(param)
          },
        })
      }
    }.padding({ top: 12, left: 16, right: 16 }).backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  customDialogComponent(item: BasketItem, removeRecipe: (item: BasketItem) => void) {
    Column() {
      Text('提示').fontSize(20).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary')).height(56)
      Text(`您确定要删除清单“${item.title}”吗？`).fontSize(14).fontColor($r('sys.color.font_primary'))
      Row({ space: 16 }) {
        Button('取消')
          .width(120)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E84026')
          .backgroundColor($r('sys.color.background_primary'))
          .onClick(() => {
            try {
              promptAction.closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              console.error(`closeCustomDialog error code is ${code}, message is ${message}`);
            }
          })
        Button('确定')
          .width(120)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E84026')
          .onClick(() => {
            try {
              removeRecipe(item)
              promptAction.closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              console.error(`closeCustomDialog error code is ${code}, message is ${message}`);
            }
          })
      }.margin({ top: 8 })
    }.width(CommonConstants.FULL_WIDTH).height(140).backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  addIngredientSheet() {
    Column() {
      Column() {
        Row() {
          Text('用料名').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary')).width(64)
          TextInput({ text: $$this.nameTemp, placeholder: '输入用料名' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .showUnderline(true)
            .layoutWeight(1)
        }.padding({ right: 28 })

        Row() {
          Text('数目|备注').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary')).width(64)
          TextInput({ text: $$this.quantityTemp, placeholder: '输入数目，备注等' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .showUnderline(true)
            .layoutWeight(1)
        }.padding({ right: 28 })
      }

      Button('确定')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#E84026')
        .width(CommonConstants.FULL_WIDTH)
        .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
        .margin({ left: 24, right: 24 })
        .onClick(() => {
          if (!this.nameTemp) {
            promptAction.showToast({ message: '输入用料名' })
            return
          }
          if (!this.quantityTemp) {
            promptAction.showToast({ message: '输入数目，备注等' })
            return
          }
          this.item.todoList.push(new IngredientItem(this.nameTemp, this.quantityTemp, ''))
          this.showAddSheet = false
        })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
    .margin({ left: 16, right: 16 })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .padding({
      top: 27,
      left: 12,
      right: 12,
      bottom: 28,
    })
  }
}