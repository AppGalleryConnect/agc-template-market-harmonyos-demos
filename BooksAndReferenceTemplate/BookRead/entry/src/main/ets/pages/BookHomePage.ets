import { BookListPage } from 'book_home';
import { PersonPage } from 'book_person';
import { Constants } from 'common';

@Builder
function bookList() {
  BookListPage();
}

@Builder
function person() {
  PersonPage();
}

const bookListBuilder: WrappedBuilder<[string]> = wrapBuilder(bookList);
const personBuilder: WrappedBuilder<[string]> = wrapBuilder(person);


@ComponentV2
export struct BookHomePage {
  @Local currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndex === index ? $r('app.color.font_overdue') : '#E6000000')
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  @Builder
  tabContentBuilder(text: Resource,
    index: number,
    selectedImg: Resource,
    normalImg: Resource,
    builder: WrappedBuilder<[string]>) {
    TabContent() {
      Stack() {
        builder.builder('');
      }
    }
    .backgroundColor(Color.White)
    .tabBar(this.tabBuilder(text, index, selectedImg, normalImg))
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        this.tabContentBuilder($r('app.string.book_home'),
          Constants.TAB_INDEX_ZERO, $r('app.media.home_tab_active'), $r('app.media.home_tab'), bookListBuilder)
        this.tabContentBuilder($r('app.string.person'),
          Constants.TAB_INDEX_ONE, $r('app.media.person_tab_active'), $r('app.media.person_tab'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .backgroundColor('#F3F4F5')
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .padding({ bottom: 18 })
      .onAnimationStart((index: number, targetIndex: number) => {
        this.currentIndex = targetIndex;
      })
    }
    .hideTitleBar(true)
  }
}