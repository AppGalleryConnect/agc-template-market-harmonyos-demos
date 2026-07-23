@Entry
@ComponentV2
struct EmptyPage {
  @Provider('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.mainPathStack.pushPathByName('SafePage', null)
  }

  build() {
    Navigation(this.mainPathStack) {
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideBackButton(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack);
  }
}