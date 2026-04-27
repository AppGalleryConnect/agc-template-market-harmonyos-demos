import { ContactSearchModel } from '../viewmodel/ContactSearchModel';

@ComponentV2
export struct SearchFriendItem {
  @Param @Require friendItem: ContactSearchModel;
  @Param @Require searchText: string;
  @Local keyNum: number[] = [];
  @Local nickNameLower: string = '';
  @Local searchTextLower: string = '';

  aboutToAppear() {
    this.keyNum = [];
    this.nickNameLower = this.friendItem.searchNickName.toLowerCase();
    this.searchTextLower = this.searchText.toLowerCase();
    let num = this.nickNameLower.split(this.searchTextLower).length - 1;
    let preLength = 0;
    for (let i = 0; i < num; i++) {
      let curIndex = this.nickNameLower.indexOf(this.searchTextLower, preLength);
      this.keyNum.push(curIndex);
      preLength = curIndex + this.searchTextLower.length;
    }
  }

  build() {
    Row() {
      Image(this.friendItem.searchAvatarUrl.startsWith('http') ? this.friendItem.searchAvatarUrl :
      $r('app.media.' + this.friendItem.searchAvatarUrl))
        .width($r('app.float.vp_48'))
        .height($r('app.float.vp_48'))
        .borderRadius($r('app.float.vp_12'))
        .objectFit(ImageFit.Cover)
      Text() {
        ForEach(this.keyNum, (start: number, index: number) => {
          Span(this.friendItem.searchNickName.substring(index !== 0 ?
            (this.keyNum[index - 1] + this.searchText.length) : 0,
            start));
          Span(this.friendItem.searchNickName.substring(start, (start + this.searchText.length)))
            .fontColor($r('app.color.color_564af7'));
          if (index === (this.keyNum.length - 1)) {
            Span(this.friendItem.searchNickName.substring((start + this.searchText.length),
              this.friendItem.searchNickName.length));
          }
        }, (item: number) => item.toString())
      }
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .margin({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height($r('app.float.vp_72'))
  }
}