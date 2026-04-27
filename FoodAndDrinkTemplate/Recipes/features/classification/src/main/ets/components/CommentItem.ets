import { AccountUtil, UserInfo } from 'commonlib';
import { CommentModel, Score } from '../model/CommentModel';

@ComponentV2
export struct CommentItem {
  @Local arr: Score[] = [
    new Score('0', true),
    new Score('1', false),
    new Score('2', false),
    new Score('3', false),
    new Score('4', false),
  ];
  @Param @Require comment: CommentModel;

  aboutToAppear(): void {
    this.arr.forEach((item: Score, idx: number) => {
      if (this.comment.score > idx) {
        item.select = true;
      } else {
        item.select = false;
      }
    });
  }


  build() {
    Row() {
      if(AccountUtil.getUserInfo().isLogin) {
        Image(AccountUtil.getUserInfo().avatar === 'default_avatar' ?
          $r(`app.media.${AccountUtil.getUserInfo().avatar}`) : AccountUtil.getUserInfo().avatar)
          .imageStyles()
      } else {
        if(typeof this.comment.icon === 'string' && 
        this.comment.icon.startsWith('file://')) {
          Image(this.comment.icon)
            .imageStyles()
        } else {
          Image(this.comment.icon !== '' ?
            $r(`app.media.${this.comment.icon}`) : $r('app.media.icon_default_avatar'))
            .imageStyles()
        }
      }

      Column() {
        Text(this.comment.authorId === AccountUtil.getUserInfo().id ?
          AccountUtil.getUserInfo().nickname : this.comment.nickName)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);
        Row() {
          ForEach(this.arr, (item: Score) => {
            Image(item.select ? $r('app.media.ic_star') : $r('app.media.ic_star_fill'))
              .width(9)
              .height(9)
              .margin({ right: 2 });
          }, (item: number, index: number) => item + index + '');
          Text(this.comment.score + '')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Regular)
            .margin({ left: 2 });
        }
        .margin({ top: 2, bottom: 8 });

        Text(this.comment.comment)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .lineHeight(19)
          .width('100%');
        Text(this.getCoverDateString(this.comment.time))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: 13, bottom: 13 });
        Text()
          .width('100%')
          .height(0.5)
          .backgroundColor($r('sys.color.comp_divider'));
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ bottom: 10 })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start);
  }

  private getCoverDateString(timestamp: number): string {
    let date = new Date(timestamp);
    const hour = ('0' + date.getHours()).slice(-2);
    const min = ('0' + date.getMinutes()).slice(-2);
    const sec = ('0' + date.getSeconds()).slice(-2);
    const year = date.getFullYear();
    const month = ('0' + (date.getMonth() + 1)).slice(-2);
    const day = ('0' + date.getDate()).slice(-2);
    return `${year}-${month}-${day}  ${hour}:${min}:${sec}`;
  }
}

@Extend(Image)
function imageStyles() {
  .width(46)
  .height(46)
  .margin({ right: 8 })
  .borderRadius(23);
}
