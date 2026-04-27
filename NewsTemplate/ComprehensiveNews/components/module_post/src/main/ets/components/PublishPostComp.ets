import { KeyboardAvoidMode, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { Permissions } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'module_imagepreview';
import {
  Constants,
  DEFAULT_IMAGE_PARAM,
  DEFAULT_VIDEO_PARAM,
  PostImgVideoItem,
  UploadType,
  MediaParams,
  GRID_ROW_OPTIONS,
  COL_SPAN,
  COL_OFFSET,
  ImageContent,
} from '../constants/Constants';
import { TextSpanInfo, Topic, User } from '../types/Types';
import { MediaUtils } from '../utils/MediaUtils';
import { FileUtils } from '../utils/FileUtils';
import { getPageMargin } from '../utils/Common';
import { LocationUtils } from '../utils/LocationUtils';
import { PermissionUtils } from '../utils/PermissionUtils';
import { TopicSheetView } from './TopicSheetView';
import { ContactSheetView } from './ContactSheetView';
import { PostController } from '../controller/PostController';
import { RichEditorView } from './RichEditorView';
import { RichEditorViewController } from '../controller/RichEditorViewController';

const TAG = '[PublishPostComp]';

@ComponentV2
export struct PublishPostComp {
  // 字体大小比例
  @Param fontRatio: number = 1;
  // 主体色
  @Param themeColor: ResourceColor = '#5C79D9';
  // 图片参数
  @Param imageParams: MediaParams = DEFAULT_IMAGE_PARAM;
  // 视频参数
  @Param videoParams: MediaParams = DEFAULT_VIDEO_PARAM;
  // 发帖控制器
  @Param postController: PostController = new PostController();
  // RichEditor控制器
  @Param richEditorController: RichEditorController = new RichEditorController();
  // 初始化是携带的话题
  @Param attachedTopic: Topic = { id: '', title: '' };
  // 话题列表
  @Param topicList: Topic[] = [];
  // 联系人列表
  @Param userList: User[] = [];
  // 图文变化的回调
  @Event onChange: (body: string, mediaList: PostImgVideoItem[], cityLocation?: string) => void = () => {
  };
  // 键盘是否被拉起
  @Event isFocus: (result: boolean) => void = () => {
  }
  // 跳转话题详情页
  @Event jumpTopicPage: (topic: Topic) => void = () => {
  };
  @Local private body: string = '[]';
  @Local private imgList: PostImgVideoItem[] = [];
  @Local private videoList: PostImgVideoItem[] = [];
  @Local private columnsNum: number = 3;
  @Local private breakpoint: string = 'sm';
  @Local private showTopicSheet: boolean = false;
  @Local private showContactSheet: boolean = false;
  @Local private selectedTopic: Topic | null = null;
  @Local private selectedContact: User | null = null;
  @Local private locationText: string = Constants.DEFAULT_LOCATION_TEXT;
  @Local private richEditorViewController: RichEditorViewController = new RichEditorViewController();

  @Monitor('body', 'imgList.length', 'videoList.length', 'locationText')
  onContentChange() {
    this.onChange(this.body, [...this.imgList, ...this.videoList], this.isLocationSelected ? this.locationText : '');
  }

  aboutToAppear(): void {
    this.initConfig();
    this.addKeyboardListener();
  }

  aboutToDisappear(): void {
    this.cancelKeyboardListener();
  }

  initConfig() {
    this.postController.joinDiscuss = (topic) => {
      this.insertTopic(topic);
    };
  }

  addKeyboardListener() {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
      windowClass.on('keyboardHeightChange', this.onKeyBoardCB);
    } catch (e) {
      UtilLog.error(TAG, 'on keyboardHeightChange fail, error: ' + JSON.stringify(e));
    }
  }

  cancelKeyboardListener() {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
      windowClass.off('keyboardHeightChange', this.onKeyBoardCB);
    } catch (e) {
      UtilLog.error(TAG, 'off keyboardHeightChange fail, error: ' + JSON.stringify(e));
    }
  }

  build() {
    Column() {
      GridRow(GRID_ROW_OPTIONS) {
        GridCol({
          span: COL_SPAN,
          offset: COL_OFFSET,
        }) {
          Scroll() {
            Column() {
              this.textArea()
              this.mediaArea()
            }
            .width(Constants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Start)
          }
          .width(Constants.FULL_PERCENT)
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
      }
      .layoutWeight(1)
      .padding({
        left: getPageMargin(this.breakpoint),
        right: getPageMargin(this.breakpoint),
      })
      .onBreakpointChange((bp: string) => {
        this.breakpoint = bp;
        if (bp === 'sm') {
          this.columnsNum = 3;
        } else {
          this.columnsNum = 6;
        }
      })

      this.newToolBar()
      this.actionBar()
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .onAppear(() => {
      this.handleKeyBoard();
    })
    .onDisAppear(() => {
      this.cancelHandleKeyBoard()
    })
  }

  @Computed
  get plainText() {
    try {
      const list = JSON.parse(this.body) as TextSpanInfo[];
      return list.map(v => v.text).join('');
    } catch (e) {
      return '';
    }
  }

  @Computed
  get imageTip() {
    if (this.imageParams.maxSize) {
      return `图片大小不超过${this.imageParams.maxSize}MB，最多支持上传${this.imageParams.maxLimit}张图片`;
    }
    return `最多支持上传${this.imageParams.maxLimit}张图片`;
  }

  @Computed
  get videoTip() {
    if (this.videoParams.maxSize) {
      return `视频大小不超过${this.videoParams.maxSize}MB，最多支持上传${this.videoParams.maxLimit}个视频`;
    }
    return `最多支持上传${this.videoParams.maxLimit}个视频`;
  }

  @Computed
  get isLocationSelected() {
    return this.locationText !== Constants.DEFAULT_LOCATION_TEXT;
  }

  getImageId(v: PostImgVideoItem) {
    return `image_${v.picVideoUrl}_${v.id}`;
  }

  insertTopic(topic: Topic) {
    this.selectedTopic = topic;
    this.richEditorViewController.insertTopic(topic);
    this.showTopicSheet = false;
  }

  async handleLocationClick() {
    if (this.isLocationSelected) {
      return;
    }

    const locationPermission: Permissions = 'ohos.permission.APPROXIMATELY_LOCATION';

    // 检查权限
    if (!PermissionUtils.checkPermissionGrant(locationPermission)) {
      const granted =
        await PermissionUtils.requestPermissions(this.getUIContext().getHostContext() as Context, [locationPermission]);
      if (!granted) {
        return;
      }
    }

    // 获取城市信息
    const city = await LocationUtils.getCurrentCityInfo();
    this.locationText = city.cityName || Constants.DEFAULT_LOCATION_TEXT;
  }

  @Builder
  textArea() {
    Column() {
      RichEditorView({
        controller: this.richEditorController,
        viewController: this.richEditorViewController,
        attachedTopic: this.attachedTopic,
        fontRatio: this.fontRatio,
        themeColor: this.themeColor,
        showContactSheet: () => {
          this.showContactSheet = true;
        },
        showTopicSheet: () => {
          this.showTopicSheet = true;
        },
        onChange: (text: string) => {
          this.body = text;
        },
      })
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.MAX_TEXTAREA_HEIGHT)
  }

  @Builder
  mediaArea() {
    Column({ space: Constants.SPACE_8 }) {
      Grid() {
        if (this.showUploadBox) {
          GridItem() {
            this.uploadBox()
          }
        }

        ForEach(this.imgList, (v: PostImgVideoItem) => {
          GridItem() {
            this.imageBox(v)
          }
        }, (v: PostImgVideoItem) => v.picVideoUrl + v.id)

        ForEach(this.videoList, (v: PostImgVideoItem) => {
          GridItem() {
            this.videoBox(v)
          }
        }, (v: PostImgVideoItem) => v.picVideoUrl + v.id)
      }
      .columnsTemplate(this.getColumnsTemplate)
      .columnsGap(12)
      .rowsGap(8)
      .maxCount(this.getMaxCount)
      .scrollBar(BarState.Off)

      Text(this.isImageType ? this.imageTip : this.videoTip)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_tertiary'))
        .visibility((this.imgList.length || this.videoList.length) > 0 ? Visibility.Visible : Visibility.Hidden)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  topicSheetBuilder() {
    TopicSheetView({
      topicList: this.topicList,
      onSelect: (topic) => {
        this.insertTopic(topic);
      },
      jumpTopicPage: (topic) => {
        this.jumpTopicPage(topic);
      },
    })
  }

  @Builder
  contactSheetBuilder() {
    ContactSheetView({
      userList: this.userList,
      onSelect: (user) => {
        this.selectedContact = user;
        this.richEditorViewController.insertContact(user);
        this.showContactSheet = false;
      },
    })
  }

  @Builder
  newToolBar() {
    Row() {
      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.local'))
          .fontSize(16)
          .fontColor(this.isLocationSelected ? [$r('sys.color.brand')] : [$r('sys.color.font_secondary')])
        Text(this.locationText)
          .fontSize(14)
          .fontColor(this.isLocationSelected ? $r('sys.color.brand') : $r('sys.color.font_secondary'))

        if (this.isLocationSelected) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_secondary')])
            .onClick(() => {
              this.locationText = Constants.DEFAULT_LOCATION_TEXT;
            })
        }
      }
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4,
      })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(14)
      .onClick(() => {
        this.handleLocationClick();
      })
    }
    .width(Constants.FULL_PERCENT)
    .height(48)
    .padding({
      left: getPageMargin(this.breakpoint),
      right: getPageMargin(this.breakpoint),
    })
  }

  @Builder
  actionBar() {
    Row({ space: Constants.PADDING_16 }) {
      Image($r('app.media.ic_public_camera'))
        .width(Constants.ICON_WIDTH)
        .height(Constants.ICON_WIDTH)
        .draggable(false)
        .fillColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.uploadImage();
        })
      Image($r('app.media.ic_public_recorder'))
        .width(Constants.ICON_WIDTH)
        .height(Constants.ICON_WIDTH)
        .draggable(false)
        .fillColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.uploadVideo();
        })
      SymbolGlyph($r('sys.symbol.at'))
        .fontColor([$r('sys.color.font_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(Constants.ICON_WIDTH)
        .onClick(() => {
          this.showContactSheet = true;
        })
        .bindSheet($$this.showContactSheet, this.contactSheetBuilder(), {
          title: { title: '联系人' },
          height: SheetSize.LARGE,
          showClose: true,
          preferType: SheetType.CENTER,
        })
      SymbolGlyph($r('sys.symbol.topic'))
        .fontColor([$r('sys.color.font_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(Constants.ICON_WIDTH)
        .onClick(() => {
          this.showTopicSheet = true;
        })
        .bindSheet($$this.showTopicSheet, this.topicSheetBuilder(), {
          title: { title: '添加话题' },
          height: SheetSize.LARGE,
          showClose: true,
          preferType: SheetType.CENTER,
          mode: SheetMode.EMBEDDED,
        })
      Blank()
      Text(`${this.plainText.length}/${Constants.MAX_BODY_WORD_LIMIT}`)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.ACTION_BAR_HEIGHT)
    .padding({
      left: getPageMargin(this.breakpoint),
      right: getPageMargin(this.breakpoint),
    })
    .shadow({
      offsetY: -2,
      radius: 4,
      color: '#F2F2F2',
    })
  }

  @Builder
  uploadBox() {
    Column({ space: 4 }) {
      Image($r('app.media.ic_plus2'))
        .width(Constants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .fillColor($r('sys.color.icon_secondary'))
    }
    .width(Constants.FULL_PERCENT)
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(async () => {
      this.plusBtnClick();
    })
  }

  @Builder
  imageBox(v: PostImgVideoItem) {
    RelativeContainer() {
      Image(v.picVideoUrl)
        .width(Constants.FULL_PERCENT)
        .aspectRatio(1)
        .draggable(false)
        .autoResize(true)
        .id(this.getImageId(v))
      Image($r('app.media.ic_public_close_circle'))
        .width(Constants.ICON_WIDTH)
        .aspectRatio(1)
        .draggable(false)
        .margin({
          top: Constants.SPACE_8,
          right: Constants.SPACE_8,
        })
        .alignRules({
          top: { anchor: this.getImageId(v), align: VerticalAlign.Top },
          right: { anchor: this.getImageId(v), align: HorizontalAlign.End },
        })
        .onClick(() => {
          const index = this.imgList.findIndex(item => item.id === v.id && item.picVideoUrl === v.picVideoUrl);
          if (index !== -1) {
            this.imgList.splice(index, 1);
          }
        })

      SymbolGlyph($r('sys.symbol.livephoto'))
        .fontColor([$r('sys.color.font_on_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(16)
        .visibility(v.movingPhoto ? Visibility.Visible : Visibility.None)
        .margin({
          left: Constants.SPACE_8,
          bottom: Constants.SPACE_8,
        })
        .alignRules({
          bottom: { anchor: this.getImageId(v), align: VerticalAlign.Bottom },
          left: { anchor: this.getImageId(v), align: HorizontalAlign.Start },
        })
    }
    .width('auto')
    .height('auto')
    .borderRadius(16)
    .clip(true)
    .onClick(() => {
      const index = this.imgList.findIndex(item => item.id === v.id && item.picVideoUrl === v.picVideoUrl);
      const options = new ImagePreviewOptions()
      options
        .setImageList(this.imgList.map(v => new SourceImageModel({
          imageUrl: v.picVideoUrl,
          movingPhoto: v.movingPhoto,
        })))
        .setLoop(false)
        .setLongTake(false)
        .setInitIndex(index)
      ImagePreview.open(this.getUIContext(), options)
    })
  }

  @Builder
  videoBox(v: PostImgVideoItem) {
    Stack() {
      Stack() {
        Image(v.surfaceUrl)
          .width(Constants.FULL_PERCENT)
          .aspectRatio(1)
          .draggable(false)
          .autoResize(true)
        Row()
          .width(Constants.FULL_PERCENT)
          .aspectRatio(1)
          .backgroundColor($r('sys.color.mask_fourth'))
        Image($r('app.media.ic_public_close_circle'))
          .width(Constants.ICON_WIDTH)
          .aspectRatio(1)
          .draggable(false)
          .borderRadius(16)
          .margin({
            top: Constants.SPACE_8,
            right: Constants.SPACE_8,
          })
          .onClick(() => {
            const index = this.videoList.findIndex(item => item.id === v.id && item.picVideoUrl === v.picVideoUrl);
            if (index !== -1) {
              this.videoList.splice(index, 1);
            }
          })
      }
      .alignContent(Alignment.TopEnd)

      Image($r('app.media.ic_video_flag'))
        .width(Constants.ICON_WIDTH)
        .draggable(false)
    }
    .alignContent(Alignment.Center)
    .borderRadius(16)
    .clip(true)
  }

  showToast(options: promptAction.ShowToastOptions) {
    try {
      this.getUIContext().getPromptAction().showToast(options);
    } catch (e) {
      UtilLog.error(TAG, 'showToast fail, error: ' + JSON.stringify(e));
    }
  }

  uploadImage() {
    if (this.videoList.length) {
      this.showToast({
        message: '图片与视频一次只可上传一种',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    if (this.imgList.length >= this.imageParams.maxLimit) {
      this.showToast({
        message: '已添加的图片数量已达上限',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    this.plusBtnClick(UploadType.Image);
  }

  uploadVideo() {
    if (this.imgList.length) {
      this.showToast({
        message: '图片与视频一次只可上传一种',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    if (this.videoList.length >= this.videoParams.maxLimit) {
      this.showToast({
        message: '已添加的视频数量已达上限',
        bottom: this.toastMarginBottom,
      });
      return;
    }
    this.plusBtnClick(UploadType.Video);
  }

  async plusBtnClick(type?: UploadType) {
    let isUploadImage = true;
    if (type && type === UploadType.Image) {
      isUploadImage = true;
    } else if (type && type === UploadType.Video) {
      isUploadImage = false;
    } else {
      isUploadImage = this.isImageType;
    }
    let params = isUploadImage ? this.imageParams : this.videoParams;
    let list = isUploadImage ? this.imgList : this.videoList;

    const uriList = await MediaUtils.selectMedia(this.getUIContext().getHostContext() as Context, {
      type: params.type,
      maxLimit: params.maxLimit - list.length,
      maxSize: params.maxSize,
    });
    uriList.forEach(async (v: ImageContent) => {
      const item = new PostImgVideoItem();
      item.id = new Date().getTime();
      item.movingPhoto = v.movingPhoto;
      item.picVideoUrl = v.src;
      if (!isUploadImage) {
        const thumbnail = await MediaUtils.getVideoThumbnail(v.src);
        item.surfaceUrl = await FileUtils.writePixelMap(this.getUIContext(), thumbnail);
      }
      list.push(item);
    })
  }

  handleKeyBoard() {
    // 键盘避让设置为压缩模式
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    this.getUIContext().animateTo({
      duration: 200,
      curve: Curve.EaseInOut,
    }, () => {
      if (!height) {
        this.isFocus(false)
      } else {
        this.isFocus(true)
      }
    });
  };

  cancelHandleKeyBoard() {
    // 键盘避让还原成上抬模式
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }

  @Computed
  get toastMarginBottom() {
    return 40;
  }

  @Computed
  get getMaxCount() {
    return Math.max(this.imageParams.maxLimit, this.videoParams.maxLimit) + 1;
  }

  @Computed
  get getColumnsTemplate() {
    return Array(this.columnsNum).fill('1fr').join(' ');
  }

  @Computed
  get isImageType() {
    return this.imgList.length > 0;
  }

  @Computed
  get showUploadBox() {
    if (this.imgList.length && this.imgList.length < this.imageParams.maxLimit) {
      return true;
    }
    if (this.videoList.length && this.videoList.length < this.videoParams.maxLimit) {
      return true;
    }
    return false;
  }
}