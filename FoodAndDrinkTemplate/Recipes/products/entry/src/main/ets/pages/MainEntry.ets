import { hdsMaterial } from '@kit.UIDesignKit';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { HdsTabs, HdsTabsController } from '@hms.hds.hdsBaseComponent';
import { CommentUtil, RouterMap, RouterModule } from 'commonlib';
import { TabListItem } from '../types/Types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';

@Builder
export function MainEntryBuilder() {
  MainEntry()
}

@ComponentV2
struct MainEntry {
  @Local vm: MainEntryVM = MainEntryVM.instance;
  private controller: HdsTabsController = new HdsTabsController();
  callBackFunc: () => void = () => {
    this.controller.changeIndex(1);
  };

  @Monitor('vm.formCardJump.form.id', 'vm.formCardJump.form.url')
  formChange(monitor: IMonitor) {
    if (monitor.value('vm.formCardJump.form.url')?.now) {
      let url = monitor.value('vm.formCardJump.form.url')?.now as string;
      this.widgetInterception(url);
    }
  }

  /*
    * 卡片跳转拦截
    * */
  widgetInterception(url: string) {
    if (url) {
      if (url === RouterMap.HOME) {
        RouterModule.popToName(RouterMap.MAIN_ENTRY)
        this.vm.curIndex = 0;
        this.controller.changeIndex(0);
      } else {
        if (url === RouterMap.MY_COLLECTION && !this.vm.userInfo.isLogin) {
          RouterModule.push(RouterMap.QUICK_LOGIN_PAGE, { 'url': url } as Record<string, string>);
        } else {
          RouterModule.push(url);
        }
      }
      this.vm.formCardJump.form.url = '';
    }
  }

  aboutToAppear(): void {
    emitter.on('jumpPage', this.callBackFunc);
    let url = this.vm.formCardJump.form.url;
    this.widgetInterception(url);
    // 延迟执行顺序在onForeground生命周期后
    let timer = setTimeout(() => {
      CommentUtil.toComment(this.getUIContext().getHostContext() as common.UIAbilityContext);
      clearTimeout(timer);
    }, 0);
  }

  aboutToDisappear(): void {
    emitter.off('jumpPage', this.callBackFunc);
  }

  build() {
    NavDestination() {
      HdsTabs({
        barPosition: BarPosition.End,
        index: this.vm.curIndex,
        controller: this.controller
      }) {
        ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
          TabContent() {
            item.component.builder();
          }
          .tabBar(this.tabBarBuilder(item, index))
          .clip(index !== 0)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }, (item: TabListItem) => item.label);
      }
      .scrollable(false)
      .barHeight(56)
      .barOverlap(true)
      .barFloatingStyle({
        barBottomMargin: 28, // 距离屏幕底部的边距
        adaptToHandedness: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      })
      .onChange((index: number) => {
        this.vm.curIndex = index;
        if (index === 3) {
          emitter.emit('refreshMinePage')
        }
      });
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      if (this.vm.curIndex === 3) {
        emitter.emit('refreshMinePage')
      }
    })
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column({ space: 2 }) {
      SymbolGlyph(item.icon)
        .fontSize(24)
        .fontColor(this.vm.curIndex === index ? ['#FD4238'] : [$r('sys.color.icon_primary')])
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? '#FD4238' : $r('sys.color.font_primary'))
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding(4)
  }
}
