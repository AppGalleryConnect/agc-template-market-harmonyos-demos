import { JSON, util } from '@kit.ArkTS';
import { LoginManageUtil, MemberManageUtil, UPDATE_MEMBER_STATUS } from 'module_base';
import { LoginSheetUtils } from 'aggregated_login';
import { MemberSheetUtils } from 'membership';
import { StickerShowModel } from '../model/PageParams';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct StickerToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local stickerTabIndex: number = 0;
  @Local isMember: boolean = false;
  @Local currentStickerList: StickerShowModel[] = [];
  @Local stickerShowList: Map<string, StickerShowModel[]> = new Map<string, StickerShowModel[]>();

  async aboutToAppear(): Promise<void> {
    this.isMember = await MemberManageUtil.queryMemberStatus(this.getUIContext());
    this.getCurrentStickerList();
    this.getUIContext().getHostContext()!.eventHub.on(UPDATE_MEMBER_STATUS, (status: boolean) => {
      this.isMember = status;
    });
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()!.eventHub.off(UPDATE_MEMBER_STATUS);
  }

  async getCurrentStickerList() {
    this.currentStickerList =
      await this.getList(Constants.stickerTagListMap.get(Constants.stickerTagList[this.stickerTabIndex])!);
  }

  handleStickerClick(item: StickerShowModel) {
    let loginManageUtil = new LoginManageUtil(this.getUIContext());
    if (!item.isVip) {
      this.vm.stickerList.push({
        id: util.generateRandomUUID(),
        positionX: 0,
        positionY: 0,
        img: item.imageSource,
      });
    } else {
      if (loginManageUtil.userInfoModel.isLogin && this.isMember) {
        this.vm.stickerList.push({
          id: util.generateRandomUUID(),
          positionX: 0,
          positionY: 0,
          img: item.imageSource,
        });
      } else {
        if (!loginManageUtil.userInfoModel.isLogin) {
          LoginSheetUtils.open(loginManageUtil.params, this.getUIContext());
        } else if (!this.isMember) {
          let memberManageUtil = new MemberManageUtil(this.getUIContext());
          MemberSheetUtils.open(memberManageUtil.productsInfo, this.getUIContext());
        }
      }
    }
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 24 }) {
        ForEach(Constants.stickerTagList, (item: string, index: number) => {
          Text(item)
            .fontSize(16)
            .fontColor(this.stickerTabIndex === index ? '#ED6F21' : Color.Black)
            .onClick(() => {
              this.stickerTabIndex = index;
              this.getCurrentStickerList();
            });
        }, (item: string) => item);
      }.width('100%').justifyContent(FlexAlign.Start);

      this.stickerContentBuilder();

      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
            this.cleanSticker();
          });
        Text('贴纸')
          .fontSize(16);
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.saveImage();
            this.cleanSticker();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .padding(16)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  @Builder
  stickerContentBuilder() {
    Grid() {
      ForEach(this.currentStickerList, (item: StickerShowModel) => {
        GridItem() {
          Stack() {
            Stack({ alignContent: Alignment.TopStart }) {
              Image(item.imageSource).size({ width: 48, height: 48 });

              if (item.isVip) {
                Image($r('app.media.vip_decorate'))
                  .size({ width: 12, height: 12 }).margin({ left: 2, top: 2 });
              }
            };
          }
          .backgroundColor('#F1F3F5')
          .borderRadius(8)
          .alignContent(Alignment.BottomStart)
          .onClick(() => {
            this.handleStickerClick(item);
          });
        };
      }, (item: StickerShowModel, index: number) => item.tag[0] + index.toString());
    }
    .scrollBar(BarState.Off)
    .height(108)
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    .rowsGap(12)
    .columnsGap(12);
  }

  async getList(item: string): Promise<StickerShowModel[]> {
    let result: StickerShowModel[] = [];
    let value = await this.getUIContext().getHostContext()?.resourceManager.getRawFileList('sticker');

    if (value) {
      for (let i = 0; i < value.length; i++) {
        if (value[i].toString().includes(item)) {
          let path = 'sticker/' + value[i];
          let stickerShow: StickerShowModel = {
            imageSource: $rawfile(path),
            tag: [item],
            isVip: i === value.length - 1 ? true : false,
          };
          result.push(stickerShow);
        }
      }
    }
    return result;
  }

  cleanSticker() {
    this.stickerTabIndex = 0;
    this.vm.stickerList = [];
  }
}