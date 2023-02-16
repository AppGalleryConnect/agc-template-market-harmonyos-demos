/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import Logger from '@ohos.hilog';
import prompt from '@ohos.promptAction';
import { OrderModel, AttrModel, SelectKeys } from '../../model';
import { Request, RequestType, Auth, Triggers } from '../../api';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.GoodDetail')).toString();

@Entry
@Component
struct GoodDetail {
  @State value: number = 1;
  @State panelShow: boolean = false;
  @State InstantBuyList: Array<OrderModel> = [];
  @State selectTags: SelectKeys = {};
  @State selectData: Array<AttrModel> = [];
  @State selectCount: number = 0;
  @State totalSelectCount: number = 0;
  @State @Watch('onSelectKeysChange') selectKeys: SelectKeys = {};
  @State marginTop: number = 100;
  @State hasDefaultAddress: boolean = false;
  private panelHeight: number = 60;
  private goodItem;
  private userId;
  private token;
  private panelIndex = 3;

  @Styles addButton(){
    .width(Constants.BUTTON_WIDTH)
    .backgroundColor(Color.Orange)
  }

  @Styles image(){
    .width($r('app.float.img_minor'))
    .height($r('app.float.img_minor'))
  }

  @Styles flex(){
    .width(Constants.WIDTH_FULL)
    .backgroundColor(Color.White)
    .padding($r('app.float.padding_small'))
    .borderRadius($r('app.float.border_radius_small'))
  }

  getToken(user) {
    return user.getToken(false).then(token => {
      this.token = token.getString();
    });
  }

  aboutToAppear() {
    this.goodItem = router.getParams()['goodData'];
    this.totalSelectCount = JSON.parse(this.goodItem.attr_list).length;

    Auth.getAuthUser().then(async (res) => {
      if (res == null) {
        Logger.info(domain, TAG, "user has not login");
      } else {
        this.userId = res.getUid();
        await this.getToken(res);
        Logger.info(domain, TAG, "userId is " + this.userId);
      }
    })
  }

  async onPageShow() {
    const res = await Request.invokeWithToken(Triggers.Address, this.token, RequestType.DefaultQuery, {
      "uid": this.userId
    });
    if (res.length) {
      this.hasDefaultAddress = true;
    }
  }

  routerByLoginStates() {
    router.push({
      url: 'pages/Login'
    })
  }

  onShowChange() {
    if (this.panelShow) {
      this.marginTop = 100 - this.panelHeight
    } else {
      this.marginTop = 100
    }
  }

  onSelectKeysChange() {
    this.selectTags = { ...this.selectKeys }
    Logger.info(domain, TAG, "attr list is " + this.selectTags);
  }

  onTagSelect(key, value) {
    if (!this.selectTags[key]) {
      this.selectCount++;
    }
    this.selectTags[key] = value;
    Logger.info(domain, TAG, "the selectCount is " + this.selectCount);
  }

  async InsertShopCartRecord() {
    this.selectData = []
    return await Request.invokeWithToken(Triggers.ShopCart, this.token, RequestType.Insert, {
      "spu_id": this.goodItem.spu_id,
      "sc_id": Date.now(),
      "uid": this.userId,
      "quantity": this.value,
      "spu_attrs": this.getSelectedData()
    });
  }

  async addIntoShopcart() {
    if (!this.userId) {
      this.routerByLoginStates();
    } else {
      if (!this.checkSelectParams()) {
        return;
      }

      const promise = this.InsertShopCartRecord()

      promise.then(() => {
        this.panelShow = false;
        prompt.showToast({ message: $r('app.string.shopCart_add_success') })
      }).catch((err) => {
        Logger.error(domain, TAG, "insert shopCartRecord failed " + JSON.stringify(err))
      })
    }
  }

  onPageHide() {
    this.InstantBuyList = []
    this.selectData = []
  }

  buyInstantly() {
    if (!this.userId) {
      this.routerByLoginStates();
    } else {
      if (!this.checkSelectParams()) {
        return;
      }

      // 将选择商品清空
      this.selectData = [];

      this.InstantBuyList.push({
        order_id: Date.now(),
        uid: this.userId,
        spu_id: this.goodItem.spu_id,
        spu_num: this.value,
        status: 0,
        amount: this.value * this.goodItem.price,
        name: this.goodItem.name,
        desc: this.goodItem.desc,
        pic_url: this.goodItem.pic_url,
        spu_attrs: this.getSelectedData(),
        create_time: new Date(),
        update_time: new Date(),
        price: this.goodItem.price
      });

      router.push({
        url: 'pages/ConfirmOrder',
        params: {
          orderData: this.InstantBuyList,
          settleMent: this.value * this.goodItem.price,
          userId: this.userId,
          token: this.token,
          hasDefaultAddress: this.hasDefaultAddress
        }
      })
    }
  }

