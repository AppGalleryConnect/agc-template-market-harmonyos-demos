import { BaseViewModel } from 'module_base'

@ObservedV2
export class MinePageVM extends BaseViewModel {
  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }
}
