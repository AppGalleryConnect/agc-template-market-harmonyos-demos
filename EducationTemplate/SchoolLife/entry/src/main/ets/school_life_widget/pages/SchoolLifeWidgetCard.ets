@Entry
@Component
struct SchoolLifeWidgetCard {
  readonly actionType: string = 'router';

  readonly abilityName: string = 'EntryAbility';

  readonly message: string = 'add detail';
  readonly fullPercent: string = '100%';

  build() {
    Column() {
      Row() {
        this.buttonBuilder($r('app.media.ic_form_home'), '首页', () => {
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: {
              path: 'Home',
            },
          });
        });
        this.buttonBuilder($r('app.media.ic_form_sign_in'), '打卡', () => {
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: {
              path: 'ClassSignInPage',
            },
          });
        });
      }
      .height(this.fullPercent);
    }
    .width(this.fullPercent)
  }

  @Builder buttonBuilder(imgResource: ResourceStr, text: string | Resource, event: () => void) {
    Row() {
      Image(imgResource)
        .size({ width: 24, height: 24 })
        .objectFit(ImageFit.Fill)

      Text(text)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .margin({ left: 7 })
    }
    .justifyContent(FlexAlign.Center)
    .height(this.fullPercent)
    .layoutWeight(1)
    .onClick(() => {
      event();
    })
  }
}