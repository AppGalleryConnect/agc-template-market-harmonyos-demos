import { RecipeIngredient, Step, UploadRecipeData } from '../types/Index';
import { UploadRecipeVM } from '../viewModels/UploadRecipeVM';
import { LengthMetrics, promptAction, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { KeyboardAvoidMode } from '@kit.ArkUI';

@ComponentV2
export struct UploadRecipe {
  @Local vm: UploadRecipeVM = new UploadRecipeVM();
  @Event uploadRecipe: (data: UploadRecipeData) => void = () => {
  };
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    // 获取窗口实例并关闭避让
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE);
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text('标题').titleBaseStyle();
            TextInput({ placeholder: '请输入标题文本', text: this.vm.title })
              .height(35)
              .margin({ top: 12, bottom: 12 })
              .inputBaseExtend()
              .borderRadius(12)
              .maxLength(10)
              .onChange((res) => {
                this.vm.title = res;
              });

            Text('主图').titleBaseStyle();
            Text('图片尺寸16:9，支持上传图片，视频，动图，主体居中')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4, bottom: 12 });

            if (this.vm.mainImg) {
              Image(this.vm.mainImg).width(120).height(120).borderRadius(12).onClick(() => {
                this.vm.selectImage(this.context, 0).then(async res => {
                  this.vm.mainImg = await this.vm.showFile(res, this.getUIContext(), 0);
                });
              })
            } else {
              Column() {
                Image($r('app.media.ic_public_add')).width(20).fillColor($r('sys.color.font_tertiary'));
                Text('上传媒体文件').fontSize(14).fontColor($r('sys.color.font_tertiary')).margin({ top: 8 });
              }
              .width(120)
              .height(120)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.vm.selectImage(this.context, 0).then(async res => {
                  this.vm.mainImg = await this.vm.showFile(res, this.getUIContext(), 0);
                });
              });
            }

            Text('描述').titleBaseStyle().margin({ top: 15, bottom: 8 });
            TextArea({ placeholder: '请输入菜谱背后的故事', text: this.vm.description })
              .width('100%')
              .height(91)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius(12)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .maxLength(this.vm.maxLength)
              .placeholderFont({ size: 14 })
              .placeholderColor($r('sys.color.font_secondary'))
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
              .fontColor('#99000000');
          }.columnWrapExtend();

          Column() {
            Text('用料').titleBaseStyle().margin({ bottom: 4 });
            List({ space: 8 }) {
              ForEach(this.vm.ingredients, (item: RecipeIngredient, index) => {
                ListItem() {
                  Flex({ space: { main: LengthMetrics.vp(8) } }) {
                    TextInput({ placeholder: '食材', text: item.name })
                      .inputSmallExtend()
                      .borderRadius(8)
                      .maxLength(10)
                      .onChange((res) => {
                        item.name = res;
                      });
                    TextInput({ placeholder: '数量', text: item.quantity })
                      .inputSmallExtend()
                      .borderRadius(8)
                      .maxLength(10)
                      .onChange((res) => {
                        item.quantity = res;
                      });
                    TextInput({ placeholder: '单位', text: item.unit })
                      .inputSmallExtend()
                      .borderRadius(8)
                      .maxLength(10)
                      .onChange((res) => {
                        item.unit = res;
                      });
                  };
                }.swipeAction({
                  end: {
                    builder: () => {
                      this.itemEnd(index);
                    },
                  }, edgeEffect: SwipeEdgeEffect.Spring,
                });

              }, (item: RecipeIngredient, index) => item.name + item.unit + item.quantity + index);
            };


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
                  Text(`步骤${index + 1}`).titleBaseStyle();
                  if (item.stepImg) {
                    Image(item.stepImg).width(120).height(120).borderRadius(12).onClick(() => {
                      this.vm.selectImage(this.context, 1).then(async res => {
                        item.stepImg = await this.vm.showFile(res, this.getUIContext(), 1);
                      });
                    });
                  } else {
                    Column() {
                      Image($r('app.media.ic_public_add')).width(20).fillColor($r('sys.color.font_tertiary'));
                      Text('上传步骤图').fontSize(14).fontColor($r('sys.color.font_tertiary')).margin({ top: 8 });
                    }
                    .width(120)
                    .height(120)
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                    .borderRadius(12)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      this.vm.selectImage(this.context, 1).then(async res => {
                        item.stepImg = await this.vm.showFile(res, this.getUIContext(), 1);
                      });
                    });
                  }

                  TextInput({ placeholder: '请输入步骤说明', text: item.description })
                    .height(56)
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                    .borderRadius(12)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_primary'))
                    .placeholderFont({ size: 14 })
                    .placeholderColor($r('sys.color.font_secondary'))
                    .padding(12)
                    .maxLength(200)
                    .onChange((res) => {
                      item.description = res;
                    });

                  if (this.vm.steps.length === index + 1) {
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
                      this.vm.steps.push(new Step('', ''));
                    });
                  }
                }.columnWrapExtend().margin({ top: 12 });
              }.swipeAction({
                end: {
                  builder: () => {
                    this.stepEnd(index);
                  },
                }, edgeEffect: SwipeEdgeEffect.Spring,
              });
            }, (item: Step, index) => item.stepImg + index);
          };
        }.padding({ top: 12, bottom: 20 });
      }.height('calc(100% - 76vp)').align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

      Row() {
        Button('上传')
          .height(40)
          .width('100%')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#E84026')
          .onClick(() => {
            if (this.vm.isUploadValid()) {
              const data: UploadRecipeData = {
                description: this.vm.description,
                title: this.vm.title,
                mainImg: !this.vm.isMovingPhoto && this.vm.video ? '' : this.vm.mainImg,
                ingredients: this.vm.ingredients,
                steps: this.vm.steps,
                video: this.vm.video,
                coverUrl: this.vm.video ? this.vm.mainImg : '',
              }
              this.uploadRecipe(data)
            }
          });
      }
      .padding({
        left: 40,
        right: 40,
        top: 8,
        bottom: 20
      });
    }
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  @Builder
  itemEnd(index: number) {
    Row() {
      Text('删除')
        .padding(5)
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor('#E84026')
        .fontColor(Color.White)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .width(60)
        .height(36)
        .onClick(() => {
          if (this.vm.ingredients.length === 1) {
            this.getUIContext().getPromptAction().showToast({ message: '至少需要1份食材！' });
          } else {
            this.vm.ingredients.splice(index, 1);
          }

        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  @Builder
  stepEnd(index: number) {
    Row() {
      Text('删除')
        .padding(5)
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor('#E84026')
        .fontColor(Color.White)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .width(60)
        .height(36)
        .onClick(() => {
          if (this.vm.steps.length === 1) {
            this.getUIContext().getPromptAction().showToast({ message: '至少需要1个步骤！' });
          } else {
            this.vm.steps.splice(index, 1);
          }
        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  @Builder
  addContentBuilder() {
    Row() {
      Image($r('app.media.ic_public_add_circle'))
        .width(16)
        .height(16)
        .borderRadius(8)
    }
    .width(18)
    .height(18)
    .borderRadius(8)
    .justifyContent(FlexAlign.Center);

    Text('添加一行').fontSize(14).fontColor(Color.White);
  }
}

@Extend(TextInput)
function inputBaseExtend() {
  .fontSize(14)
  .fontColor($r('sys.color.font_primary'))
  .placeholderFont({ size: 14 })
  .placeholderColor($r('sys.color.font_secondary'))
  .backgroundColor($r('sys.color.comp_background_tertiary'));
}

@Extend(TextInput)
function inputSmallExtend() {
  .fontSize(12)
  .fontColor($r('sys.color.font_primary'))
  .placeholderFont({ size: 12 })
  .placeholderColor($r('sys.color.font_secondary'))
  .backgroundColor($r('sys.color.comp_background_tertiary'));
}

@Extend(Text)
function titleBaseStyle() {
  .fontSize(16).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
}

@Extend(Column)
function columnWrapExtend() {
  .width('100%')
  .backgroundColor($r('sys.color.comp_background_gray'))
  .padding({
    left: 16,
    right: 16,
    top: 12,
    bottom: 12,
  })
  .alignItems(HorizontalAlign.Start);
}
