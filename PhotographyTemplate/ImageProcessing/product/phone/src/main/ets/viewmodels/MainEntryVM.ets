import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { BaseViewModel, RouterMap, RouterModule } from 'commonlib';
import { HomePageBuilder } from 'home';
import { MinePageBuilder } from 'mine';
import { FormCardJumpModel, TabListItem } from '../models/Types';


@ObservedV2
export class MainEntryVM extends BaseViewModel {
  @Trace formModel: FormCardJumpModel = AppStorageV2.connect(FormCardJumpModel, () => new FormCardJumpModel())!;
  @Trace curIndex: number = 0;
  public tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('app.media.icon_house_fill_off'),
      iconChecked: $r('app.media.icon_house_fill_on'),
      component: wrapBuilder(HomePageBuilder),
    },
    {
      label: '我的',
      icon: $r('app.media.icon_person_fill_off'),
      iconChecked: $r('app.media.icon_person_fill_on'),
      component: wrapBuilder(MinePageBuilder),
    },
  ];

  @Computed
  get isTabVertical() {
    return this.breakPointModel.isTabVertical;
  }

  @Computed
  get barPosition() {
    if (this.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  @Computed
  get tabWidth(): Length {
    if (this.isTabVertical) {
      return 96;
    }
    return '100%';
  }

  @Computed
  get tabHeight(): Length {
    if (this.isTabVertical) {
      return 400;
    }
    return 48;
  }

  // 服务卡片
  @Monitor('formModel.formCardId')
  formCardChange() {
    if (this.formModel.formCardId) {
      this.jumpToFormCardPage();
    }
  }

  // 跳转到服务卡片的页面
  public jumpToFormCardPage() {
    if (!this.formModel.formCardPageUrl) {
      return;
    }
    // 清除路由栈中除Main页面之外的路由
    let pathNames: string[] = RouterModule.stack.getAllPathName();
    for (let i = pathNames.length - 1; i > 0; i--) {
      RouterModule.stack.removeByName(pathNames[i]);
    }
    const curPathName = this.formModel.formCardPageUrl;
    emitter.emit('formCardPageUrl', { data: {url: curPathName}});
    this.formModel.formCardId = '';
  }

  offEvent() {
    emitter.off('formCardPageUrl');
  }
}
