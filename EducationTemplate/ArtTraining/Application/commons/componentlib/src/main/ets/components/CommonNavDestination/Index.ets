@ComponentV2
export struct CommonNavDestination {
  @Param title: string = '';


  build() {
    NavDestination() {

    }
    .hideTitleBar(true)

  }
}