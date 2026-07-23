import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { TextReader } from '@kit.SpeechKit';
import { VoiceComponent } from 'attraction_announcement';
import { BreakpointModel, Constant, GridRowColSetting, Logger, SystemUtil } from 'common';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { AttractionInfo, CustomShareParams, PlayInfo } from 'module_base';
import { https } from 'network';
import { TitleBar } from 'uicomponents';
import { mapperAttractionInfo } from '../mapper/Index';

@Builder
export function AttractionDetailBuilder() {
  AttractionDetail();
}

@ComponentV2
export struct AttractionDetail {
  @Local attractionId: number = 0;
  @Local isShow: boolean = false;
  @Local attractionInfo: AttractionInfo = new AttractionInfo();
  @Local instance: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  @Local index: number = -1;
  @Local resources: SourceImageModel[] = [];
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  options: ImagePreviewOptions = new ImagePreviewOptions();

  aboutToDisappear(): void {
    TextReader.stop().then(() => {
      TextReader.release();
    });
  }

  @Builder
  AttractionHeader() {
    Row() {
      Image(this.attractionInfo.banner).width(80).height(80).borderRadius(8);

      Column() {
        Text(this.attractionInfo.name)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'));
        Text(this.attractionInfo.brief)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 });
        Row({ space: 8 }) {
          ForEach(this.attractionInfo.labels, (item: string) => {
            Text(item)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .border({ width: 1, radius: 4, color: $r('sys.color.comp_divider') })
              .height(16)
              .padding({
                top: 1,
                bottom: 1,
                left: 4,
                right: 4,
              })
              .fontColor($r('sys.color.font_secondary'));
          }, (item: string) => item);
        }.margin({ top: 4 });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 16, right: 8 });

      VoiceComponent({
        playInfo: {
          playId: this.attractionInfo.attractionId.toString(),
          introduction: this.attractionInfo.introduction,
          title: this.attractionInfo.name,
          imageUrl: this.attractionInfo.banner,
          panelName: '松山湖景区',
          panelIcon: $r('app.media.app_icon'),
        } as PlayInfo,
      });
    }.justifyContent(FlexAlign.Start).width(Constant.FULL_PERCENT).alignItems(VerticalAlign.Top);
  }

  @Builder
  AttractionLocation() {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.time_inerval'))
            .width(16)
            .height(16)
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')]);
          Text('开放时间：全天开放').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
        };

        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.local'))
            .width(16)
            .height(16)
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')]);
          Text(`景点地址：${this.attractionInfo.location}`)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'));
        };
      }.alignItems(HorizontalAlign.Start);

      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.location_north_up_right'))
          .width(16)
          .height(16)
          .fontSize(16)
          .fontColor([$r('sys.color.icon_primary')]);
        Text('导航').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
      }.onClick(() => {
        SystemUtil.routerToPetalMap(this.attractionInfo.latitude, this.attractionInfo.longitude,
          this.attractionInfo.name, this.getUIContext().getHostContext() as common.UIAbilityContext);
      });
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(16)
    .padding(12)
    .margin({ top: 16 })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  AttractionIntroduction() {
    Column({ space: 8 }) {
      Text('景点介绍')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'));
      Text(this.attractionInfo.introduction).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start).margin({ top: 24 });
  }

  @Builder
  AttractionImages() {
    Column({ space: 8 }) {
      Row() {
        Text('图片/视频')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));

        Row() {
          Text('查看全部').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
          Image($r('app.media.chevron_right')).size({ height: 12, width: 12 });
        }.onClick(() => {
          this.mainPathStack.pushPathByName('AttractionImage', this.attractionInfo.detailImages);
        });
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      List({ space: GridRowColSetting.getGutter(this.breakPointModel.currentBreakpoint) }) {
        ForEach(this.attractionInfo.detailImages, (item: ResourceStr, index: number) => {
          ListItem() {
            Image(item).size({ height: 104, width: 104 }).borderRadius(8);
          } /**
           * 设置id，显示一镜到底效果
           * id作用是为了获取组件快照，建议保证id的唯一性
           * 这里是方便演示，选择是item+index组合
           * 如果当前组件被当成子组件渲染，就会产生两个相同id的组件快照，会导致一镜到底效果错乱
           * */
          .id(this.options.snapshotId(item, index)) /**
           * 设置隐藏是为了增强一镜到底效果
           * */
          .visibility(index === this.index ? Visibility.Hidden : Visibility.Visible).onClick(() => {
            this.options
              .setImageList(this.resources)
              .setInitIndex(index);
            ImagePreview.open(this.getUIContext(), this.options);
          });
        }, (item: ResourceStr) => item.toString());
      }.listDirection(Axis.Horizontal).scrollBar(BarState.Off).height(104).edgeEffect(EdgeEffect.Spring);
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start).margin({ top: 24, bottom: 16 });
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
        }
        .margin({ top: 8, left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
        .constraintSize({ maxWidth: Constant.FULL_PERCENT });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.attractionId = context.pathInfo.param as number;
      this.getAttractionById(this.attractionId);
    });
  }

  getAttractionById(attractionId: number) {
    https.getAttractionDetail(attractionId).then((res) => {
      this.attractionInfo = mapperAttractionInfo(res.data); // 华为分享
      this.instance.pageName = 'TicketDetail';
      this.instance.goodId = this.attractionInfo.attractionId;
      this.instance.goodName = this.attractionInfo.name;
      this.resources = this.attractionInfo.detailImages.map((imageUrl) => {
        return new SourceImageModel({ imageUrl });
      });
      this.options
        .setImageActionListener({
          onPageChanged: (item: SourceImageModel, index: number) => {
            this.index = index;
          }, onLongPress: (index: number) => {
            Logger.info(`长按了第${index + 1}个资源`);
          },
        })
        .setPreviewListener({
          onBack: () => {
            this.index = -1;
          },
        });
    });
  }
}