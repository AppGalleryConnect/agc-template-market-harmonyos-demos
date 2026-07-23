import { initMainPageContent } from '@agctemplate/frame';
import { appRouter, deepEqual, NavRouterActionType, navStackActionOptions } from '@agctemplate/utils';
import '@agctemplate/resources';
import '@agctemplate/login';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import { LoneTakeAnimationsTransition } from 'module_transition';

@Entry
@ComponentV2
struct Index {
  @Local isEnabled: boolean = true;
  @Provider('navStack') navPathStack: NavPathStack = new NavPathStack();
  navStackAction: (actionType: NavRouterActionType, options: navStackActionOptions) => boolean =
    (actionType: NavRouterActionType, options: navStackActionOptions) => {
      switch (actionType) {
        case NavRouterActionType.PUSH:
          let allPathName = this.navPathStack.getAllPathName();
          if (allPathName.length > 0 && allPathName[allPathName.length-1] === options.name &&
          deepEqual(this.navPathStack.getParamByIndex(allPathName.length - 1), options.params)) {
            this.navPathStack.replacePathByName(options.name, options.params, options.animated)
          } else {
            this.navPathStack.pushPathByName(options.name, options.params, options.popCallback, options.animated)
          }
          return true;
        case NavRouterActionType.REPLACE:
          this.navPathStack.replacePathByName(options.name, options.params, options.animated)
          return true;
        case NavRouterActionType.POP:
          if (this.navPathStack.size() <= 1) {
            appRouter.back(false);
            return true;
          }
          if (options.name) {
            options.params ? this.navPathStack.popToName(options.name, options.params, options.animated) :
              this.navPathStack.popToName(options.name, options.animated)
          } else {
            options.params ? this.navPathStack.pop(options.params, options.animated) :
              this.navPathStack.pop(options.animated)
          }
          return true;
        default:
          return false;
      }
    }

  aboutToAppear() {
    appRouter.setNavStackAction(this.navStackAction);
    appRouter.setNavPathStack(this.navPathStack);
    initMainPageContent();
    appRouter.push({
      builderName: NAV_PAGE_NAME.LaunchPage.name
    })
  }

  build() {
    Navigation(this.navPathStack) {
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .enabled(this.isEnabled)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.isEnabled = true;
        },
      });
    })
  }
}