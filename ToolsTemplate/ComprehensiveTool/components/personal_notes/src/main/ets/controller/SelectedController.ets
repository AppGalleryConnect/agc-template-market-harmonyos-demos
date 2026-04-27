/**
 * 多选控制器
 */
@ObservedV2
export class SelectedController {
  private static _instance: SelectedController;

  public static get instance() {
    if (!SelectedController._instance) {
      SelectedController._instance = new SelectedController();
    }
    return SelectedController._instance;
  }
  /**
   * 是否处于多选状态
   */
  @Trace isCtrl: boolean = false;
  /**
   * 选中数量
   */
  @Trace selectedCount: number = 0;

  recoverInitState(){
    this.isCtrl = false;
    this.selectedCount = 0;
  }
}