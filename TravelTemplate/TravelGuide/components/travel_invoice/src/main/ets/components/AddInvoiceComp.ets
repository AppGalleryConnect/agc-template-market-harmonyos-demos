import { InvoiceInfo, InvoiceList, InvoiceType } from '../model/InvoiceModel';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { SafeAreaUtils } from '../utils/SafeAreaUtils';

export enum EditType {
  ADD = 0,
  EDIT = 1
}

/**
 * @usage: 发票抬头新增/编辑组件，支持企业、个人、非企业单位三种发票类型的添加和编辑
 * @layout: 单列布局，顶部导航栏+类型选择+抬头输入+税号输入+增值税专用发票开关+保存按钮
 * @isGen: true
 * @fileType: component
 * @zhName: 新增发票抬头组件
 * @domain: 旅游
 */
@Builder
export function AddInvoiceCompBuilder() {
  AddInvoiceComp();
}

@ComponentV2
export struct AddInvoiceComp {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local invoiceList: InvoiceList = AppStorageV2.connect(InvoiceList, () => new InvoiceList())!
  @Local type: EditType = EditType.ADD
  @Local data: InvoiceInfo = new InvoiceInfo()
  @Local invoiceInfo: InvoiceInfo | undefined;
  @Local statusBarHeight: number = 0
  @Local bottomSafeArea: number = 0
  invoiceTypeList: InvoiceType[] = [InvoiceType.ENTERPRISE, InvoiceType.INDIVIDUAL, InvoiceType.NON_ENTERPRISE_UNIT]

  @Computed
  get allowSave() {
    if (this.data.type === InvoiceType.INDIVIDUAL) {
      if (this.data.title && this.data.type) {
        return true
      }
    } else {
      if (this.data.title && this.data.type && this.data.taxID) {
        return true
      }
    }
    return false
  }

  getData(temp: InvoiceInfo | undefined) {
    if (!temp) {
      return
    }

    this.type = temp.title ? EditType.EDIT : EditType.ADD
    if (this.type === EditType.EDIT) {
      this.data.id = temp.id
      this.data.type = temp.type
      this.data.title = temp.title
      this.data.taxID = temp.taxID || ''
      this.data.isNeedVAD = temp.isNeedVAD || false
    }
  }

  saveData() {
    const taxIDRegex = /^[A-Za-z0-9]{1,18}$/;
    const titleRegex = /^[\u4e00-\u9fa5A-Za-z0-9]{1,30}$/;


    if (!titleRegex.test(this.data.title.trim())) {
      promptAction.showToast({ message: '公司抬头只能包含汉字、字母和数字' });
      return;
    }

    if (this.data.title.length > 30) {
      promptAction.showToast({ message: '公司抬头长度不能超过30个字符' });
      return;
    }

    // 非个人发票需要校验税号
    if (this.data.type !== InvoiceType.INDIVIDUAL) {
      if (!taxIDRegex.test(this.data.taxID.trim())) {
        promptAction.showToast({ message: '税号格式不正确，请输入1-18位数字和字母' });
        return;
      }
    }

    let invoiceInfo = new InvoiceInfo(this.data.type, this.data.title, this.data.taxID, this.data.isNeedVAD)
    if (invoiceInfo.type === InvoiceType.INDIVIDUAL) {
      invoiceInfo.taxID = ''
      invoiceInfo.isNeedVAD = false
    }
    if (this.type === EditType.ADD) {
      this.invoiceList.add(invoiceInfo)
    } else {
      invoiceInfo.id = this.data.id
      this.invoiceList.editData(invoiceInfo)
    }
    this.routerModule?.pop()
  }

  async aboutToAppear() {
    // 使用 getUIContext() 获取 UIContext，然后传递给 SafeAreaUtils
    const uiContext = this.getUIContext()
    // 异步更新真实值
    SafeAreaUtils.getStatusBarHeight(uiContext).then((height: number) => {
      if (height > 0) {
        this.statusBarHeight = height
      }
    })
    SafeAreaUtils.getBottomSafeArea(uiContext).then((height: number) => {
      if (height > 0) {
        this.bottomSafeArea = height
      }
    })
  }

