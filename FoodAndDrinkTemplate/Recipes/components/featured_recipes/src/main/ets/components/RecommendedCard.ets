import { HwAdService } from 'aggregated_ads'
import { RecipeBriefInfo } from '../types/Index'
import { MovingPhotoView, MovingPhotoViewController, photoAccessHelper } from '@kit.MediaLibraryKit'
import { common } from '@kit.AbilityKit'
import { VideoView } from './VideoView'

@ComponentV2
export struct RecommendedCard {
  @Param recipe: RecipeBriefInfo = new RecipeBriefInfo()
  @Param isToDelete: boolean = false
  @Param canDelete: boolean = false
  @Param recipeIndex: number = 0;
  @Local src: photoAccessHelper.MovingPhoto | undefined = undefined;
  controller: MovingPhotoViewController = new MovingPhotoViewController();
  videoController: VideoController = new VideoController();
  @Event jumpBloggerInfo: () => void = () => {
  }
  @Event changeDeleteState: (isToDelete: boolean) => void = () => {
  }
  @Event onClickCb: (id: number, index:number) => void = () => {
  }
  @Event changeSelect: (id: number, flag: boolean) => void = () => {
  }
  @Event deleteAds: (id: number, index:number) => void = () => {
  }

  async aboutToAppear(): Promise<void> {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if(this.recipe.video && this.recipe.thumbnail) {
      let imageFileUri = this.recipe.thumbnail;
      let videoFileUri = this.recipe.video;
      this.src = await photoAccessHelper.MediaAssetManager.loadMovingPhoto(context, imageFileUri, videoFileUri);
    }
  }

  build() {
    if(this.recipe.authorId === 10001){
      Column() {
        Stack() {
          HwAdService({
            // todo 替换广告id
            adId: 'testu7m3hc4gvm',
            adType: 3,
          })
          Image($r('app.media.ic_close'))
            .width(16)
            .height(16)
            .opacity(0.5)
            .borderRadius(16)
            .position({ x: '88%', y: 8 })
            .onClick(()=>{
              this.deleteAds(this.recipe.id, this.recipeIndex)
            })
        }
        .borderRadius(8)
        .width('100%')
        .height(160)
        .clip(true)
        .align(Alignment.Bottom);

        Text(this.recipe.title)
          .width('100%')
          .margin({ top: 8, bottom: 4 })
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14)
          .padding({left: 10, right: 10})
        Row() {
          Row({ space: 4 }) {
            Image($r(`app.media.${this.recipe.authorAvatar}`)).width(20).height(20).borderRadius(10);
            Text(this.recipe.author).fontSize(12).fontColor($r('sys.color.font_secondary'));
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({left: 10, right: 10})
        .margin({bottom: 8})
      }
      .borderRadius(8)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
    } else {
      Column() {
        Stack() {
          if(this.recipe.video) {
            if(this.recipe.thumbnail) {
              Row() {
                MovingPhotoView({
                  movingPhoto: this.src,
                  controller: this.controller
                })
                Image($r('app.media.livephoto')).position({ x: 10, y: 130 })
                  .width(20)
                  .height(20)
                  .onClick(() => {
                    this.controller.startPlayback()
                  })
              }
              .height(160)
              .width('100%')
              .borderRadius(8)
              .clip(true)
            } else {
              Stack({alignContent: Alignment.TopEnd}) {
                VideoView({
                  videoData: this.recipe,
                  isSlider: false,
                  isCover: true,
                  onClickCb: (id: number) => {
                    this.onClickCb(id, this.recipeIndex)
                  },
                });
                Image($r('app.media.ic_video_pause'))
                  .width(12)
                  .height(12)
                  .margin(14)
                  .onClick(() => {
                    this.onClickCb(this.recipe.id, this.recipeIndex)
                  })
              }
            }
          } else {
            if(this.recipe.thumbnail.includes('.png')) {
              Image(this.recipe.thumbnail)
                .width('100%')
                .objectFit(ImageFit.Cover)
                .height(160)
                .draggable(false)
            } else {
              Image($r(`app.media.${this.recipe.thumbnail}`))
                .width('100%')
                .objectFit(ImageFit.Cover)
                .height(160)
                .draggable(false)
            }
            if(this.recipe.isVip) {
              Text('VIP')
                .width(32)
                .height(16)
                .fontSize(10)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
                .borderRadius({
                  topLeft: 8,
                  topRight: 0,
                  bottomRight: 8,
                  bottomLeft: 0
                })
                .backgroundColor('#fff9a01e')
                .position({ x: 0, y: 0 })
            }
          }
          if (this.canDelete && this.isToDelete) {
            Row() {
              Checkbox()
                .width(20)
                .height(20)
                .selectedColor('#E84026')
                .unselectedColor('#33FFFFFF')
                .onChange((res: boolean) => {
                  this.changeSelect(this.recipe.id, res)
                });
            }.width('100%').justifyContent(FlexAlign.End).padding({ bottom: 8, right: 8 });
          }
        }
        .borderRadius({topLeft: 8, topRight: 8})
        .width('100%')
        .height(160)
        .clip(true)
        .align(Alignment.Bottom);

        Text(this.recipe.title)
          .width('100%')
          .margin({ top: 8, bottom: 4 })
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14)
          .padding({left: 10, right: 10})
        Row() {
          Row({ space: 4 }) {
            Image($r(`app.media.${this.recipe.authorAvatar}`)).width(20).height(20).borderRadius(10);
            Text(this.recipe.author).fontSize(12).fontColor($r('sys.color.font_secondary'));
          }.onClick(() => {
            this.jumpBloggerInfo()
          })
          Row({ space: 5 }) {
            Image($r('app.media.ic_public_star_plain'))
              .fillColor($r('sys.color.font_secondary'))
              .width(15)
              .height(14);
            Text(this.formatCollection(this.recipe.likes))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'));
          };
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({left: 10, right: 10})
        .margin({bottom: 8})

        Row() {
          Row() {
            Image($r('app.media.ic_hot_icon'))
              .width(16)
              .height(16)
            if(this.recipe.heatness) {
              Text(`热搜榜NO.${this.recipe.heatness}`)
                .fontSize(12)
                .fontFamily('HarmonyHeiTi')
                .fontColor(Color.White)
                .margin({left: 2})
            }
          }
          .backgroundColor('rgba(249, 160, 30, 1)')
          .height(16)
          .padding(2)
          .borderRadius(4)
        }
        .margin({ left: 12, bottom: 10})
        .width('100%')
        .visibility(this.recipe.heatness ? Visibility.Visible : Visibility.None)
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(8)
      .width('100%')
      .gesture(GestureGroup(GestureMode.Exclusive,
        LongPressGesture({ repeat: true })
          .onAction(() => {
            this.changeDeleteState(true);
          }),
        TapGesture({ count: 1, fingers: 1 })
          .onAction(() => {
            this.onClickCb(this.recipe.id, this.recipeIndex)
          }),
      ),
      );
    }
  }

  formatCollection(count: number): string {
    if (count > 1000) {
      return (count / 1000).toFixed(1) + 'K'
    }
    return count.toString()
  }
}
