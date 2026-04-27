import { UIDialog } from '@hw-agconnect/ui-dialog';
import { BottomBtn, CommonEmpty, CommonTitle, PageStatus } from 'lib_foundation';
import { TemplateListPageVM } from '../viewmodel/TemplateListPageVM';
import { CommonUtils } from '../common/Utils';
import { MoreMenuItem, TemplateInfo } from '../models/Model';

@Builder
export function TemplateListPageBuilder() {
  TemplateListPage()
}

@Entry
@ComponentV2
struct TemplateListPage {
  vm: TemplateListPageVM = new TemplateListPageVM();

  // 模板列表更多操作菜单
  moreMenuList: MoreMenuItem[] = [
    {
      name: '修改模板名称',
      onClick: (template: TemplateInfo) => { this.modifyTemplateName(template) }
    },
    {
      name: '编辑模板',
      onClick: (template: TemplateInfo) => { this.vm.editTemplate(template) }
    },
    {
      name: '删除模板',
      fontColor: $r('sys.color.warning'),
      onClick: (template: TemplateInfo) => { this.vm.deleteTemplate(template) }
    },
  ]

  // 更新修改模板名称
  modifyTemplateName(template: TemplateInfo) {
    this.vm.editName = template.name;
    UIDialog.open({
      showConfirmButton: true,
      showCancelButton: true,
      contentBuilder: (): void => this.modifyNameInputBuilder(),
      confirmButtonOptions: {
        buttonFontColor: $r('sys.color.font_emphasize'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_secondary'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent
      },
      onConfirm: () => {
        this.vm.updateName(template)
      },
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '我的模板'
      })
      Column() {
        if (this.vm.pageStatus === PageStatus.SUCCESS) {
          List({ space: 12 }) {
            Repeat(this.vm.newTemplateList)
              .each((templateInfo: RepeatItem<TemplateInfo>) => {
                ListItem() {
                  this.templateCard(templateInfo.item)
                }
              })
              .key((item: TemplateInfo) => JSON.stringify(item))
          }
          .width('100%')
          .height('100%')
          .lanes(this.vm.listLanes, 12)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding
          })
        } else if (this.vm.pageStatus === PageStatus.EMPTY) {
          this.emptyView()
        }
      }
      .layoutWeight(1)
      .padding({ bottom: this.vm.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onWillShow(() => {
      // 获取我的模板列表
      this.vm.getTemplateList()
    })
  }

  @Builder
  templateCard(template: TemplateInfo) {
    Column() {
      Row() {
        Text(template.name)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16)
          .fontWeight(700)
          .lineHeight(21)

        Button() {
          SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .type(ButtonType.Normal)
        .width(24)
        .height(24)
        .backgroundColor(Color.Transparent)
        .bindMenu(this.moreMenuBuilder(template))
      }
      .width('100%')
      .padding(12)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .borderRadius({ topLeft: 16, topRight: 16 })

      Column({ space: 12 }) {
        this.contentBuilder('物品类型', template.goodsName)
        Divider().color($r('sys.color.comp_divider'))

        this.contentBuilder('物品重量', template.goodsWeight + 'kg')
        Divider().color($r('sys.color.comp_divider'))

        this.contentBuilder('寄件方式', CommonUtils.getShippingMethodValue(template.shippingMethod))
        Divider().color($r('sys.color.comp_divider'))

        this.contentBuilder('付款方式', CommonUtils.getPaymentMethodValue(template.paymentMethod))

        this.shippingBtnBuilder(template.id)
      }
      .backgroundColor(Color.White)
      .padding(12)
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    }
  }

  @Builder
  moreMenuBuilder(template: TemplateInfo) {
    List() {
      ForEach(this.moreMenuList, (item: MoreMenuItem) => {
        ListItem() {
          Row() {
            Text(item.name)
              .fontSize(16)
              .fontWeight(500)
              .lineHeight(21)
              .fontColor(item.fontColor || $r('sys.color.font_primary'))
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            item.onClick(template)
          })
        }
      }, (item: MoreMenuItem) => JSON.stringify(item))
    }
    .width(152)
    .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider') })
    .scrollBar(BarState.Off)
  }

  @Builder
  modifyNameInputBuilder() {
    Column() {
      Text('修改模板名称')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      Row() {
        TextInput({ text: $$this.vm.editName, placeholder: '请输入模板名称' })
          .placeholderColor($r('sys.color.font_tertiary'))
          .placeholderFont({ size: 14, weight: FontWeight.Regular })
          .height(40)
          .fontSize(14)
          .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .height(40)
      .margin({ top: 16 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(8)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  emptyView() {
    Column() {
      Column({space: 12}) {
        CommonEmpty({
          emptyDesc: '暂无模版，快去添加吧',
          emptyIcon: $r('app.media.img_template_empty')
        })
      }
      .layoutWeight(1)
      .margin({ bottom: 40 })
      .justifyContent(FlexAlign.Center)

      BottomBtn({
        text: '添加我的模版',
        onAction: () => {
          this.vm.addMyTemplate()
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  contentBuilder(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  shippingBtnBuilder(id: number) {
    Row() {
      Button('去寄件')
        .width(72)
        .height(28)
        .onClick(() => {
          this.vm.shipping(id)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .margin({ top: 12 })
  }
}