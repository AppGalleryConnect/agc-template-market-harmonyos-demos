import { HashSet } from '@kit.ArkTS';
import { ALL_CARD_TAB } from '../common/Enum';
import { NfcInfo } from '../db/NfcCardInfo';

@ObservedV2
export class CardListVM {
  private static _instance: CardListVM;
  @Trace currentIndex: number = ALL_CARD_TAB.TAB_INDEX_DOOR
  @Trace editMode: boolean | undefined = undefined
  @Trace data: NfcInfo[] = [];
  @Trace checked: HashSet<number> = new HashSet();
  @Trace allCheck: boolean = false;
  @Trace editModeDoor: boolean | undefined = undefined
  @Trace editModeBus: boolean | undefined = undefined
  @Trace editModeBank: boolean | undefined = undefined

  public static get instance() {
    if (!CardListVM._instance) {
      CardListVM._instance = new CardListVM();
    }
    return CardListVM._instance;
  }

  isEditMode(): boolean | undefined {
    switch (this.currentIndex) {
      case ALL_CARD_TAB.TAB_INDEX_DOOR:
      default:
        return this.editModeDoor;
      case ALL_CARD_TAB.TAB_INDEX_BUS:
        return this.editModeBus;
      case ALL_CARD_TAB.TAB_INDEX_BANK:
        return this.editModeBank;
    }
  }

  toggleEditMode() {
    switch (this.currentIndex) {
      case ALL_CARD_TAB.TAB_INDEX_DOOR:
      default:
        this.editModeDoor = !this.editModeDoor
        break;
      case ALL_CARD_TAB.TAB_INDEX_BUS:
        this.editModeBus = !this.editModeBus
        break;
      case ALL_CARD_TAB.TAB_INDEX_BANK:
        this.editModeBank = !this.editModeBank
        break;
    }
    this.editMode = this.isEditMode()
  }

  updateCheckAllState() {
    let allCheck = true;
    for (let dataElement of this.data) {
      if (!this.checked.has(dataElement.id)) {
        allCheck = false;
        break;
      }
    }
    this.allCheck = allCheck;
  }

  checkAll() {
    if (this.allCheck) {
      this.checked = new HashSet();
      this.allCheck = false;
    } else {
      let checked: HashSet<number> = new HashSet();
      for (let dataElement of this.data) {
        checked.add(dataElement.id);
      }
      this.checked = checked;
      this.allCheck = true;
    }
  }
}