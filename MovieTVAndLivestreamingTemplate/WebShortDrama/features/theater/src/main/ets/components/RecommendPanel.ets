import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { AppStorageV2 } from '@kit.ArkUI'
import { DramaRecommendInfo } from './DramaRecommendInfo'
import { WindowManager } from '@agctemplate/utils'
import { onDramaClick } from './BannerPanel'
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition'
import { AiBarHeight, AppStorageKeys, BreakPoint, BreakPointType, BreakPointValue } from '@agctemplate/widgets'

@ComponentV2
export struct RecommendPanel {
  @Param @Require recommendList: Array<DramaCoverVM>
  @Param @Require gutter: number
  @Param inPage: string = ''
  @Local pixelMapImg: PixelMap | undefined = undefined;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local gridWidth: number = new BreakPointType<number>({
    sm: 104,
    md: 159,
    lg: 189
  }).getValue(this.currentBreakpoint.value)!

  build() {
    Row() {
      Row() {
        Grid() {
          ForEach(this.recommendList, (recommend: DramaCoverVM) => {
            GridItem() {
              DramaRecommendInfo({
                drama: recommend,
                inPage: this.inPage,
                onItemClick: async (options: DramaCoverVM) => {
                  this.requestImageUrl(recommend.imagePath as string);
                  options.pixelMapImg = this.pixelMapImg;
                  const longTakeTransitionParam: LongTakeTransitionParam | undefined =
                    await LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(),
                      'RecommendPanel' + recommend.dramaId, 8);
                  if (longTakeTransitionParam) {
                    options.longTakeTransitionParam = longTakeTransitionParam;
                  }
                  if (onDramaClick) {
                    onDramaClick(options, () => {
                      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                    })
                  }
                }
              })
            }

          }, (recommend: DramaCoverVM, index: number) => recommend.dramaId + index)
        }
        .columnsTemplate(`repeat(auto-stretch, ${this.gridWidth})`)
        .columnsGap(this.gutter)
        .rowsGap(16)
      }
      .alignItems(VerticalAlign.Top)
      .padding({ bottom: 72 + this.getUIContext().px2vp(this.aiBarHeight.value) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  requestImageUrl(url: string) {
    try {
      http.createHttp().request(url, (error: BusinessError, data: http.HttpResponse) => {
        if (error) {
          console.error(`request image failed: url: ${url}, code: ${error.code}, message: ${error.message}`);
        } else {
          try {
            let imgData: ArrayBuffer = data.result as ArrayBuffer;
            console.info(`request image success, size: ${imgData.byteLength}`);
            let imgSource: image.ImageSource = image.createImageSource(imgData);

            class SizeTmp {
              height: number = 100;
              width: number = 100;
            }

            let options: Record<string, number | boolean | SizeTmp> = {
              'alphaType': 0,
              'editable': false,
              'pixelFormat': 3,
              'scaleMode': 1,
              'size': { height: 100, width: 100 }
            }
            imgSource.createPixelMap(options).then((pixelMap: PixelMap) => {
              console.error('image createPixelMap success');
              this.pixelMapImg = pixelMap;
              imgSource.release();
            }).catch(() => {
              imgSource.release();
            })
          } catch (e) {
          }
        }
      })
    } catch (e) {
      console.error(`createHttp failed: ${e}`);
    }
  }
}