  routeByShopCartIcon() {
    if (!this.userId) {
      this.routerByLoginStates();
    } else {
      router.push({
        url: 'pages/Main',
        params: {
          index: 1
        }
      })
    }
  }

  routeByMainIcon() {
    router.push({
      url: 'pages/Main'
    })
  }

  getSelectedData() {
    for (let key in this.selectTags) {
      let selectSnapShot: AttrModel = {
        "name": key,
        "value": this.selectTags[key]
      }
      this.selectData.push(selectSnapShot)
    }
    return JSON.stringify(this.selectData)
  }

  checkSelectParams() {
    if (!this.panelShow) {
      this.panelShow = true
      return false
    } else {
      if (this.selectCount < this.totalSelectCount) {
        prompt.showToast({ message: $r('app.string.shopCart_select_firstly'), duration: 1000 })
        return false
      }
    }
    return true
  }

  @Builder SpecificationPanel() {
    Column({ space: 12 }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.End }) {
          Image(`${this.goodItem.pic_url}`)
            .width($r('app.float.img_large'))
            .height($r('app.float.img_large'))
            .objectFit(ImageFit.Contain)
          Row() {
            Text("￥").fontSize($r('app.float.gooddetail_price_font')).fontColor(Color.Red)
            Text(`${this.goodItem.price.toFixed(2)}`)
              .fontSize($r('app.float.gooddetail_price_font'))
              .fontColor(Color.Red)
          }
        }

