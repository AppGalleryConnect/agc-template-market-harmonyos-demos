import { BeautyActionBar } from '../components/BeautyActionBar';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { StickerModel } from '../model/BeautificationParam';
import { StickerComponent } from '../components/StickerComponent';
import { AddTextComponent } from '../components/AddTextComponent';
import { getInstance } from '../util/RouteModule';
import { BeautyParam } from '../model/PageParams';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@Builder
export function PictureBeautificationBuilder() {
  PictureBeautification();
}

@ComponentV2
export struct PictureBeautification {
  @Local isEdit: boolean = true;
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  aboutToDisappear(): void {
    this.vm.pixelMapList = [];
  }

  getNavParam(ctx: NavDestinationContext) {
    // 清除滤镜名
    this.vm.filterName = '';
    let param = ctx?.pathInfo?.param as BeautyParam;
    this.vm.barIndex = param.barIndex;
    if (param.uris.length) {
      const uri = param.uris[0];
      if (param?.filterName) {
        this.vm.filterName = param.filterName;
      }
      this.vm.initData(uri);
    } else {
      if (param.pixelMap) {
        this.vm.pushPixelMap(param.pixelMap);
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.beautifyContentBuilder();
        BeautyActionBar()
          .margin({ top: 16, left: this.vm.barIndex === -1 ? 16 : 0, right: this.vm.barIndex === -1 ? 16 : 0 });
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .layoutWeight(1);
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onReady((ctx: NavDestinationContext) => {
      this.getNavParam(ctx);
    });
  }

  @Builder
  beautifyContentBuilder() {
    Column() {
      Row() {
        Image($r('app.media.chevron_left')).size({ width: 40, height: 40 }).onClick(() => {
          getInstance().pop();
        });

        Row({ space: 10 }) {
          Row({ space: 10 }) {
            Image(this.vm.totalPixelMapCount > 1 && this.vm.currentPixelMapIndex !== 0 ?
              $r('app.media.ic_recall_enable') :
              $r('app.media.ic_recall_disable'))
              .height(40)
              .width(40)
              .onClick(() => {
                if (this.vm.currentPixelMapIndex !== 0) {
                  this.vm.currentPixelMapIndex--;
                  this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
                }
              });
            Image(this.vm.totalPixelMapCount - 1 !== this.vm.currentPixelMapIndex ? $r('app.media.ic_forward_enable') :
              $r('app.media.ic_forward_disable'))
              .height(40)
              .width(40)
              .onClick(() => {
                if (this.vm.currentPixelMapIndex !== this.vm.totalPixelMapCount - 1) {
                  this.vm.currentPixelMapIndex++;
                  this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
                }
              });
          };

          SaveButton({ text: SaveDescription.SAVE }).onClick(() => {
            ImageProcessingUtil.saveToAlbum('ImageContent', this.getUIContext());
          });
        };
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })
      .visibility(this.vm.barIndex === -1 ? Visibility.Visible : Visibility.None);

      Stack() {
        Stack() {
          Image(this.vm.currentPixelMap).width('100%');

          ForEach(this.vm.stickerList, (item: StickerModel) => {
            StickerComponent({ item: item, onDelete: this.vm.deleteSticker });
          }, (item: StickerModel) => item.id);

          if (this.vm.barIndex === 1 || this.vm.saveText) {
            AddTextComponent();
          }
        }.id('ImageContent')
        .onAreaChange((_value: Area, newVal: Area) => {
          // 获取图片位置xy
          this.vm.imageArea.x = Math.round(newVal.position.x as number);
          this.vm.imageArea.y = Math.round(newVal.position.y as number);
          this.vm.clipRect.x = this.vm.imageArea.x;
          this.vm.clipRect.y = this.vm.imageArea.y;
          this.vm.clipRect.width = newVal.width as number;
          this.vm.clipRect.height = newVal.height as number;
          this.vm.imageArea.width = newVal.width as number;
          this.vm.imageArea.height = newVal.height as number;
        });

        // 蒙层
        Canvas(this.vm.maskContext)
          .position({
            x: this.vm.imageArea.x,
            y: this.vm.imageArea.y,
          })
          .width(this.vm.imageArea.width)
          .height(this.vm.imageArea.height)
          .visibility(this.vm.barIndex === 0 && this.vm.carouselCutTabIndex === 0 ? Visibility.Visible :
            Visibility.None);
        // 裁剪框
        Canvas(this.vm.cropContext)
          .position({
            x: this.vm.clipRect.x - 2,
            y: this.vm.clipRect.y - 2,
          })
          .width(this.vm.clipRect.width! + 4)
          .height(this.vm.clipRect.height! + 4)
          .visibility(this.vm.barIndex === 0 && this.vm.carouselCutTabIndex === 0 ? Visibility.Visible :
            Visibility.None)
          .onReady(() => {
            this.vm.drawClipImage(this.getUIContext());
          })
          .onTouch(event => {
            if (event.type === TouchType.Down) {
              this.vm.isMove(event.target.area, event.touches[0]);
              this.vm.touchPosition = {
                x: event.touches[0].displayX,
                y: event.touches[0].displayY,
              };
            } else if (event.type === TouchType.Move) {
              let moveX = event.changedTouches[0].displayX - this.vm.touchPosition.x;
              let moveY = event.changedTouches[0].displayY - this.vm.touchPosition.y;
              this.vm.touchPosition = {
                x: event.changedTouches[0].displayX,
                y: event.changedTouches[0].displayY,
              };
              if (this.vm.cropRatio === 0) {
                this.vm.moveClipCanvasFreeType(moveX, moveY);
              } else {
                this.vm.moveClipCanvasRatioType(moveX, moveY);
              }
            }
          });
        Image($r('app.media.switch'))
          .width(32)
          .height(32)
          .position({ bottom: 16, right: 16 })
          .visibility(this.vm.barIndex === -1 ? Visibility.Visible : Visibility.None)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.vm.currentPixelMapIndex = 0;
              this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
            } else if (event.type === TouchType.Up) {
              this.vm.currentPixelMapIndex = this.vm.totalPixelMapCount - 1;
              this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
            }
          });
      }
      .width('100%')
      .height('60%');
    }.padding({ left: 16, right: 16 });
  }
}