import { https, ShopItem, SubmitCommentRequest } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, RouterModule } from 'commonlib';
import { SubmitCommentModel } from '../models/SubmitCommentModel';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class SubmitCommentPageVM {
  @Trace submitPageModel: SubmitCommentModel = new SubmitCommentModel();
  @Trace hotelList: ShopItem[] = [];
  @Trace hotelLabelList: string[] = [];
  @Trace checkedHotel: ShopItem | null = null;
  private static _instance: SubmitCommentPageVM;

  public static get instance() {
    if (!SubmitCommentPageVM._instance) {
      SubmitCommentPageVM._instance = new SubmitCommentPageVM();
    }
    return SubmitCommentPageVM._instance;
  }

  public resetData() {
    this.submitPageModel = new SubmitCommentModel();
    this.checkedHotel = null;
  }

  public async getHotelList() {
    if (!this.hotelList.length) {
      const res = await https.getShopListForComment();
      if (res.code === 0) {
        this.hotelList = res.data;
        this.hotelLabelList = this.hotelList.map((item) => item.name);
        if (this.hotelList.length === 1) {
          this.submitPageModel.location = this.hotelList[0].name;
          this.checkedHotel = this.hotelList[0];
        }
      }
    }
  }

  public async getCheckedHotel(name: string) {
    const shopItem: ShopItem | undefined = this.hotelList.find((item) => item.name === name);
    if (shopItem) {
      this.checkedHotel = shopItem;
      this.submitPageModel.location = shopItem.name;
    }
  }

  public async submitComment() {
    const data = this.getSubmitData();
    if (data) {
      https.submitComment(data).then((res) => {
        if (res.code === 0) {
          promptAction.showToast({ message: '提交成功' });
          const timer = setTimeout(() => {
            RouterModule.pop();
            clearTimeout(timer);
          }, 1000);
        }
      });
    }
  }

  public getSubmitData() {
    if (!this.checkedHotel) {
      promptAction.showToast({ message: '请选择门店' });
      return undefined;
    }
    if (!this.submitPageModel.desc) {
      promptAction.showToast({ message: '请输入评论' });
      return undefined;
    }
    // todo: 其他校验
    let userInfo = AccountUtil.getUserInfo();
    const data: SubmitCommentRequest = {
      comment: this.submitPageModel.desc,
      environmentScore: this.submitPageModel.detailRate.environment,
      facilityScore: this.submitPageModel.detailRate.device,
      hotelId: this.checkedHotel.id,
      hotelType: this.checkedHotel.type,
      isAnonymous: this.submitPageModel.isAnonymous,
      overallScore: this.submitPageModel.totalRate,
      recommendScore: this.submitPageModel.detailRate.experience,
      serviceScore: this.submitPageModel.detailRate.service,
      tenantId: AppStorage.get(AppStorageMap.TENANT_ID) as number,
      tourType: this.submitPageModel.arrivalType.label,
      commentTime: FormatUtil.formatFullDate(new Date()),
      hotelName: this.checkedHotel.name,
      userId: userInfo.id,
    };
    return data;
  }
}
