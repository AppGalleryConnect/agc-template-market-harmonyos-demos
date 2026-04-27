/**
 * @usage: 收到的赞页面，展示用户帖子收到的点赞记录列表，支持查看被点赞的帖子详情
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，下方是点赞记录列表或空状态提示
 * @constraints: likesList为点赞记录数据源；点击记录可跳转到对应帖子详情
 * @isGen: true
 * @fileType: page
 * @zhName: 收到的赞
 * @domain: 旅游
 * @image: screenshots/person/MyLikes.jpg
 * @subPage: PostDetailPage
 * @component: CommonHeader,CommonEmpty
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { PostDetailPageBuilder } from 'homepage';
import { CommonEmpty, CommonHeader, RouterMap } from 'common';
import { LikesItem, MyLikeList, MyPostList } from 'common_travel_guide';
import { OHPage, phoneRouterControl } from 'oh_router'

@Builder
export function MyLikesPageBuilder() {
  MyLikesPage();
}

@ComponentV2
export struct MyLikesPage {
  @Local likesList: MyLikeList = AppStorageV2.connect(MyLikeList, () => new MyLikeList())!
  @Local postList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!

  @Builder
  likeItem(item: LikesItem) {
    Row() {
      Row({ space: 6 }) {
        Image(item.avatar ? item.avatar : $r('app.media.path2x'))
          .width(30)
          .height(30)
          .borderRadius(30)
        Column() {
          Text(item.userName)
            .fontColor('rgba(0, 0, 0, 0.50)')
            .fontSize(12)
            .margin({ bottom: 4 })
          Text(item.time)
            .fontColor('rgba(0, 0, 0, 0.50)')
            .fontSize(12)
            .margin({ bottom: 10 })
          Text('赞了你的帖子')
            .fontColor('#000')
            .fontSize(14)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)

      Image(item.postCover)
        .width(54)
        .height(72)
        .borderRadius(10)
    }
    .width('100%')
    .backgroundColor('#fff')
    .padding({
      top: 10,
      bottom: 10,
      left: 16,
      right: 16
    })
    .borderRadius(12)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      let postInfo = this.postList.getDataById(item.postId)
      if (postInfo) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.POST_DETAIL_PAGE,
          builder: wrapBuilder(PostDetailPageBuilder),
          param: postInfo
        })
      }
    })
  }

  @Builder
  likeList() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.likesList.list, (item: LikesItem) => {
          this.likeItem(item)
        },(item: LikesItem) => JSON.stringify(item))
      }
    }
    .layoutWeight(1)
    .margin({ top: 10 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart)
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '收到的赞',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
      if (this.likesList.list.length) {
        this.likeList()
      } else {
        CommonEmpty()
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
    })
  }
}