  @Builder
  addContentBuilder() {
    Column({ space: 10 }) {
      Column() {
        this.typeSelectRow()
        this.inputRow('抬头', this.data.title, '必填，公司名称', (value) => {
          this.data.title = value
        })
        if (this.data.type !== InvoiceType.INDIVIDUAL) {
          this.inputRow('税号', this.data.taxID, '必填，纳税人识别号', (value) => {
            this.data.taxID = value
          })
        }
      }
      .contentCol()

      if (this.data.type !== InvoiceType.INDIVIDUAL) {
        this.needVADRow()
      }
    }
  }

  @Builder
  typeSelectRow() {
    Row({ space: 48 }) {
      Text('类型')
        .fontSize(14)
        .fontColor('#000')
      Row({ space: 13 }) {
        ForEach(this.invoiceTypeList, (item: InvoiceType) => {
          Row({ space: 5 }) {
            Image(this.data.type === item ? $r('app.media.ic_isSelected') : $r('app.media.ic_unselected'))
              .width(12)
              .height(12)
            Text(item)
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.50)')
          }
          .onClick(() => {
            this.data.type = item
          })
        }, (item: InvoiceType) => JSON.stringify(item))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
    }
    .height(46)
    .width('100%')
  }

  @Builder
  inputRow(label: string, data: string, placeholder: string, onChange: (value: string) => void, type?: InputType) {
    Row({ space: 48 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#000')
      TextInput({ text: data, placeholder: placeholder })
        .padding({ left: 0 })
        .type(type ? type : InputType.Normal)
        .height(46)
        .layoutWeight(1)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .inputFilter(label === '税号' ? '[a-zA-Z0-9]' : '')
        .maxLength(label === '抬头' ? 30 : label === '税号' ? 18 : undefined)
        .onChange((value) => onChange(value))
    }
    .width('100%')
  }

  @Builder
  needVADRow() {
    Column() {
      Row() {
        Column({ space: 6 }) {
          Text('需要增值税专用发票')
            .fontSize(14)
            .fontColor('#000')
          Text('请先与公司财务确认是否需要增值税发票')
            .fontColor('rgba(0, 0, 0, 0.30)')
            .fontSize(12)
        }
        .alignItems(HorizontalAlign.Start)

        Toggle({
          type: ToggleType.Switch,
          isOn: this.data.isNeedVAD
        })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .switchPointColor($r('sys.color.comp_background_list_card'))
          .onChange((isOn: boolean) => {
            this.data.isNeedVAD = isOn
          })
      }
      .padding({ top: 14, bottom: 14 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .contentCol()
  }

  @Builder
  saveButton() {
    Button('保存')
      .width('100%')
      .height(42)
      .backgroundColor(this.allowSave ? '#FEE231' : '#DBDBDB ')
      .fontColor($r('sys.color.font_primary'))
      .enabled(this.allowSave)
      .margin({ top: 84 })
      .borderRadius(24)
      .onClick(() => {
        this.saveData()
      })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      this.customHeader()
      this.addContentBuilder()
      this.saveButton()
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .padding({
      top: this.statusBarHeight,
      bottom: this.bottomSafeArea,
      left: 16,
      right: 16
    })
  }

  @Builder
  customHeader() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.routerModule?.pop()
      })

      Text(this.type === EditType.EDIT ? '编辑凭证' : '新增凭证')
        .fontSize(20)
        .fontWeight(400)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
    }
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .margin({ bottom: 20 })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.routerModule = ctx.pathStack;
      this.invoiceInfo = ctx.pathInfo.param as InvoiceInfo | undefined;
      this.getData(this.invoiceInfo)
    })
  }
}

@Extend(Column)
function contentCol() {
  .padding({
    left: 12,
    right: 12
  })
  .backgroundColor('#fff')
  .borderRadius(16)
  .width('100%')
}