import { contextUtil } from 'module_base';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();
  @Local isEnabled: boolean = true;

  aboutToAppear(): void {
    contextUtil.setUiContext(this.getUIContext())
    this.vm.setInterception();
  }

  build() {
    Navigation(this.vm.navStack) {
    }
    .hideNavBar(true)
    .enabled(this.isEnabled)
    .hideTitleBar(true)
  }
}