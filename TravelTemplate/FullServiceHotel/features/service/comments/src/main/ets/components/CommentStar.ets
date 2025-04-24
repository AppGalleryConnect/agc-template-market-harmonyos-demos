import { util } from '@kit.ArkTS';

@ComponentV2
export struct CommentStar {
  @Param starNum: number = 0;
  @Param starSize: number = 30;
  @Param starSpace: number = 16;
  @Param isUncheckedShow: boolean = false;
  @Local starList: boolean[] = [false, false, false, false, false];
  @Event handleStarClick?: (value: number) => void = () => {
  };

  @Monitor('starNum')
  refreshStarList() {
    for (let i = 0; i < 5; i++) {
      this.starList[i] = Boolean(i < this.starNum);
    }
  }

  aboutToAppear(): void {
    this.refreshStarList();
  }

  build() {
    Row() {
      ForEach(this.starList, (item: boolean, index: number) => {
        Column() {
          if (item) {
            Image($r('app.media.ic_star_filled')).width(this.starSize);
          } else if (this.isUncheckedShow) {
            Image($r('app.media.star_grey')).width(this.starSize);
          }
        }.margin({ right: index === 4 ? 0 : this.starSpace })
        .onClick(() => {
          this.handleStarClick?.(index);
        });
      }, (item: boolean, index: number) => {
        return index + '__' + JSON.stringify(item);
      });
    };
  }
}