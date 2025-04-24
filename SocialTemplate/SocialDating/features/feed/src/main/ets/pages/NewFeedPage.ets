import {
  BasicUserInfo,
  CommonUtils,
  Constants,
  NavigationTitleBuilder,
  PhotoPickerPageParam,
  CreateFeedRequest,
  Feed
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import FeedService from '../service/FeedService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Builder
export function NewFeedPageBuilder() {
  NewFeedPage()
}

@Component
struct NewFeedPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private textInputController: TextInputController = new TextInputController()
  @State feedMsg: string | null = null;
  @State selectUris: Array<string> = [];

  aboutToAppear(): void {
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          TextArea({
            text: this.feedMsg,
            placeholder: '展示自我，分享生活，在这里肆意挥洒文采吧～',
            controller: this.textInputController
          })
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: 14, weight: FontWeight.Regular, family: Constants.HARMONY_HEITI })
            .caretColor($r('sys.color.font_emphasize'))
            .height('auto')
            .borderRadius(10)
            .maxLines(Constants.FEED_MSG_MAX_LINES)
            .maxLength(Constants.FEED_MSG_MAX_LENGTH)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.Black)
            .wordBreak(WordBreak.BREAK_ALL)
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.feedMsg = value;
            })
        }.margin({ top: 12, bottom: 12 })

        this.showFeedImage(Constants.FEED_IMAGE_SIZE)

      }.backgroundColor(Color.White).borderRadius(16).width('92%')

      Row() {
        Button('发布')
          .backgroundColor($r('app.color.button_background_color'))
          .width('92%')
          .fontSize($r('sys.float.Body_L'))
          .enabled(!CommonUtils.isBlank(this.feedMsg) || (this.selectUris != null && this.selectUris.length > 0))
          .onClick(() => {
            Logger.debug('---------------before publish, selectUris=' + JSON.stringify(this.selectUris))
            let currentUser: BasicUserInfo | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
            if (currentUser != null && currentUser !== undefined && currentUser.uid != null) {
              FeedService.createFeed(new CreateFeedRequest(currentUser.uid, this.feedMsg, this.selectUris))
                .then((data: number | null) => {
                  Logger.debug('createFeed rsp=' + data)
                  if (data != null) {
                    FeedService.getFeedDetail(data).then((feedDetail: Feed | null) => {
                      Logger.debug('getFeedDetail rsp=' + JSON.stringify(feedDetail))
                      if (feedDetail != null) {
                        this.pageStack.pop('', false);
                      }
                    })
                  }
                })
            }
          })
      }.margin({ top: 20 })

    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('发布动态'))
  }

  @Builder
  showFeedImage(gridItemHeight: number) {
    Row() {
      this.gridShowImage('1fr 1fr 1fr', '1fr 1fr 1fr', (gridItemHeight + 10) * 3, gridItemHeight);
    }.padding({ left: 12, right: 12 }).width('100%').justifyContent(FlexAlign.Start)
  }

  @Builder
  showCross(size: number, index: number) {
    Image($r('sys.media.ohos_ic_public_close'))
      .width(size)
      .height(size)
      .backgroundColor(Color.White)
      .objectFit(ImageFit.Cover)
      .clipShape(new Circle({ width: size, height: size }))
      .onClick(() => {
        this.selectUris.splice(index, 1)
      })
  }

  @Builder
  gridShowImage(rowTemplate: string, columnTemplate: string, gridHeight: number,
    gridItemHeight: number) {
    Grid() {
      ForEach(this.selectUris, (imageResource: string, index: number) => {
        GridItem() {
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            this.showOneImage(imageResource, gridItemHeight, index)
          }
        }
      }, (imageResource: string) => imageResource);

      if (this.selectUris.length < 9) {
        GridItem() {
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Column() {
              Row() {
                Text('+').fontSize(36).fontColor($r('app.color.text_font_color_black'))
              }.margin({ top: 10, bottom: 10 }).justifyContent(FlexAlign.Center)

              Row() {
                Text('上传图片')
                  .fontSize($r('sys.float.Body_M'))
                  .fontFamily(Constants.HARMONY_HEITI)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('app.color.text_font_color_black'))
              }.margin({ bottom: 12 })
            }
            .width(Constants.FEED_IMAGE_SIZE)
            .height(Constants.FEED_IMAGE_SIZE)
            .backgroundColor($r('app.color.light_grey_bg'))
            .borderRadius(8)
            .onClick(() => {
              this.pageStack.pushPathByName('CommonPhotoPicker',
                new PhotoPickerPageParam(Constants.FEED_MAX_IMAGES - this.selectUris.length,
                  photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE),
                (popInfo: PopInfo) => {
                  this.selectUris = this.selectUris.concat(popInfo.result as Array<string>);
                  Logger.debug('---------------  on pop selectUris=' + JSON.stringify(this.selectUris))
                })
            })
          }
        }
      }
    }
    .rowsTemplate(rowTemplate)
    .columnsTemplate(columnTemplate)
    .margin({ bottom: 16 })
    .height(gridHeight)
  }

  @Builder
  showOneImage(imageResource: string, gridItemHeight: number, index: number) {
    Stack() {
      Image(imageResource)
        .borderRadius(8)
        .width(gridItemHeight)
        .height(gridItemHeight)
        .objectFit(ImageFit.Cover)
      Image($r('sys.media.ohos_ic_public_close'))
        .width(16)
        .height(16)
        .backgroundColor(Color.White)
        .objectFit(ImageFit.Cover)
        .clipShape(new Circle({ width: 16, height: 16 }))
        .position({ x: '82%', y: -6 })
        .onClick(() => {
          this.selectUris.splice(index, 1)
        })
    }
  }
}