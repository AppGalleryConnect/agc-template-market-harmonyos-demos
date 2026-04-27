import { KeyboardAvoidMode, window } from '@kit.ArkUI'
import { AddBillVM } from '../viewmodels/AddBillVM';
import { CustomKeyboard } from './CustomKeyboard';
import { BillConstants } from '../commons/Constants';
import { BalanceChangeType } from '../commons/Enums';
import { BalanceResourceItem } from '../commons/Types';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { BillManageModel } from '../commons/Models';
import { UtilLog } from '@hw-agconnect/util-log';

export class BillManageSheetOptions {
  initBill?: BillManageModel;
  handleConfirm?: (data: BillManageModel) => void;
  handleResourceManage?: () => void;
}

@Builder
export function billManageSheetBuilder(options: BillManageSheetOptions) {
  BillManageSheet({
    initBill: options.initBill,
    handleConfirm: (data) => {
      options?.handleConfirm?.(data);
    },
    handleResourceManage: () => {
      options?.handleResourceManage?.();
    },
  });
}

@ComponentV2
export struct BillManageSheet {
  @Param
  initBill: BillManageModel | undefined = undefined;
  vm: AddBillVM = new AddBillVM();
  @Event
  handleConfirm: (data: BillManageModel) => void;
  @Event
  handleResourceManage: () => void;
  @Local
  resourceGridH: number = 300;
  @Local
  inputBottom: number = 0
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  @Computed
  get typeGridTemplate() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return '1fr 1fr 1fr 1fr 1fr'
    }
    return '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr'
  }

  @Monitor('initBill')
  initData() {
    if (this.initBill) {
      this.vm.handleBillInitialization(this.initBill);
    }
  }

  async aboutToAppear() {
    this.initData();
    BreakpointSystem.register(this.getUIContext())
    // 自定义键盘避让
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE)
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        currentWindow.on('keyboardHeightChange', this.changeInputBottom.bind(this))
      })
    } catch (e) {
      UtilLog.error(`setKeyboardAvoidMode failed with error ${JSON.stringify(e)}`);
    }
  }

  aboutToDisappear(): void {
    // 恢复默认键盘避让
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        currentWindow.off('keyboardHeightChange', this.changeInputBottom)
      })
    } catch (e) {
      UtilLog.error(`keyboardHeightChangeOff failed with error ${JSON.stringify(e)}`);
    }
  }

  changeInputBottom(data: number) {
    this.inputBottom = data ? 80 : 0
    this.resourceGridH = 300 - this.inputBottom;
    this.vm.scroller.scrollToIndex(this.vm.selectedIndex, true)
  }

  build() {
    Column() {
      // 账单类型选择
      this.typeOptionBuilder();
      Scroll() {
        Column() {
          // 账单来源选择
          this.resourceGroupBuilder();
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .padding(16);

      // 金额和自定义信息输入
      CustomKeyboard({
        inputBottom: this.inputBottom,
        initBill: this.initBill,
        amountArr: [this.initBill ? this.initBill.amount.toString() : ''],
        handleConfirm: (amountArr: string[], note: string, date: Date) => {
          const res = this.vm.handleKeyboardChange(amountArr, note, date);
          if (res) {
            this.handleConfirm?.(this.vm.billData);
          }
        },
      });
    }
    .backgroundColor(BillConstants.BACKGROUND_COLOR_GREY)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%');
  }

  @Builder
  typeOptionBuilder() {
    Row() {
      Text('支出')
        .typeOptionStyle(this.vm.billData.type === BalanceChangeType.EXPENSE, this.vm.billData.type)
        .onClick(() => {
          this.vm.handleTypeChange(BalanceChangeType.EXPENSE);
        });
      Text('收入')
        .typeOptionStyle(this.vm.billData.type === BalanceChangeType.INCOME, this.vm.billData.type)
        .onClick(() => {
          this.vm.handleTypeChange(BalanceChangeType.INCOME);
        });
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding(16);
  }

  @Builder
  resourceGroupBuilder() {
    Grid(this.vm.scroller) {
      ForEach(this.vm.displayResourceList, (item: BalanceResourceItem, index: number) => {
        GridItem() {
          Column() {
            Image(this.vm.billData.resource === item.key ? item.icon : item.uncheckedIcon).width(40).height(40);
            Text(item.name)
              .resourceLabelStyle()
              .fontColor(this.vm.billData.resource === item.key ? BillConstants.FONT_COLOR_LEVEL1 :
                BillConstants.FONT_COLOR_LEVEL2);
          };
        }
        .onClick(() => {
          this.vm.handleResourceChange(item, index);
        });
      }, (item: BalanceResourceItem) => item.key + '__' + item.name);
      GridItem() {
        Column() {
          Image($r('app.media.ic_manage_resource')).width(40).height(40);
          Text('分类管理').resourceLabelStyle()
        };
      }
      .onClick(() => {
        this.handleResourceManage?.();
      });
    }
    .columnsTemplate(this.typeGridTemplate)
    .rowsGap(16)
    .height(this.resourceGridH)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring);
  }
}

@Extend(Text)
function typeOptionStyle(isChecked: boolean, type: BalanceChangeType) {
  .fontSize(BillConstants.FONT_SIZE_14)
  .fontColor(isChecked ? BillConstants.FONT_COLOR_1_INVERT : BillConstants.FONT_COLOR_LEVEL1)
  .backgroundColor(isChecked ?
    type === BalanceChangeType.EXPENSE ? BillConstants.THEME_COLOR : BillConstants.THEME_COLOR_SECOND :
    BillConstants.BACKGROUND_COLOR_GREY_2)
  .padding({
    left: 24,
    right: 24,
    top: 8,
    bottom: 8,
  })
  .borderRadius(BillConstants.BORDER_RADIUS_CAPSULE)
  .margin({ right: 12 });
}

@Extend(Text)
function resourceLabelStyle() {
  .fontSize(BillConstants.FONT_SIZE_12)
  .fontWeight(FontWeight.Regular)
  .margin({ top: 8 })
  .fontColor(BillConstants.FONT_COLOR_LEVEL2);
}