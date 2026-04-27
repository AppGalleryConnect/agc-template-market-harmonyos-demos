import { InvoiceInfo, InvoiceList, InvoiceType } from '../model/InvoiceModel';
import { AlertDialog } from '@kit.ArkUI';

/**
 * @usage: 发票抬头列表组件，展示已保存的发票抬头信息，支持编辑和删除操作
 * @layout: 单列布局，发票卡片列表+新增凭证按钮
 * @isGen: true
 * @fileType: component
 * @zhName: 发票抬头列表组件
 * @domain: 旅游
 * @subPage: AddInvoiceComp
 */
@ComponentV2
export struct InvoiceListComp {
  @Param @Require invoiceList: InvoiceList
  @Param routerModule: NavPathStack = new NavPathStack()
  @Local deleteInvoiceId: string = ''

  addClick() {
    this.routerModule.pushPathByName('AddInvoiceComp', null);
  }

  editClick(data: InvoiceInfo) {
    this.routerModule.pushPathByName('AddInvoiceComp', data);
  }

  deleteItem() {
    this.confirmDeleteDialog.open()
  }

  // 确认删除凭证提示弹窗
  private confirmDeleteDialog: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '确定删除凭证吗？',
      primaryButton: {
        value: '取消',
        fontColor: $r('sys.color.font_tertiary'),
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        fontColor: $r('sys.color.black'),
        action: () => {
          this.invoiceList.deleteById(this.deleteInvoiceId)
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    showInSubWindow: true,
    isModal: true,
    customStyle: false,
    cornerRadius: 32,
    width: 328,
  })

  @Builder
  titleBuilder(item: InvoiceInfo) {
    Row() {
      Text(item.title)
        .fontSize(16)
        .fontWeight(500)
        .fontColor('#000')
      Image($r('app.media.ic_edit_card'))
        .width(20)
        .height(20)
        .onClick(() => {
          this.editClick(item)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  cardContentRow(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .width(52)
        .fontSize(13)
        .fontColor('rgba(0, 0, 0, 0.50)')
      Text(value)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor('rgba(0, 0, 0, 0.50)')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  infoCardBuilder(item: InvoiceInfo) {
    Column({ space: 8 }) {
      this.titleBuilder(item)
      this.cardContentRow('类型', item.type)
      if (item.type !== InvoiceType.INDIVIDUAL) {
        this.cardContentRow('税号', item.taxID)
      }
      Row() {
        Text('删除')
          .textBtnStyle()
          .onClick(() => {
            this.deleteInvoiceId = item.id
            this.deleteItem()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .backgroundColor('#fff')
    .borderRadius(16)
    .padding(12)
  }

  @Builder
  addButton() {
    Row() {
      Row({ space: 5 }) {
        Image($r('app.media.ic_plus_circle'))
          .width(14)
          .height(14)
        Text('新增凭证')
          .fontSize(14)
          .fontColor('#333333')
      }
    }
    .width('100%')
    .borderRadius(24)
    .padding({ top: 13, bottom: 13 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff')
    .onClick(() => {
      this.addClick()
    })
  }

  build() {
    Column({ space: 10 }) {
      ForEach(this.invoiceList.list, (item: InvoiceInfo) => {
        this.infoCardBuilder(item)
      }, (item: InvoiceInfo) => JSON.stringify(item))
      this.addButton()
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function textBtnStyle() {
  .fontSize(12)
  .fontColor('rgba(0, 0, 0, 0.70)')
  .padding({
    top: 8,
    bottom: 8,
    left: 26,
    right: 26
  })
  .backgroundColor('#fff')
  .borderRadius(10)
  .border({ width: 1, color: 'rgba(0, 0, 0, 0.10)' })
}
