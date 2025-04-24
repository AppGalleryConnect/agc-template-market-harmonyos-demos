import { User } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, StringUtil } from '@ohos_agcit/children_education_utils';
import { VipPackage } from './VipPackage';

@ComponentV2
export struct UserInfo {
  @Consumer(CommonConstants.IS_VIP) isVip: boolean = false;
  @Consumer(CommonConstants.VALID_TIME) validTime: string = '';
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

  build() {
    Row() {
      RelativeContainer() {
        Image($r('app.media.top'))
          .width(CommonConstants.FULL_PERCENT)
          .id(CommonConstants.IMAGE);

        Text($r('app.string.vip'))
          .fontSize(24)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
          .alignRules({
            'top': { anchor: CommonConstants.IMAGE, align: VerticalAlign.Top },
            'left': { anchor: CommonConstants.IMAGE, align: HorizontalAlign.Start },
          })
          .padding({
            top: 12,
            left: 16,
          });

        Row({ space: 16 }) {
          Image($r('app.media.avatar'))
            .height(60)

          Column({ space: 2 }) {
            Row({ space: 4 }) {
              Text($r('app.string.huawei_user'))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontFamily('鸿蒙黑体')

              Stack({ alignContent: Alignment.Center }) {
                Row()
                  .width(60)
                  .height(15)
                  .backgroundColor(this.isVip ? '#F8E6CE' : Color.Black)
                  .borderRadius(4)
                  .opacity(this.isVip ? 1 : 0.05);
                Row() {
                  Image($r('app.media.non_members'))
                    .height(15)
                    .id('non_members')
                    .fillColor(this.isVip ? '#000000' : Color.Gray);

                  Text(this.isVip ? $r('app.string.is_vip') : $r('app.string.not_vip'))
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontFamily('鸿蒙黑体')
                    .padding({
                      left: 2,
                    });
                };
              }
            }

            Row() {
              Text(StringUtil.isEmpty(this.validTime) ? '您当前还不是会员' : this.validTime + '到期')
                .fontSize(12)
                .fontWeight(400)
                .fontFamily('鸿蒙黑体')
            }
          }.alignItems(HorizontalAlign.Start)
        }.alignRules({
          'top': { anchor: CommonConstants.IMAGE, align: VerticalAlign.Top },
          'left': { anchor: CommonConstants.IMAGE, align: HorizontalAlign.Start },
        })
        .padding({
          left: 16,
          top: 70,
        })

        // 会员套餐
        VipPackage({
          isVip: this.isVip,
          validTime: this.validTime,
          changeVipState: () => {
            this.isVip = true;
          },
        }).alignRules({
          'top': { anchor: CommonConstants.IMAGE, align: VerticalAlign.Top },
        }).padding({ top: 134 });
      }
      .width('auto')
      .height('auto');
    };
  }
}