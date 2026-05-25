@ObservedV2
export class AggreagetedAdVM {
  private static _instance: AggreagetedAdVM;

  public static get instance() {
    if (!AggreagetedAdVM._instance) {
      AggreagetedAdVM._instance = new AggreagetedAdVM();
    }
    return AggreagetedAdVM._instance;
  }


}