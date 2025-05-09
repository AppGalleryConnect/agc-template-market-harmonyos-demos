import { HomePageVM } from '../viewModels/HomePageVM';
import TabBar from '../components/TabBar';
import {  PreferencesUtil } from 'commonlib';

@Builder
export function homePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  vm: HomePageVM = HomePageVM.instance;
  @Param  initSize: number = 0;

  async aboutToAppear() {
    PreferencesUtil.getChangeFontSize().then((value) => {
      this.vm.changeFontSize = value;
    });
  }

  build() {
    Column() {
      TabBar()
    }
  }
}