import { Constant } from 'common';
import { TitleBar } from 'components';
import { https } from 'network';
import { mapperBulletinInfo } from '../mapper/Index';
import { BulletinInfo } from '../model/BulletinInfo';

@Builder
export function BulletinDetailBuilder() {
  BulletinDetail();
}

@ComponentV2
export struct BulletinDetail {
  @Local bulletinId: number = 0;
  @Local bulletinInfo: BulletinInfo = new BulletinInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  getBulletinById() {
    https.getBulletinDetail(this.bulletinId).then((res) => {
      this.bulletinInfo = mapperBulletinInfo(res.data);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '公告详情', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll() {
          Column() {
            Image(this.bulletinInfo.banner).width(Constant.FULL_PERCENT).height(200).objectFit(ImageFit.Fill);

            Column() {
              Text(this.bulletinInfo.title)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontWeight(700)
                .lineHeight(28)
                .fontSize(20);

              Text(this.bulletinInfo.releaseTime).fontSize(12).opacity(0.6).margin({ top: 16, bottom: 16 });

              Text(this.bulletinInfo.detail).fontSize(14).lineHeight(20);
            }.padding(16).alignItems(HorizontalAlign.Start);
          };
        }.height('90%').align(Alignment.Top);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.bulletinId = context.pathInfo.param as number;
      this.getBulletinById();
    });
  }
}