        Row() {
          Text("x").fontSize($r('app.float.gooddetail_close_font')).onClick(() => {
            this.panelShow = false
          }).margin({ right: $r('app.float.margin_right_middle') })
        }.alignItems(VerticalAlign.Top)
      }

      Divider().color(Color.Gray).width(Constants.WIDTH_FULL);

      ForEach(JSON.parse(this.goodItem.attr_list), ele1 => {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
          Text(`${ele1.name}`).fontSize($r('app.float.font_large'))
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(ele1.value, i => {
              Text(`${i}`)
                .padding({
                  top: $r('app.float.padding_small'),
                  bottom: $r('app.float.padding_small'),
                  left: $r('app.float.padding_middle'),
                  right: $r('app.float.padding_middle')
                })
                .fontSize($r('app.float.font_middle'))
                .fontColor(this.selectTags[ele1?.name] === i ? Color.Orange : Color.Black)
                .backgroundColor('rgba(200, 200, 200, 0.3)')
                .margin({ bottom: $r('app.float.margin_bottom_large'), right: $r('app.float.margin_right_middle') })
                .border({
                  color: this.selectTags[ele1?.name] === i ? Color.Orange : 'rgba(200, 200, 200, 0)',
                  radius: 4,
                  width: 1
                })
                .onClick(() => this.onTagSelect(ele1.name, i))
            })
          }.margin({ top: $r('app.float.margin_top_small') })
        }.height(Constants.ADDRESS_TEXT_HIGH).margin({ left: $r('app.float.setting_margin_left') })
      })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r('app.string.shopCart_add_number')).fontSize($r('app.float.title_font'))
        Counter() {
          Text(`${this.value}`)
            .fontSize($r('app.float.font_small'))
        }.margin({ right: $r('app.float.margin_right_large') })
        .onInc(() => {
          this.value++
        })
        .onDec(() => {
          if (this.value <= 1) {
            this.value = 1
          } else {
            this.value--
          }
        })
      }.margin({ left: $r('app.float.setting_margin_left') })

      Row({ space: 10 }) {
        Button($r('app.string.shopCart_addIntoShopCart')).width(Constants.DETAIL_BUTTON_WIDTH).onClick(() => {
          this.addIntoShopcart()
        }).backgroundColor(Color.Orange).fontWeight(FontWeight.Medium)
        Button($r('app.string.shopCart_buyInstant')).width(Constants.DETAIL_BUTTON_WIDTH).onClick(() => {
          this.buyInstantly()
        }).backgroundColor(Color.Red).fontWeight(FontWeight.Medium)
      }.justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center)
    }
    .backgroundColor(Color.White)
    .height(Constants.HIGH_HALF)
    .width(Constants.HIGH_FULL)
    .zIndex(this.panelIndex)
    .borderRadius($r('app.float.border_radius_small'))
    .padding({ top: $r('app.float.margin_top_middle') })
    .position({ x: 0, y: Constants.HIGH_HALF })
  }

  @Builder Detail() {
    Scroll() {
      Column() {
        Flex({ direction: FlexDirection.Column }) {
          Swiper() {
            Image(`${this.goodItem.pic_url}`).objectFit(ImageFit.Contain)
          }
          .backgroundColor(Color.White)
          .aspectRatio(1)
          .onChange((index: number) => {
            Logger.info(domain, TAG, index.toString())
          })

          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
            Text(`￥${this.goodItem.price.toFixed(2)}`)
              .fontSize($r('app.float.font_large'))
              .fontColor(Color.Red)
              .margin({ left: $r('app.float.margin_left_small') })
              .align(Alignment.Start)
            Text(`【${this.goodItem.name}】${this.goodItem.desc}`)
              .fontSize($r('app.float.font_large'))
              .margin({ left: $r('app.float.margin_left_small') })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .align(Alignment.Start)
          }.height(Constants.ADDRESS_TEXT_HIGH).width('100%')
        }.backgroundColor(Color.White).borderRadius($r('app.float.border_radius_small'))

        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Text($r('app.string.shopCart_select'))
            .fontSize($r('app.float.font_small'))
            .fontColor(Color.Gray)
            .width(Constants.ADDRESS_TEXT_HIGH)
            .margin({ left: $r('app.float.margin_left_small') })
            .textAlign(TextAlign.Center)
            .alignSelf(ItemAlign.Start)
            .margin({ top: $r('app.float.margin_top_middle') })

          Flex({
            alignContent: FlexAlign.SpaceBetween,
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.Center
          }) {
            ForEach(JSON.parse(this.goodItem.attr_list), ele => {
              Flex({ alignContent: FlexAlign.SpaceAround }) {
                Text(`${ele.name}`).fontSize($r('app.float.font_large'))
                Text(`共${ele.value.length}种${ele.name}可选`)
                  .fontSize($r('app.float.font_large'))
                  .margin({ left: $r('app.float.margin_left_large') })
                  .fontColor(Color.Gray)
                Text('>').fontSize($r('app.float.font_large')).textAlign(TextAlign.End)
              }.onClick(() => {
                this.panelShow = !this.panelShow
              })
              .margin({ top: $r('app.float.margin_top_small') })
            })
          }.margin({ left: $r('app.float.margin_left_middle') })
        }
        .height(Constants.ADDRESS_TEXT_HIGH)
        .margin({ top: $r('app.float.margin_top_middle') })
        .flex()

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
          Text($r('app.string.shopCart_detail')).fontSize($r('app.float.title_font'))

          Image(`${this.goodItem.pic_url}`)
            .width(Constants.WIDTH_FULL)
            .height(400)
            .margin({ top: $r('app.float.margin_top_small') })
        }
        .width(Constants.WIDTH_FULL)
        .margin({ top: $r('app.float.margin_top_middle') })
        .backgroundColor(Color.White)
        .padding($r('app.float.padding_small'))
        .borderRadius($r('app.float.border_radius_small'))
      }.padding({ bottom: $r('app.float.gooddetail_padding') })
    }
    .width(Constants.WIDTH_FULL)
    .height(Constants.HIGH_FULL)
    .onClick(() => {
      this.panelShow = false
    }).zIndex(0)
  }

  @Builder Behavior() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Image($r('app.media.home'))
          .image()
        Text($r('app.string.home'))
          .fontSize($r('app.float.font_small')).fontColor(Color.Gray)
      }.onClick(() => {
        this.routeByMainIcon();
      }).margin({ left: $r('app.float.margin_left_middle') }).width(Constants.GOODDETAIL_TEXT_WIDTH)

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Image($r('app.media.tab_cart'))
          .image()
        Text($r('app.string.shopCart'))
          .fontSize($r('app.float.font_small')).fontColor(Color.Gray)
      }.margin({ left: $r('app.float.margin_left_small') }).onClick(() => {
        this.routeByShopCartIcon();
      }).width(Constants.GOODDETAIL_TEXT_WIDTH)

      Flex({ justifyContent: FlexAlign.End }) {
        Button($r('app.string.shopCart_addIntoShopCart'), { type: ButtonType.Capsule })
          .onClick(() => {
            this.addIntoShopcart();
          })
          .fontSize($r('app.float.font_middle'))
          .fontWeight(FontWeight.Bold)
          .height(Constants.BUTTON_HIGH)
          .addButton()

        Button($r('app.string.shopCart_buyInstant'), { type: ButtonType.Capsule })
          .width(Constants.BUTTON_WIDTH)
          .fontSize($r('app.float.font_middle'))
          .fontWeight(FontWeight.Bold)
          .height(Constants.BUTTON_HIGH)
          .onClick(() => {
            this.buyInstantly();
          })
          .margin({ left: $r('app.float.margin_left_middle'), right: $r('app.float.margin_right_middle') })
          .backgroundColor(Color.Red)
      }.flex()
    }.height(Constants.SETTINGITEM_HIGH).zIndex(1).position({ x: 0, y: '94%' }).backgroundColor(Color.White)
  }

  build() {
    Column() {
      Stack() {
        this.Detail()

        Image($r('app.media.back'))
          .objectFit(ImageFit.Contain)
          .position({ x: Constants.BACK_POSITION, y: Constants.BACK_POSITION })
          .zIndex(2)
          .image()
          .onClick(() => router.back())

        this.Behavior()

        if (this.panelShow) {
          this.SpecificationPanel()
        }
      }.width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL)
    }.width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL).backgroundColor($r('app.color.page_background'))
  }
}