import { CustomContentDialog, TipsDialog } from '@kit.ArkUI';
import { RouterMap, CommonDivider, IParam } from 'module_base';
import { TemplateListPageVM } from '../viewmodel/TemplateListPageVM';
import { ITemplate } from '../http/Type';
import { CommonUtils } from '../common/Utils';
import { Context, ctx } from '../common/Context';

@Builder
export function TemplateListPageBuilder() {
  TemplateListPage()
}

@Entry
@ComponentV2
struct TemplateListPage {
  vm: TemplateListPageVM = TemplateListPageVM.instance
  @Local
  public ctx: Context = ctx
  dialogControllerDelete: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否删除当前模板?',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          if (this.vm.selectedTemplate) {
            this.vm.deleteTemplate(this.vm.selectedTemplate.id)
          }
        },
      },
    }),
  })
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      contentAreaPadding: {
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
      },
    }),
    cancel: () => {
      this.vm.editName = ''
    },
  })

  build() {
    NavDestination() {
      Column() {
        List() {
          ForEach(this.vm.templateList, (template: ITemplate) => {
            ListItem() {
              Column() {
                Column() {
                  Row() {
                    Image($r('app.media.ic_more'))
                      .width(24)
                      .height(24)
                      .onClick(() => {
                        this.vm.selectedTemplate = template
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ bottom: 13 })

                  this.contentBuilder('物品类型', template.goods.name)
                  CommonDivider()
                  this.contentBuilder('物品重量', template.weight.toString())
                  CommonDivider()
                  this.contentBuilder('寄件方式', CommonUtils.getShippingMethodValue(template.shippingMethod))
                  CommonDivider()
                  this.contentBuilder('付款方式', CommonUtils.getPaymentMethodValue(template.paymentMethod))

                  Row() {
                    Button('去寄件', { controlSize: ControlSize.SMALL })
                      .width(60)
                      .fontColor(Color.White)
                      .backgroundColor('#0A59F7')
                      .onClick(() => {
                        if (typeof this.ctx.onPushPath === 'function') {
                          this.ctx.onPushPath(template.id)
                          return
                        }
                        const param: IParam = {
                          templateId: template.id,
                        }

                        this.vm.stack.removeByName(RouterMap.EXPRESS_PAGE)
                        this.vm.stack.pushPath({ name: RouterMap.EXPRESS_PAGE, param })
                        this.vm.stack.removeByName(RouterMap.TEMPLATE_LIST_PAGE)
                        this.vm.stack.removeByName(RouterMap.TEMPLATE_PAGE)
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ top: 12 })
                }
                .borderRadius(16)
                .backgroundColor(Color.White)
                .padding(12)

                Row() {
                  Text(template.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                }
                .width(56)
                .height(37)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#999999')
                .borderRadius({ topLeft: 16, bottomRight: 14 })
                .position({ top: 0, left: 0 })

                if (this.vm.showEditButton(template)) {
                  Column() {
                    Row() {
                      Text('修改模板名称')
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_secondary'))
                    }
                    .onClick(() => {
                      this.editDialogController.open()
                    })

                    CommonDivider()

                    Row() {
                      Text('编辑模板')
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_secondary'))
                    }
                    .onClick(() => {
                      this.vm.stack.pushPath({ name: RouterMap.TEMPLATE_PAGE, param: this.vm.selectedTemplate })
                    })

                    CommonDivider()

                    Row() {
                      Text('删除模板')
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor('#E84026')
                    }
                    .onClick(() => {
                      this.dialogControllerDelete.open()
                    })
                  }
                  .width(108)
                  .padding(12)
                  .position({ right: 12, top: 44 })
                  .backgroundColor(Color.White)
                  .shadow({
                    offsetX: 0,
                    offsetY: 4,
                    radius: 4,
                    color: 'rgba(0,0,0,0.25)',
                  })
                  .borderRadius(8)
                  .zIndex(99)
                }
              }
            }
            .margin({ bottom: 12 })
          }, (item: ITemplate) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.vm.selectedTemplate = undefined
      })
    }
    .backgroundColor('#F1F3F5')
    .title('自定义模板')
    .onReady((context) => {
      this.vm.setStack(context.pathStack);
    })
    .onShown(() => {
      this.vm.init()
    })
  }

  @Builder
  contentBuilder(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('修改模板名称')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            TextInput({ text: $$this.vm.editName, placeholder: '请输入模板名称' })
              .placeholderColor('#999999')
              .placeholderFont({ size: 14, weight: FontWeight.Regular })
              .height(40)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(40)
          .padding({ left: 12, right: 12 })
          .margin({ bottom: 18 })
          .backgroundColor('rgba(0,0,0,0.05)')
          .borderRadius(8)

          Row() {
            Row() {
              Text('取消')
            }
            .width('50%')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.vm.editName = ''
              this.editDialogController.close()
            })

            Row() {
              Button('确认')
                .width('100%')
                .height(40)
                .backgroundColor('#0A59F7')
            }
            .width('50%')
            .height(40)
            .onClick(async () => {
              const res = await this.vm.update()
              if (res) {
                this.editDialogController.close()
                this.vm.selectedTemplate = undefined
              }
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 24,
          right: 24,
        })
        .backgroundColor('rgba(255,255,255,0.80)')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }
}