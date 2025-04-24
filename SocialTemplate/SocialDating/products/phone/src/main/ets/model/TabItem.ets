import { HomePageBuilder } from 'composite/src/main/ets/pages/Home';
import { PersonalPageBuilder } from 'composite/src/main/ets/pages/Personal';
import { FeedListPageBuilder } from 'feed';
import { MemberPageBuilder } from 'member';

export interface  TabItem {
  index: number;
  img: Resource ;
  selectedImage: Resource ;
  title: string;
  selectedTitleColor: Resource | Color;
  component: WrappedBuilder<[]>;
}

const tabItems: TabItem[] = [
  {
    index: 0,
    img: $r('app.media.home_0'),
    selectedImage: $r('app.media.home_1'),
    title: '首页',
    selectedTitleColor: $r('app.color.button_background_color'),
    component: wrapBuilder(HomePageBuilder)
  },
  {
    index: 1,
    img: $r('app.media.feed_0'),
    selectedImage: $r('app.media.feed_1'),
    title: '广场',
    selectedTitleColor: $r('app.color.button_background_color'),
    component: wrapBuilder(FeedListPageBuilder)
  },
  {
    index: 2,
    img: $r('app.media.member_0'),
    selectedImage: $r('app.media.member_1'),
    title: '会员',
    selectedTitleColor: $r('app.color.button_background_color'),
    component: wrapBuilder(MemberPageBuilder)

  },
  {
    index: 3,
    img: $r('app.media.personal_0'),
    selectedImage: $r('app.media.personal_1'),
    title: '我的',
    selectedTitleColor: $r('app.color.button_background_color'),
    component: wrapBuilder(PersonalPageBuilder)
  }
]

export { tabItems }