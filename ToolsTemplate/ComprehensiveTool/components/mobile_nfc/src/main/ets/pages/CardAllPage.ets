import { ALL_CARD_TAB, NFC_TYPE } from '../common/Enum';
import { getMyNfcName } from '../common/nfc/Nfc';
import { CardListVM } from '../viewmodel/CardListVM';
import { CardAllView } from './CardListView';

@ComponentV2
struct CardAllPage {
  vm: CardListVM = CardListVM.instance;
  tabsController: TabsController = new TabsController();

  @Monitor('editModeDoor','editModeBus','editModeBank')
  editModeChange(monitor: IMonitor) {
    switch (this.vm.currentIndex) {
      case ALL_CARD_TAB.TAB_INDEX_DOOR:
      default:
        if (monitor.value()?.now === 'editModeDoor') {
          this.vm.editMode = this.vm.editModeDoor;
        }
        break;
      case ALL_CARD_TAB.TAB_INDEX_BUS:
        if (monitor.value()?.now === 'editModeBus') {
          this.vm.editMode = this.vm.editModeBus;
        }
        break;
      case ALL_CARD_TAB.TAB_INDEX_BANK:
        if (monitor.value()?.now === 'editModeBank') {
          this.vm.editMode = this.vm.editModeBank;
        }
        break;
    }
  }

  onBackPress(): boolean | void {
    return this.back();
  }

  private back(): boolean {
    if (this.vm.editMode) {
      this.vm.toggleEditMode();
      return true;
    }
    return false;
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.Start,
        index: this.vm.currentIndex,
        controller: this.tabsController,
      }) {
        TabContent() {
          CardAllView({
            isShowTitle: false,
            nfcType: NFC_TYPE.NFC_TYPE_DOOR,
            index: ALL_CARD_TAB.TAB_INDEX_DOOR,
            editMode: this.vm.editModeDoor,
            clonePage: false,
          });
        }
        .tabBar(this.TabBuilder(ALL_CARD_TAB.TAB_INDEX_DOOR, getMyNfcName(NFC_TYPE.NFC_TYPE_DOOR)));

        TabContent() {
          CardAllView({
            isShowTitle: false,
            nfcType: NFC_TYPE.NFC_TYPE_BUS,
            index: ALL_CARD_TAB.TAB_INDEX_BUS,
            editMode: this.vm.editModeBus,
            clonePage: false,
          });
        }
        .tabBar(this.TabBuilder(ALL_CARD_TAB.TAB_INDEX_BUS, getMyNfcName(NFC_TYPE.NFC_TYPE_BUS)));

        TabContent() {
          CardAllView({
            isShowTitle: false,
            nfcType: NFC_TYPE.NFC_TYPE_BANK,
            index: ALL_CARD_TAB.TAB_INDEX_BANK,
            editMode: this.vm.editModeBank,
            clonePage: false,
          });
        }
        .tabBar(this.TabBuilder(ALL_CARD_TAB.TAB_INDEX_BANK, getMyNfcName(NFC_TYPE.NFC_TYPE_BANK)));
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.vm.currentIndex = index;
        this.vm.editMode = this.vm.isEditMode();
      });
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#eeeeee');
  }

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontSize(16)
        .fontColor(this.vm.currentIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'));
    }
    .justifyContent(FlexAlign.Center)
    .padding({ left: 12, right: 12 })
    .onClick(() => {
      this.vm.currentIndex = index;
      this.tabsController.changeIndex(this.vm.currentIndex);
    });
  }
}