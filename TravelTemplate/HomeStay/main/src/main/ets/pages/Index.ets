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
    .backgroundColor('#f1f3f5')
    .hideBackButton(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack);
  }
}