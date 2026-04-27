import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { UtilLog as Logger, UtilLog } from '@hw-agconnect/util-log';
import { formatFileSize } from '../util/FormatUtil';
import { MediaInfo, MediaType, CastParams, MediaData } from '../model/Index';
import { PermissionUtil } from '../util/PermissionUtil';
import { formatTime } from '../util/FormatUtil';

@ComponentV2
export struct VideoList {
  @Local context: common.UIAbilityContext | null = null;
  @Local selectIndex: number = 0;
  @Local mediaList: MediaInfo[] = [];
  uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Event onSelect: (param: CastParams) => void = () => {

  };

  aboutToAppear(): void {
    this.getVideo();
  }

  public toCast() {
    const videoList = this.mediaList.map((item, index) => {
      const obj: MediaData = {
        id: `video${index}`,
        sortId: index,
        name: item.name,
        mediaType: item.type,
        head: item.headImg,
        url: item.url,
        duration: item.duration,
      };
      return obj;
    });

    const params: CastParams = {
      selectIndex: this.selectIndex,
      mediaList: videoList,
      mediaType: MediaType.VIDEO,
    };
    this.onSelect(params);
  }

  // 获取视频
  async getVideo() {
    const hasPermission = await PermissionUtil._checkPermissions('ohos.permission.READ_IMAGEVIDEO');
    if (!hasPermission) {
      PermissionUtil.requestPermissions(['ohos.permission.READ_IMAGEVIDEO'], this.uiContext);
    }
    // 图片和视频
    try {
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.uiContext);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo(photoAccessHelper.PhotoKeys.PHOTO_TYPE, photoAccessHelper.PhotoType.VIDEO);
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: [photoAccessHelper.PhotoKeys.DURATION, photoAccessHelper.PhotoKeys.SIZE],
        predicates: predicates,
      };

      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOption);
      fetchResult.getAllObjects((err, photoAssetList) => {
        if (err === undefined) {
          this.mediaList = [];
          photoAssetList.forEach(async (asset) => {
            // 获取时长
            let duration: photoAccessHelper.MemberType = asset.get(photoAccessHelper.PhotoKeys.DURATION);
            // 获取文件大小
            let size: photoAccessHelper.MemberType = asset.get(photoAccessHelper.PhotoKeys.SIZE);
            // 获取缩略图
            let headImg = await asset.getThumbnail();
            const video: MediaInfo = {
              name: asset.displayName,
              url: asset.uri,
              duration: Number(duration),
              type: MediaType.VIDEO,
              headImg: headImg,
              size: formatFileSize(Number(size)),
            };
            this.mediaList.push(video);
          });

        } else {
          Logger.error(`photoAsset failed with err:${err.code}, ${err.message}`);
        }
      });
    } catch (e) {
      UtilLog.error(`getVideo failed with error ${JSON.stringify(e)}`);
    }
  }

  build() {
    if (this.mediaList.length > 0) {
      List({ space: 12 }) {
        ForEach(this.mediaList, (item: MediaInfo, index) => {
          ListItem() {
            Row({ space: 12 }) {
              Stack() {
                Image(item.headImg).width('100%');
                if (item.type === MediaType.VIDEO) {
                  Image($r('app.media.ic_file_play')).width(24).height(24);
                }
              }.width(64).height(64).borderRadius(12).clip(true);

              Column({ space: 8 }) {
                Text(item.name)
                  .width('100%')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium);
                Row({ space: 9 }) {
                  Text(`大小：${item.size}`).labelExtend();
                  Text(`时长：${formatTime(item.duration)}`).labelExtend();
                };

              }.layoutWeight(1).height(46).alignItems(HorizontalAlign.Start);

              Image($r('app.media.ic_list_device')).width(24).onClick(() => {
                this.selectIndex = index;
                this.toCast();
              });
            };
          };
        }, (item: MediaInfo, index) => item.name);
      }.scrollBar(BarState.Off)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
    } else {
      Column() {

        Column({ space: 24 }) {
          Image($r('app.media.ic_search_missing')).width(120);
          Text('暂无文件').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
        };

      }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center);
    }

  }
}

@Extend(Text)
function labelExtend() {
  .fontColor($r('sys.color.font_secondary'))
  .fontSize($r('sys.float.Caption_L'))
  .fontWeight(FontWeight.Medium)
  .constraintSize({ minWidth: 86 });
}