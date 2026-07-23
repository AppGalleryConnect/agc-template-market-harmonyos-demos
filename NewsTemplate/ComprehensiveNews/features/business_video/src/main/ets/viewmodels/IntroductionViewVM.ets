import { BaseViewModel, CommonDataSource } from 'lib_common';
import { BaseNewsServiceApi, RequestListData } from 'lib_news_api';

export class LayoutNewsDataSource extends CommonDataSource<RequestListData> {
}

@ObservedV2
export class IntroductionViewVM extends BaseViewModel {
  @Trace introductionDataSource = new LayoutNewsDataSource();
  scroller: Scroller = new Scroller()

  timer: number | undefined = undefined

  init() {
    this.queryIntroductionList();
    // 轮询生成直播图文介绍
    this.loopAddMockData()
  }

  async queryIntroductionList() {
    const list = await BaseNewsServiceApi.queryAuthorPosts('author_5');
    list.forEach((item) => {
      item.extraInfo.showUserBar = false;
      item.extraInfo.showTimeBottom = false;
      item.extraInfo.showTitleTextAll = false;
      item.extraInfo.showImagePreviewLayer = false;
      item.extraInfo.disabledClickEvent = true;
      item.extraInfo.authorId = 'author_5';
      item.articles[0].postImgList = item.articles[0].postImgList?.slice(0, 1)
    })
    this.introductionDataSource.setData(list);
  }
  loopAddMockData() {
    let count = 0;
    let textList = [
      '冰川如同一面巨大的镜子，反射着天空的蓝，点缀着几朵白云，美得令人窒息。',
      '路再远，也要一步步走；梦再大，也要一点点追。',
      '别急着否定自己，每一步积累，都是在为未来铺路；哪怕慢，也是在前进。',
      '人生就像一场马拉松，不是比谁跑得快，而是比谁能坚持到最后。别被眼前的困难吓倒，每一次跌倒都是积蓄力量的过程。' +
        '慢下来，整理呼吸，调整步伐，你会发现风景依然在前方等你。坚持，是给自己最好的礼物。',
    ]
    this.timer = setInterval(async () => {
      const list = await BaseNewsServiceApi.queryAuthorPosts('author_5');
      let item = list[0];
      if (item) {
        item.extraInfo.showUserBar = false;
        item.extraInfo.showTimeBottom = false;
        item.extraInfo.showTitleTextAll = false;
        item.extraInfo.showImagePreviewLayer = false;
        item.extraInfo.disabledClickEvent = true;
        item.extraInfo.authorId = this.userInfoModel.authorId;
        item.articles[0].id = textList[count % 4] + count;
        item.articles[0].title = textList[count % 4];
        item.articles[0].postImgList = []
      }
      this.introductionDataSource.pushData(item)
      count++;
      this.scroller.scrollToIndex(this.introductionDataSource.totalCount() - 1, true, ScrollAlign.END)
    }, 2 * 60 * 1000)
  }

  disappear() {
    this.timer && clearInterval(this.timer)
  }
}