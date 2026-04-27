import { MyControl } from '../model/Index';
import { PersistenceV2 } from '@kit.ArkUI';




@ObservedV2
export class RemotePageVM {
  @Trace myControl: MyControl = PersistenceV2.connect<MyControl>(MyControl, () => new MyControl())!;
  @Trace delId: string = '';
  private static _instance: RemotePageVM;

  public static get instance() {
    if (!RemotePageVM._instance) {
      RemotePageVM._instance = new RemotePageVM();
    }
    return RemotePageVM._instance;
  }
}