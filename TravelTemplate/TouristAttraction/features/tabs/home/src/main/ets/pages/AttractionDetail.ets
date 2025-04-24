import { VoiceComponent, MediaService } from 'audio';
import { https } from 'network';
import { AttractionInfo } from 'types';
import { mapperAttractionInfo } from '../mapper/Index';
import { Constant, routerToPetalMap } from 'common';
import { common } from '@kit.AbilityKit';
import { TitleBar } from 'components';

@Builder
export function AttractionDetailBuilder() {
  AttractionDetail();
}

@ComponentV2
export struct AttractionDetail {
  @Local attractionId: number = 0;
  @Local isShow: boolean = false;
  @Local attractionInfo: AttractionInfo = new AttractionInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToDisappear(): void {
    MediaService.getInstance().releaseAvPlayer();
  }

  @Builder
  ImagesBuilder() {
    Grid() {
      ForEach(this.attractionInfo.detailImages, (item: ResourceStr) => {
        GridItem() {
          Image(item).size({ height: 76, width: 76 }).borderRadius(8);
        };
      }, (item: ResourceStr) => item.toString());
    }.width(Constant.FULL_PERCENT).padding({ left: 12, right: 12 });
  }

  @Builder
  AttractionHeader() {
    Row() {
      Image(this.attractionInfo.banner).width(96).height(96).borderRadius(8).margin({ right: 8 });

      Column() {
        Text(this.attractionInfo.name).fontWeight(500);
        Text(this.attractionInfo.brief).fontSize(12).opacity(0.6).margin({ top: 4, bottom: 4 });
        Row({ space: 8 }) {
          ForEach(this.attractionInfo.labels, (item: string) => {
            Text(item)
              .fontSize(10)
              .border({ width: 1, radius: 4, color: '#2EB78A' })
              .padding(2)
              .fontColor('#2EB78A');
          }, (item: string) => item);
        };
      }.alignItems(HorizontalAlign.Start);
    }.justifyContent(FlexAlign.Start).width(Constant.FULL_PERCENT).alignItems(VerticalAlign.Top);
  }

  @Builder
  AttractionLocation() {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 2 }) {
          Image($r('app.media.time')).size({ width: 14, height: 14 });
          Text('开放时间：全天开放').fontSize(12).opacity(0.6);
        };

        Row({ space: 2 }) {
          Image($r('app.media.location')).size({ width: 14, height: 14 });
          Text(`景点地址：${this.attractionInfo.location}`).fontSize(12).opacity(0.6);
        };
      }.alignItems(HorizontalAlign.Start);

      Row() {
        Image($r('app.media.navigation')).size({ width: 12, height: 12 });
        Text('导航').fontSize(12).opacity(0.6);
      }.onClick(() => {
        routerToPetalMap(this.attractionInfo.latitude, this.attractionInfo.longitude,
          this.attractionInfo.name, getContext(this) as common.UIAbilityContext);
      });
    }
    .backgroundColor('#F1F3F5F2')
    .borderRadius(8)
    .opacity(0.95)
    .padding(16)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 16, bottom: 16 })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  AttractionIntroduction() {
    Column() {
      Text('景点介绍').fontWeight(500).margin({ bottom: 8 });
      Text(this.attractionInfo.introduction).fontSize(14).lineHeight(20);
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
  }

  @Builder
  AttractionImages() {
    Column({ space: 8 }) {
      Row() {
        Text('图片/视频').fontWeight(500);

        Row() {
          Text('查看全部').fontSize(14).opacity(0.6);
          Image($r('app.media.chevron_right')).size({ height: 12, width: 12 });
        }.onClick(() => {
          this.isShow = true;
        }).bindSheet($$this.isShow, this.ImagesBuilder(), { title: { title: '图片/视频' }, height: '40%' });
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      ForEach(this.attractionInfo.detailImages, (item: ResourceStr) => {
        Image(item).size({ height: 76, width: 76 }).borderRadius(8).margin({ right: 8 });
      }, (item: ResourceStr) => item.toString());
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start).margin({ top: 16, bottom: 16 });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.attractionInfo?.name, clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          this.AttractionHeader();
          this.AttractionLocation();
          this.AttractionIntroduction();
          this.AttractionImages();
          VoiceComponent({ name: this.attractionInfo.name, index: this.attractionInfo.audio });
        }.padding({ left: 12, right: 12 });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.attractionId = context.pathInfo.param as number;
      this.getAttractionById(this.attractionId);
    });
  }

  getAttractionById(attractionId: number) {
    https.getAttractionDetail(attractionId).then((res) => {
      this.attractionInfo = mapperAttractionInfo(res.data);
    });
  }
}