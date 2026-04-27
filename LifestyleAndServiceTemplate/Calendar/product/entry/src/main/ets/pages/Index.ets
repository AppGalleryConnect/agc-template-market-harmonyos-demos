import { ThemeModel } from 'common';
import { TabContainer } from './TabContainer'
import { PersistenceV2 } from '@kit.ArkUI';
import { RouterModule } from 'router_module';
import { IndexVM } from '../viewmodel/IndexVM';

@Entry
@ComponentV2
struct Index {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () =>new ThemeModel())!;
  vm: IndexVM = new IndexVM();

  aboutToAppear(): void {
    this.vm.displayOrientationListener()
    this.vm.registerBreakpointListener(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.vm.unregisterBreakpointListener();
  }


  build() {
    Navigation(RouterModule.getStack()) {
      TabContainer()
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}