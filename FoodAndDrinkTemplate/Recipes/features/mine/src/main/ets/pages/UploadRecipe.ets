import { UploadRecipeVM } from '../viewModels/UploadRecipeVM';
import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { RecipeIngredient } from 'network';
import { Step } from '../types/Index';

@Builder
export function UploadRecipeBuilder() {
  UploadRecipe();
}

@ComponentV2
struct UploadRecipe {
  vm: UploadRecipeVM = UploadRecipeVM.instance;
  scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.vm.clearData()
  }

  @Builder
  itemEnd(index: number) {
    Row() {
      Text('删除')
        .padding(5)
        .fontSize(16)
        .backgroundColor('#E84026')
        .fontColor(Color.White)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .width(60)
        .height(36)
        .onClick(() => {
          if (this.vm.ingredients.length === 1) {
            promptAction.showToast({ message: '至少需要1份食材！' });
          } else {
            this.vm.ingredients.splice(index, 1)
          }

        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  @Builder
  stepEnd(index: number) {
    Row() {
      Text('删除')
        .padding(5)
        .fontSize(16)
        .backgroundColor('#E84026')
        .fontColor(Color.White)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .width(60)
        .height(36)
        .onClick(() => {
          if (this.vm.steps.length === 1) {
            promptAction.showToast({ message: '至少需要1个步骤！' });
          } else {
            this.vm.steps.splice(index, 1)
          }
        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    NavDestination() {
      Column() {
        Scroll(this.scroller) {
          Column() {
            Column() {
              Text('标题').titleBaseStyle();
              TextInput({ placeholder: '请输入标题文本', text: this.vm.title })
                .height(35)
                .margin({ top: 12, bottom: 12 })
                .inputBaseExtend()
                .borderRadius(12)
                .onChange((res) => {
                  this.vm.title = res;
                });

              Text('主图').titleBaseStyle();
              Text('图片尺寸16:9，格式jpg/png，主体居中')
                .fontSize(12)
                .fontColor($r('app.string.font_color_gray'))
                .margin({ top: 4, bottom: 12 });

              if (this.vm.mainImg) {
                Image(this.vm.mainImg).width(120).height(120).borderRadius(12).onClick(() => {
                  this.vm.selectImage().then(res => {
                    this.vm.mainImg = res;
                  });
                });
              } else {
                Column() {
                  Image($r('app.media.ic_public_add')).width(20).fillColor('#66000000');
                  Text('上传主图').fontSize(14).fontColor('#66000000').margin({ top: 8 });
                }
                .width(120)
                .height(120)
                .backgroundColor('#F1F3F5')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.vm.selectImage().then(res => {
                    this.vm.mainImg = res;
                  });
                });
              }


              Text('描述').titleBaseStyle().margin({ top: 15, bottom: 8 });
              TextArea({ placeholder: '请输入菜谱背后的故事', text: this.vm.description })
                .width('100%')
                .height(91)
                .backgroundColor('#F1F3F5')
                .borderRadius(12)
                .fontSize(14)
                .maxLength(this.vm.maxLength)
                .placeholderFont({ size: 14 })
                .placeholderColor('#66000000')
                .padding({
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8,
                })
                .onChange((res) => {
                  this.vm.description = res;
                  this.vm.curLength = res.length;
                });
              Text(`${this.vm.curLength}/${this.vm.maxLength}`)
                .width('100%')
                .textAlign(TextAlign.End)
                .fontSize(12)
                .margin({ top: 14 })
                .fontColor($r('app.string.font_color_gray'));
            }.columnWrapExtend();

            Column() {
              Text('用料').margin({ bottom: 4 })
              List({ space: 8 }) {
                ForEach(this.vm.ingredients, (item: RecipeIngredient, index) => {
                  ListItem() {
                    Flex({ space: { main: LengthMetrics.vp(8) } }) {
                      TextInput({ placeholder: '食材', text: item.name })
                        .inputBaseExtend()
                        .borderRadius(8)
                        .onChange((res) => {
                          item.name = res;
                        });
                      TextInput({ placeholder: '数量', text: item.quantity })
                        .inputBaseExtend()
                        .borderRadius(8)
                        .onChange((res) => {
                          item.quantity = res;
                        });
                      TextInput({ placeholder: '单位', text: item.unit })
                        .inputBaseExtend()
                        .borderRadius(8)
                        .onChange((res) => {
                          item.unit = res;
                        });
                    }
                  }.swipeAction({
                    end: {
                      builder: () => {
                        this.itemEnd(index);
                      },
                    }, edgeEffect: SwipeEdgeEffect.Spring,
                  });

                }, (item: RecipeIngredient, index) => item.name + item.unit + item.quantity + index);
              }


              Row({ space: 4 }) {
                this.addContentBuilder();
              }
              .backgroundColor('#E84026')
              .width(92)
              .height(28)
              .borderRadius(14)
              .justifyContent(FlexAlign.Center)
              .margin({ top: 15 })
              .alignSelf(ItemAlign.End)
              .onClick(() => {
                this.vm.ingredients.push({ name: '', quantity: '', unit: '' });
              });

            }.columnWrapExtend().margin({ top: 8 });


            List() {
              ForEach(this.vm.steps, (item: Step, index) => {
                ListItem() {
                  Column({ space: 12 }) {
                    Text(`步骤${index + 1}`);
                    if (item.stepImg) {
                      Image(item.stepImg).width(120).height(120).borderRadius(12).onClick(() => {
                        this.vm.selectImage().then(res => {
                          item.stepImg = res;
                        });
                      });
                    } else {
                      Column() {
                        Image($r('app.media.ic_public_add')).width(20).fillColor('#66000000');
                        Text('上传步骤图').fontSize(14).fontColor('#66000000').margin({ top: 8 });
                      }
                      .width(120)
                      .height(120)
                      .backgroundColor('#F1F3F5')
                      .borderRadius(12)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => {
                        this.vm.selectImage().then(res => {
                          item.stepImg = res;
                        });
                      });
                    }

                    TextArea({ placeholder: '请输入步骤说明', text: item.description })
                      .height(56)
                      .backgroundColor('#F1F3F5')
                      .borderRadius(12)
                      .fontSize(14)
                      .placeholderFont({ size: 14 })
                      .placeholderColor('#66000000')
                      .padding(12)
                      .onChange((res) => {
                        item.description = res
                      })
                    Row({ space: 4 }) {
                      this.addContentBuilder();
                    }
                    .backgroundColor('#E84026')
                    .width(92)
                    .height(28)
                    .borderRadius(14)
                    .justifyContent(FlexAlign.Center)
                    .alignSelf(ItemAlign.End)
                    .onClick(() => {
                      this.vm.steps.push(new Step('', ''))
                    })

                  }.columnWrapExtend().margin({ top: 12 });
                }.swipeAction({
                  end: {
                    builder: () => {
                      this.stepEnd(index);
                    },
                  }, edgeEffect: SwipeEdgeEffect.Spring,
                });
              }, (item: Step, index) => item.stepImg + item.description + index)
            }

          }.padding({ top: 12, bottom: 20 });

        }.height('calc(100% - 76vp)').align(Alignment.Top).scrollBar(BarState.Off);

        Row() {
          Button('上传')
            .height(40)
            .width('100%')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#E84026')
            .onClick(() => {
              if (this.vm.isUploadValid()) {
                this.vm.uploadRecipe()
              }

            })
        }.height(76).width('100%').padding({ left: 40, right: 40, top: 24 });

      }.height('100%').backgroundColor('#F1F3F5');

    }.title('上传菜谱');
  }

  @Builder
  addContentBuilder() {
    Row() {
      Image($r('app.media.ic_public_add')).width(8).height(8).fillColor('#E84026');
    }
    .width(16)
    .height(16)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center);

    Text('添加一行').fontSize(14).fontColor(Color.White);
  }
}


@Extend(TextInput)
function inputBaseExtend() {
  .fontSize(14)
  .placeholderFont({ size: 14 })
  .placeholderColor('#66000000')
  .backgroundColor('#F1F3F5');
}

@Extend(Text)
function titleBaseStyle() {
  .fontSize(16).fontColor($r('app.string.font_color_black')).fontWeight(FontWeight.Medium);
}

@Extend(Column)
function columnWrapExtend() {
  .width('100%')
  .backgroundColor('#FFFFFF')
  .padding({
    left: 16,
    right: 16,
    top: 12,
    bottom: 12,
  })
  .alignItems(HorizontalAlign.Start);
}
