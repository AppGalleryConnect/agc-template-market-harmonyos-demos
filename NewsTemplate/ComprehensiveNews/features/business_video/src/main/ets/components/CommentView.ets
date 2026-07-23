import { NewsResponse } from 'lib_news_api';

@ComponentV2
export struct CommentView {
  // 当前视频信息
  @Param @Require videoInfo: NewsResponse;
  // 是否拉起显示键盘
  @Param isShowKeyboard: boolean = false;

  @Provider() navPathStack: NavPathStack = new NavPathStack();
  @Provider() showKeyboard: boolean = this.isShowKeyboard;
  @Provider() isCommentInModalDialog: boolean = true;

  aboutToAppear(): void {
    this.navPathStack.pushPathByName('CommentViewPage', this.videoInfo)
  }

  build() {
    Navigation(this.navPathStack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
  }
}