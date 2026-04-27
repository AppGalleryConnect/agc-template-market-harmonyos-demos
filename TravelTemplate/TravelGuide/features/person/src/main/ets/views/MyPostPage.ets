/**
 * @usage: 我发布的帖子页面，展示用户发布的帖子列表，支持点赞和查看帖子详情
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，下方是帖子瀑布流列表或空状态提示
 * @constraints: postList为帖子数据源；点击帖子可跳转到帖子详情页
 * @isGen: true
 * @fileType: page
 * @zhName: 我的帖子
 * @domain: 旅游
 * @image: screenshots/person/MyPost.jpg
 * @subPage: PostDetailPage
 * @component: CommonHeader,CommonEmpty
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { PostDetailPageBuilder } from 'homepage';
import { CommonEmpty, CommonHeader, RouterMap } from 'common';
import { LikesItem, MyLikeList, MyPostList, PostInfo } from 'common_travel_guide';
import { OHPage, phoneRouterControl } from 'oh_router'

@Builder
export function MyPostPageBuilder() {
  MyPostPage();
}

@ComponentV2
export struct MyPostPage {
  @Local postList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!
  @Local likesList: MyLikeList = AppStorageV2.connect(MyLikeList, () => new MyLikeList())!

  @Builder
  postItemBuilder(item: PostInfo) {
    Column() {
      Image(item.coverImg)
        .width('100%')
        .borderRadius({ topLeft: 12, topRight: 12 })
      Column({ space: 12 }) {
        Text(item.title)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row() {
          Row({ space: 4 }) {
            Image(item.userInfo.avatarUrl ? item.userInfo.avatarUrl :
            $r('app.media.path2x'))
              .width(18)
              .height(18)
              .borderRadius(18)
            Text(item.userInfo.nickName)
              .fontColor('rgba(0, 0, 0, 0.70)')
              .fontSize(11)
          }

          Row({ space: 2 }) {
            Image(item.liked ? $r('app.media.ic_liked') : $r('app.media.ic_unliked'))
              .width(18)
              .height(18)
            Text(item.likes.toString())
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.50)')
          }
          .onClick(() => {
            item.handleLike()
            if (item.liked) {
              const data = new LikesItem(
                item.userInfo.nickName || '',
                item.userInfo.avatarUrl || '',
                item.publishTime || '',
                item.id || '',
                item.coverImg || ''
              );
              this.likesList.add(data);
            } else {
              this.likesList.deleteById(item.id);
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(10)
    }
    .width('100%')
    .backgroundColor('#fff')
    .borderRadius(12)
    .onClick(()=>{
      phoneRouterControl.jumpPage({
        pageName: RouterMap.POST_DETAIL_PAGE,
        builder: wrapBuilder(PostDetailPageBuilder),
        param: item
      })
    })
  }

  @Builder
  postListBuilder() {
    WaterFlow() {
      ForEach(this.postList.list, (item: PostInfo) => {
        this.postItemBuilder(item)
      },(item: PostInfo) => JSON.stringify(item))
    }
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(10)
    .columnsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .width('100%')
    .layoutWeight(1)
    .margin({ top: 12 })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '我发布的帖子',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
      if (this.postList.list.length) {
        this.postListBuilder()
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

