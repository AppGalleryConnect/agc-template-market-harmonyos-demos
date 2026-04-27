import { BillConstants } from '../commons/Constants';
import { BalanceChangeType } from '../commons/Enums';
import { BalanceResourceItem } from '../commons/Types';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { contextUtil } from '../utils/ContextUtil';
import { ResourceUtil } from '../utils/ResourceUtil';
import { ResourceManageVM } from '../viewmodels/ResourceManageVM';

export class ResourceManageSheetOptions {
  handleAddSuccess?: () => void;
  handleDeleteSuccess?: (key: number) => void;
}

@Builder
export function resourceManageSheetBuilder(options: ResourceManageSheetOptions) {
  ResourceManageSheet({
    handleAddSuccess: options.handleAddSuccess,
    handleDeleteSuccess: options.handleDeleteSuccess,
  });
}

@ComponentV2
export struct ResourceManageSheet {
  @Local
  openSheet: boolean = false;
  @Local
  dialogId: number = 0;
  @Event
  handleAddSuccess: () => void;
  @Event
  handleDeleteSuccess: (key: number) => void;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  vm: ResourceManageVM = new ResourceManageVM();

  @Computed
  get typeGridTemplate() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return '1fr 1fr 1fr 1fr 1fr'
    }
    return '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr'
  }

  aboutToAppear(): void {
    this.vm.resource = ResourceUtil.getResourceList();
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Text('长按拖动分类可排序，轻触用户自定义分类可编辑')
            .fontSize(BillConstants.FONT_SIZE_14)
            .fontColor(BillConstants.FONT_COLOR_LEVEL1)
            .margin({ bottom: 16 });
          this.typeOptionBuilder();
          this.resourceGroupBuilder();
        }
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .bindSheet($$this.openSheet, this.addResourceSheet(), {
          height: 240,
          preferType: SheetType.BOTTOM,
          title: { title: '添加分类' },
        });
      }
      .padding(16)
      .layoutWeight(1);
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Color.White);
  }

  @Builder
  typeOptionBuilder() {
    Row() {
      Text('支出')
        .typeOptionStyle(this.vm.balanceType === BalanceChangeType.EXPENSE, this.vm.balanceType)
        .onClick(() => {
          this.vm.handleTypeChange(BalanceChangeType.EXPENSE);
        });
      Text('收入')
        .typeOptionStyle(this.vm.balanceType === BalanceChangeType.INCOME, this.vm.balanceType)
        .onClick(() => {
          this.vm.handleTypeChange(BalanceChangeType.INCOME);
        });
    }
    .margin({ bottom: 24 });
  }

  @Builder
  resourceGroupBuilder() {
    Grid() {
      ForEach(this.vm.displayResourceList, (item: BalanceResourceItem) => {
        GridItem() {
          Column() {
            Image(item.icon).width(40).height(40).draggable(false);
            Text(item.name)
              .fontSize(BillConstants.FONT_SIZE_12)
              .fontWeight(FontWeight.Regular)
              .margin({ top: 12, bottom: 8 })
              .fontColor(BillConstants.FONT_COLOR_LEVEL1);
            if (item.isCustom) {
              Text('轻触编辑')
                .fontSize(BillConstants.FONT_SIZE_12)
                .fontColor(BillConstants.FONT_COLOR_LEVEL3)
                .fontWeight(FontWeight.Regular);
            }
          };
        }
        .onClick(() => {
          if (item.isCustom) {
            contextUtil.getPromptAction()?.openCustomDialog({
              builder: () => this.editCustomDialog(item),
              width: '90%',
              alignment: DialogAlignment.Center,
            })
              .then((id) => {
                this.dialogId = id;
              });
          }
        });
      }, (item: BalanceResourceItem) => item.key + '__' + item.name);
      GridItem() {
        Column() {
          Image($r('app.media.ic_add_resource')).width(40).height(40).draggable(false);
          Text('添加')
            .fontSize(BillConstants.FONT_SIZE_12)
            .fontWeight(FontWeight.Regular)
            .margin({ top: 12, bottom: 12 })
            .fontColor(BillConstants.FONT_COLOR_LEVEL1);
        };
      }
      .onClick(() => {
        this.vm.editExist = false;
        this.vm.customResourceName = '';
        this.openSheet = true;
      });
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate(this.typeGridTemplate)
    .rowsGap(36)
    .editMode(true)
    .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
      if (itemIndex === this.vm.displayResourceList.length) {
        return undefined;
      }
      return this.pixelMapBuilder(this.vm.displayResourceList[itemIndex].icon);
    })
    .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number,
      isSuccess: boolean) => {
      if (!isSuccess) {
        return;
      }
      this.vm.customSortResource(itemIndex, insertIndex);
    });
  }

  @Builder
  addResourceSheet() {
    Column() {
      TextInput({ text: this.vm.customResourceName, placeholder: '不能与已有类型名重复' })
        .maxLength(4)
        .showCounter(true)
        .backgroundColor(BillConstants.BACKGROUND_COLOR)
        .onChange((value) => {
          this.vm.customResourceName = value;
        });
      Blank();
      Flex() {
        Button('取消')
          .backgroundColor(BillConstants.BACKGROUND_COLOR_GREY_2)
          .fontColor($r('sys.color.font_primary'))
          .flexGrow(1)
          .onClick(() => {
            this.openSheet = false;
            this.vm.customResourceName = '';
          });
        Blank().width(16);
        Button('确定')
          .backgroundColor(BillConstants.THEME_COLOR)
          .enabled(this.vm.customResourceName !== '')
          .flexGrow(1)
          .onClick(() => {
            const res = this.vm.addResource();
            if (res) {
              this.openSheet = false;
              this.handleAddSuccess?.();
              this.vm.selectedItem = undefined;
              contextUtil.getPromptAction()?.closeCustomDialog(this.dialogId);
            }
          });
      }
      .width('100%');
    }
    .height('100%')
    .padding(16)
  }

  @Builder
  pixelMapBuilder(imgStr: ResourceStr) { //拖拽过程样式
    Image(imgStr)
      .width(80)
      .height(80);
  }

  @Builder
  editCustomDialog(item: BalanceResourceItem) {
    Column({ space: 16 }) {
      Text('修改')
        .dialogTextStyle()
        .onClick(() => {
          this.openSheet = true;
          this.vm.editExist = true;
          this.vm.customResourceName = item.name;
          this.vm.selectedItem = item;
        });
      Text('删除')
        .dialogTextStyle()
        .fontColor(BillConstants.WARNING_COLOR)
        .onClick(() => {
          contextUtil.getPromptAction()?.showDialog({
            message: '删除类型会同时删除该类型下的所有记账数据，并且无法恢复。请确认是否删除？',
            buttons: [
              {
                text: '取消',
                color: BillConstants.FONT_COLOR_LEVEL1,

              },
              {
                text: '删除',
                color: BillConstants.WARNING_COLOR,
              },
            ],
            alignment: DialogAlignment.Center,
          })
            .then(data => {
              if (data.index === 1) {
                this.vm.deleteResource(item.key, this.dialogId, this.handleDeleteSuccess);
              }
            });
        });
      Text('取消')
        .dialogTextStyle()
        .onClick(() => {
          contextUtil.getPromptAction()?.closeCustomDialog(this.dialogId);
        });
    }
    .padding(16);
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
    top: 12,
    bottom: 12,
  })
  .borderRadius(BillConstants.BORDER_RADIUS_CAPSULE)
  .margin({ right: 12 });
}

@Extend(Text)
function dialogTextStyle() {
  .fontSize(BillConstants.FONT_SIZE_16)
  .fontWeight(FontWeight.Medium)
  .fontColor(BillConstants.FONT_COLOR_LEVEL1);
}