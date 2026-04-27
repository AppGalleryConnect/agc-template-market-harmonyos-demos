import { TabListItem } from '../types/Types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { emitter } from '@kit.BasicServicesKit';
import { CommentUtil, RouterMap, RouterModule } from 'commonlib';
import { common } from '@kit.AbilityKit';
import { FloatingNavBar, NavItemModel } from 'floating_navbar';

@Builder
export function MainEntryBuilder() {
  MainEntry()
}

@ComponentV2
struct MainEntry {
  @Local vm: MainEntryVM = MainEntryVM.instance;
  @Local tabOpacity: number = 1
  private controller: TabsController = new TabsController();

  callBackFunc: () => void = () => {
    this.controller.changeIndex(1);
  };

  switchTab(index: number) {
    if (this.vm.curIndex === index) {
      return
    }
    // 先淡出
    this.getUIContext().animateTo({
      duration: 80,
      curve: Curve.EaseIn,
      onFinish: () => {
        this.vm.curIndex = index;
        this.controller.changeIndex(index);
        // 再淡入
        this.getUIContext().animateTo({
          duration: 200,
          curve: Curve.EaseOut,
        }, () => {
          this.tabOpacity = 1
        })
      }
    }, () => {
      this.tabOpacity = 0
    })
  }

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
      if (this.vm.isLandscape) {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          this.FloatingNavBarBuilder();
          this.TabsBuilder();
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else {
        Stack({ alignContent: Alignment.Bottom }) {
          this.TabsBuilder();
          this.FloatingNavBarBuilder();
        }
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      if (this.vm.curIndex === 3) {
        emitter.emit('refreshMinePage')
      }
    })
  }

  @Builder
  TabsBuilder() {
    Tabs({
      barPosition: this.vm.isLandscape ? BarPosition.Start : BarPosition.End,
      index: this.vm.curIndex,
      controller: this.controller
    }) {
      ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
        TabContent() {
          item.component.builder();
        }
        .clip(index !== 0)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }, (item: TabListItem) => item.label);
    }
    .scrollable(false)
    .layoutWeight(1) // 横屏时生效
    .width('100%') // 竖屏时生效
    .height('100%')
    .barHeight(0)
    .animationDuration(0)
    .opacity(this.tabOpacity)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onChange((index: number) => {
      this.vm.curIndex = index;
      if (index === 3) {
        emitter.emit('refreshMinePage')
      }
    });
  }

  @Builder
  FloatingNavBarBuilder() {
    FloatingNavBar({
      items: this.vm.navItems,
      selectedIndex: this.vm.curIndex,
      isLandscape: this.vm.isLandscape,
      screenSize: this.vm.breakPoint,
      itemBuilder: (item: NavItemModel, index: number) => {
        this.navItemBuilder(item, index)
      }
    })
      .padding({
        bottom: this.vm.isLandscape ? 0 : 28,
        left: this.vm.isLandscape ? 0 : 16,
        right: this.vm.isLandscape ? 0 : 16
      })
  }

  @Builder
  navItemBuilder(item: NavItemModel, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.selectedIcon : item.icon)
        .width(24)
        .height(24)
        .margin({ top: 4 });
      Text(item.title)
        .fontColor(this.vm.curIndex === index ? Color.Red :
          $r('sys.color.font_secondary'))
        .fontSize(10)
        .margin({ top: 4 });
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.switchTab(index)
    })
  }
}