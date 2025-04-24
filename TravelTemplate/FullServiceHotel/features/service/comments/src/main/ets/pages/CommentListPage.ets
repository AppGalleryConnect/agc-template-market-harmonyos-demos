import { CommonHeader } from 'componentlib';
import { RouterModule } from 'commonlib';
import { CommentStar } from '../components/CommentStar';
import { CommentItem, KeywordItem } from '../types';
import { CommentListPageVM } from '../viewModels/CommentListPageVM';

@Builder
export function commentListPageBuilder() {
  CommentListPage();
}

@ComponentV2
export struct CommentListPage {
  vm: CommentListPageVM = CommentListPageVM.instance;

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
      }) {
        CommonHeader({
          title: '客人说',
        });
        Scroll() {
          Column() {
            // 关键词
            Grid() {
              ForEach(this.vm.keyWordList, (item: KeywordItem) => {
                GridItem() {
                  this.keywordCardBuilder(item);
                };
              }, (item: KeywordItem) => JSON.stringify(item));
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(10)
            .backgroundColor(Color.White)
            .padding(10);

            Divider().strokeWidth(5).color($r('app.color.system_color_background_auxiliary'));

            // 评论列表
            List() {
              ForEach(this.vm.commentList, (item: CommentItem) => {
                ListItem() {
                  this.commentItemBuilder(item);
                };
              }, (item: CommentItem) => JSON.stringify(item));
            }
            .padding($r('app.string.padding_s'))
            .layoutWeight(1);
          }
          .justifyContent(FlexAlign.Start);
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .flexGrow(1);

        // 去评论
        Row() {
          Button('去评价')
            .width('100%')
            .height('88lpx')
            .backgroundColor($r('app.color.system_color_focus'))
            .fontColor($r('app.color.icon_color_level1_invert'))
            .onClick(() => {
              RouterModule.push({
                url: 'SubmitComment',
              });
            });
        }
        .width('100%')
        .padding({
          left: $r('app.string.padding_s'),
          right: $r('app.string.padding_s'),
        });
      }
      .height('100%')
      .backgroundColor(Color.White);
    }
    .hideTitleBar(true)
    .onReady(() => {
    })
    .onShown(() => {
      this.vm.getCommentList();
    });
  }

  @Builder
  keywordCardBuilder(item: KeywordItem) {
    Row() {
      Text(`${item.desc}  ${item.count.toFixed(1)}`)
        .fontColor($r('app.color.system_color_focus'))
        .fontSize($r('app.string.font_size_20'));
    }
    .width('100%')
    .borderRadius(4)
    .padding(6)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#E1EFFF');

  }

  @Builder
  commentItemBuilder(item: CommentItem) {
    Column() {
      Flex({
        alignItems: ItemAlign.Center,
      }) {
        Image(item.avatar ? item.avatar : $r('app.media.ic_default_avatar'))
          .width(50)
          .borderRadius(25)
          .margin({ right: 10 })
          .objectFit(ImageFit.Fill);
        Column({ space: 5 }) {
          Row() {
            Text('匿名用户')
              .fontSize($r('app.string.font_size_28'))
              .fontColor($r('app.color.font_color_level1'));
            Text(item.date)
              .fontSize($r('app.string.font_size_20'))
              .fontColor($r('app.color.font_color_level2'));
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%');

          Flex({
            alignItems: ItemAlign.Center,
          }) {
            CommentStar({
              starNum: item.star,
              starSize: 15,
              starSpace: 0,
            })
              .flexGrow(1);
            Image($r('app.media.ic_location2')).width(12).margin({ right: 5 });
            Text(item.location)
              .fontSize($r('app.string.font_size_20'))
              .fontColor($r('app.color.font_color_level2'));
          }
          .width('100%');
        }
        .flexGrow(1);

      };

      Text(item.desc)
        .fontSize($r('app.string.font_size_28'))
        .fontColor($r('app.color.font_color_level1'))
        .lineHeight('42lpx')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({
          top: $r('app.string.margin_m'),
          bottom: $r('app.string.margin_m'),
        });

      Divider()
        .strokeWidth(1)
        .color($r('app.color.system_color_background_auxiliary'));
    }
    .width('100%')
    .padding($r('app.string.padding_s'))
    .backgroundColor($r('app.color.font_color_level1_invert'));
  }
}