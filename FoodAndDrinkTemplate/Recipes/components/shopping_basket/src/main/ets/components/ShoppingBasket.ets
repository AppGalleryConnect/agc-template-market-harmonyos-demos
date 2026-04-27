import { BaseTabs, TabIndexEnum } from 'base_ui';
import { BasketItem, IngredientItem } from '../types/Index';
import { PurchaseIngredients } from './PurchaseIngredients';
import { Decimal } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct ShoppingBasket {
  @Param basketList: BasketItem[] = []
  @Local currentIndex: number = 1
  @Local selectItem: BasketItem = new BasketItem()
  @Local showAddSheet: boolean = false
  @Local nameTemp: string = ''
  @Local quantityTemp: string = ''
  customDialogComponentId: number = 0
  @Event goRecipeDetail: (id: number) => void = () => {
  }
  @Event removeRecipe: (item: BasketItem) => void = () => {
  }

  @Computed
  get todoList() {
    let todoListTemp: IngredientItem[] = []
    this.basketList.forEach(item => {
      item.todoList.forEach(todo => {
        let existItem = todoListTemp.find(i => i.name === todo.name)
        if (existItem) {
          if (Number.isInteger(todo.quantity) && existItem.unit) {
            existItem.sum = new Decimal(existItem.sum).add(todo.quantity).toString()
          } else {
            existItem.sumArr.push(todo.name)
          }
        } else {
          let todoTemp = new IngredientItem(todo.name, todo.quantity, todo.unit)
          if (todo.unit) {
            todoTemp.sum = todo.quantity
            todoListTemp.push(todoTemp)
          } else {
            todoTemp.sumArr.push(todo.name)
            todoListTemp.push(todoTemp)
          }
        }
      })
    })
    return todoListTemp
  }

  @Computed
  get finishedList() {
    let finishedListTemp: IngredientItem[] = []
    this.basketList.forEach(item => {
      item.finishedList.forEach(todo => {
        let noFinished = this.todoList.some(i => i.name === todo.name)
        if (!noFinished) {
          let existItem = finishedListTemp.some(i => i.name === todo.name)
          if (!existItem) {
            finishedListTemp.push(todo)
          }
        }
      })
    })
    return finishedListTemp
  }

  build() {
    Column() {
      BaseTabs({
        currentIndex: this.currentIndex,
        changeTabs: (index: number) => {
          this.currentIndex = index
        },
      }).margin({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12,
      })

      Scroll() {
        if (this.basketList.length) {
          Column() {
            PurchaseIngredients({
              todoList: this.todoList,
              finishedList: this.finishedList,
              isAllTab: true,
              todoCb: (item: IngredientItem) => {
                this.todoCb(item);
              },
              finishedCb: (item: IngredientItem) => {
                this.finishedCb(item);
              },
            })
              .backgroundColor($r('sys.color.background_primary'))
              .padding({ left: 16, right: 16 })
              .visibility(this.currentIndex === TabIndexEnum.FIRST ? Visibility.Visible : Visibility.None);
            Column({ space: 12 }) {
              ForEach(this.basketList, (item: BasketItem, index: number) => {
                Column({ space: 12 }) {
                  Column({ space: 12 }) {
                    Row() {
                      Text(item.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.font_primary'))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width(200)
                      Row() {
                        Text('查看详情').fontSize(12).fontColor($r('sys.color.font_secondary'))
                        Image($r('app.media.ic_public_right_arrow')).width(20).height(20).margin({ left: 4 })
                      }.onClick(() => {
                        this.goRecipeDetail(item.id)
                      })
                    }.width('100%').justifyContent(FlexAlign.SpaceBetween)

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
                        this.selectItem = item
                        this.showAddSheet = true
                      })

                      Button('删除', { controlSize: ControlSize.SMALL })
                        .fontSize($r('sys.float.Body_M'))
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
                          this.getUIContext().getPromptAction().openCustomDialog({
                            builder: () => {
                              this.customDialogComponent(item, (item: BasketItem) => {
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
                  }.alignItems(HorizontalAlign.Start)

                  Column() {
                    PurchaseIngredients({
                      todoList: item.todoList,
                      finishedList: item.finishedList,
                      index: index,
                      todoCb: (param: IngredientItem) => {
                        item.todoList = item.todoList.filter(i => i.name !== param.name)
                        item.finishedList.push(param)
                      },
                      finishedCb: (param: IngredientItem) => {
                        item.finishedList = item.finishedList.filter(i => i.name !== param.name)
                        item.todoList.push(param)
                      },
                    })
                  }
                }.padding({ top: 12, left: 16, right: 16 }).backgroundColor($r('sys.color.background_primary'))
              }, (item: BasketItem) => JSON.stringify(item))
            }
            .bindSheet($$this.showAddSheet, this.addIngredientSheet(), {
              detents: [400],
              preferType: SheetType.CENTER,
              title: { title: '添加用料' },
            })
            .visibility(this.currentIndex === TabIndexEnum.SECOND ? Visibility.Visible : Visibility.None);
          }.layoutWeight(1);
        } else {
          Column() {
            Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
            Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
          }.margin({ top: 72 }).width('100%');
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .backgroundColor(this.currentIndex === TabIndexEnum.FIRST || !this.basketList.length ?
      $r('sys.color.background_primary') :
      $r('sys.color.background_secondary'))
      .layoutWeight(1)
      .align(Alignment.Top)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }

  }

  @Builder
  customDialogComponent(item: BasketItem, removeRecipe: (item: BasketItem) => void) {
    Column() {
      Text('提示').fontSize(20).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary')).height(56)
      Text(`您确定要删除清单“${item.title}”吗？`).fontSize(14).fontColor($r('sys.color.font_primary'))
      Row({ space: 16 }) {
        Button('取消')
          .width(120)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#E84026')
          .backgroundColor($r('sys.color.background_primary'))
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              console.error(`closeCustomDialog error code is ${code}, message is ${message}`);
            }
          })
        Button('确定')
          .width(120)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E84026')
          .onClick(() => {
            try {
              removeRecipe(item)
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              console.error(`closeCustomDialog error code is ${code}, message is ${message}`);
            }
          })
      }.margin({ top: 8 })
    }.width('100%').height(140).backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  addIngredientSheet() {
    Column() {
      Column() {
        Row() {
          Text('用料名')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(90)
          TextInput({ text: $$this.nameTemp, placeholder: '输入用料名' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .showUnderline(true)
            .layoutWeight(1)
            .maxLength(10)
        }.padding({ right: 28 })

        Row() {
          Text('数目|备注')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(90)
          TextInput({ text: $$this.quantityTemp, placeholder: '输入数目，备注等' })
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.font_secondary'))
            .showUnderline(true)
            .layoutWeight(1)
            .maxLength(10)
        }.padding({ right: 28 })
      }

      Button('确定')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#E84026')
        .width('100%')
        .constraintSize({ maxWidth: '100%' })
        .margin({ left: 24, right: 24 })
        .onClick(() => {
          if (!this.nameTemp) {
            this.getUIContext().getPromptAction().showToast({ message: '输入用料名' })
            return
          }
          if (!this.quantityTemp) {
            this.getUIContext().getPromptAction().showToast({ message: '输入数目，备注等' })
            return
          }
          this.selectItem.todoList.push(new IngredientItem(this.nameTemp, this.quantityTemp, ''))
          this.showAddSheet = false
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .constraintSize({ maxWidth: '100%' })
    .margin({ left: 16, right: 16 })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .padding({
      top: 27,
      left: 12,
      right: 12,
      bottom: 28,
    })
  }

  todoCb(item: IngredientItem) {
    this.basketList.forEach(basket => {
      basket.todoList = basket.todoList.filter(i => i.name !== item.name)
      basket.finishedList.push(item)
    })
  }

  finishedCb(item: IngredientItem) {
    this.basketList.forEach(basket => {
      basket.finishedList = basket.finishedList.filter(i => i.name !== item.name)
      basket.todoList.push(item)
    })
  }
}
