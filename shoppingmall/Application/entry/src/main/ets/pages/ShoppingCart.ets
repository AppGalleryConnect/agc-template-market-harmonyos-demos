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
import { ShopCartModel, CountKeys, QuantityKeys, OrderModel } from '../../model';
import { Loading, Empty } from '../../components';
import { Request, RequestType, Auth, Triggers } from '../../api';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.ShopCart')).toString();

@Component
export struct ShoppingCart {
  @State isManageState: boolean = true
  @State hasDefaultAddress: boolean = false;
  @Link @Watch("onShopCartListUpdated") shopCartList: Array<ShopCartModel>;
  @State value: number = 1;
  @Link checkedNumber: number;
  @State instantBuyList: Array<OrderModel> = [];
  @State @Watch("onSpuListUpdated") spuListInShopCart: Array<ShopCartModel> = [];
  @Link settleMent: number;
  @Link isLoading: boolean;
  @State isAllChecked: boolean = false;
  @State @Watch("countKeysUpdate") countKeys: CountKeys = {};
  @Link @Watch("quantityUpdate") quantityKeys: QuantityKeys;
  @State isRefreshing: boolean = false;
  @State @Watch("selectUpdate") selectProducts: Array<boolean> = [];
  private userId;
  private token;

  @Styles button(){
    .margin({ right: $r('app.float.margin_right_middle') })
    .width(Constants.BUTTON_WIDTH)
    .height(Constants.BUTTON_HIGH)
  }

  getToken(user) {
    return user.getToken(false).then(token => {
      this.token = token.getString();
    });
  }

  aboutToAppear() {
    Auth.getAuthUser().then(async (res) => {
      if (res) {
        this.userId = res.getUid();
        await this.getToken(res);
        this.getDefaultAddress();
        Logger.info(domain, TAG, "shopcart has been prepared");
      } else {
        Logger.info(domain, TAG, "user has not login in shopCart page");
        router.push({
          url: 'pages/Login'
        })
      }
    })
  }

  async getDefaultAddress() {
    const res = await Request.invokeWithToken(Triggers.Address, this.token, RequestType.DefaultQuery, {
      "uid": this.userId
    });
    if (res.length) {
      this.hasDefaultAddress = true;
    }
  }

  loadShopCartData() {
    Request.invokeWithToken(Triggers.ShopCart, this.token, RequestType.Query, { "uid": this.userId }).then(res => {
      this.shopCartList = res
      this.shopCartList.sort((a, b) => +b.sc_id - +a.sc_id)
      this.shopCartList.forEach((item) => {
        if (item.selected === 1) {
          this.settleMent += item.quantity * item.price;
          this.checkedNumber++;
        }
        this.quantityKeys[item.sc_id] = item.quantity
      })
      Logger.info(domain, TAG, "obtain shopcartList success " + this.shopCartList)
    }).catch((err) => {
      Logger.error(domain, TAG, "obtain shopcartList failed " + JSON.stringify(err));
    })
  }

  checkSpuList() {
    let isSpuSelected = true;
    if (!this.spuListInShopCart.length) {
      AlertDialog.show({
        message: $r('app.string.shopCart_not_selected'),
      })
      isSpuSelected = false;
    }
    return isSpuSelected;
  }

  selectUpdate() {
    this.isAllChecked = this.selectProducts.every(item => item);
  }

  selectUpdateWhenDelete(flag) {
    this.selectProducts = this.shopCartList.map(() => flag);
  }

  onSpuListUpdated() {
    this.getSettleMent();
    Logger.info(domain, TAG, "spuList has updated");
  }

  countKeysUpdate() {
    Logger.info(domain, TAG, "countKeysUpdate has updated");
  }

  quantityUpdate() {
    this.getSettleMent();
    Logger.info(domain, TAG, "quantityUpdate has updated");
  }

  onShopCartListUpdated() {
    Logger.info(domain, TAG, "length of shopcart list is " + this.shopCartList);
  }

  getSettleMent() {
    //每次计算置0
    this.settleMent = 0;
    this.spuListInShopCart.forEach((item) => {
      //以页面的quantityKeys为准
      this.settleMent += item.price * this.quantityKeys[item.sc_id];
      Logger.info(domain, TAG, "settleMent is " + this.settleMent);
    })
    return this.settleMent;
  }

  getScList() {
    let sc_list = [];
    this.spuListInShopCart.forEach((item) => {
      Logger.info(domain, TAG, "spu_id in spuItem is " + item.sc_id);
      sc_list.push((item.sc_id));
    })
    return sc_list;
  }

  deleteShopCardRecords(list) {
    Request.invokeWithToken(Triggers.ShopCart, this.token, RequestType.Delete, { "sc_list": list }).then(res => {
      //选择数量置为空
      this.checkedNumber = 0
      prompt.showToast({ message: `删除成功` })
      Logger.info(domain, TAG, "delete shopcart record " + res)
    }).catch((err) => {
      Logger.error(domain, TAG, "delete shopcart record failed " + JSON.stringify(err));
    })
  }

  updateQuantity(sc_id: number, quantity: number, selected: number) {
    let params = {
      "sc_id": sc_id,
      "quantity": quantity,
      "selected": selected
    }
    Request.invokeWithToken(Triggers.ShopCart, this.token, RequestType.Update, params).then(res => {
      //选择状态刷回
      setTimeout(() => {
        this.countKeys[sc_id] = false;
      }, 2000)
      Logger.info(domain, TAG, "update shopcart record " + res);
    }).catch((err) => {
      Logger.error(domain, TAG, "update shopcart record failed " + JSON.stringify(err));
    })
  }

  onPageHide() {
    this.instantBuyList = [];
  }

  confirmOrder() {
    this.spuListInShopCart.forEach(item => {
      this.instantBuyList.push({
        order_id: Date.now(),
        uid: this.userId,
        spu_id: item.spu_id,
        spu_num: this.quantityKeys[item.sc_id],
        status: 0,
        amount: item.price * this.quantityKeys[item.sc_id],
        name: item.name,
        desc: item.desc,
        pic_url: item.pic_url,
        spu_attrs: item.spu_attrs,
        price: item.price
      });
    })

    router.push({
      url: 'pages/ConfirmOrder',
      params: {
        orderData: this.instantBuyList,
        settleMent: this.settleMent,
        userId: this.userId,
        sc_list: this.getScList(),
        token: this.token,
        hasDefaultAddress: this.hasDefaultAddress
      }
    })
  }

  @Builder Empty() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r('app.media.empty'))
        .width($r('app.float.img_middle'))
        .height($r('app.float.img_middle'))
        .objectFit(ImageFit.Contain)
      Text($r('app.string.shopCart_empty_desc')).fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
    }.width(Constants.WIDTH_FULL)
  }

  @Builder ShopCartHeader() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Text($r('app.string.shopCart'))
          .fontSize($r('app.float.title_font')).margin({ left: $r('app.float.margin_left_middle') })
          .fontWeight(FontWeight.Medium)
        Text(`(${this.shopCartList.length})`).fontSize($r('app.float.font_middle'))
      }.width(Constants.HIGH_HALF)

      if (this.isManageState) {
        Text($r('app.string.shopCart_manage'))
          .fontSize($r('app.float.title_font'))
          .margin({ right: $r('app.float.margin_right_middle') })
          .width(Constants.HIGH_HALF)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.isManageState = false
            Logger.info(domain, TAG, 'current state of shopCart is ' + this.isManageState)
          })
      } else {
        Text($r('app.string.shopCart_exitManage'))
          .fontSize($r('app.float.title_font'))
          .fontColor(Color.Red)
          .margin({ right: $r('app.float.margin_right_middle') })
          .width(Constants.HIGH_HALF)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.isManageState = true
            Logger.info(domain, TAG, 'current state of shopCart is ' + this.isManageState)
          })
      }
    }.height(Constants.SETTINGITEM_HIGH)
  }

  @Builder ShopCartInfo() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Refresh({ refreshing: this.isRefreshing, offset: 120, friction: 100 }) {
        Scroll() {
          List({ space: 10 }) {
            ForEach(this.shopCartList, (item, index) => {
              ListItem() {
                Flex({ direction: FlexDirection.Column }) {
                  Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                    Checkbox({ name: `checkbox${index}`, group: 'checkboxGroup' })
                      .select(!!this.selectProducts[index])
                      .selectedColor(0x39a2db)
                      .onChange((value: boolean) => {
                        this.selectProducts[index] = value;
                        if (value) {
                          //商品id加入购物车list
                          this.spuListInShopCart.push(item);
                          this.checkedNumber++;
                        } else {
                          this.spuListInShopCart = this.spuListInShopCart.filter(ele =>
                          ele.sc_id != item.sc_id
                          )
                          if (this.checkedNumber > 0) {
                            this.checkedNumber--;
                          }
                        }
                        this.isAllChecked = this.spuListInShopCart.length === this.shopCartList.length;
                      })
                    Row() {
                      Image(`${item.pic_url}`)
                        .width($r('app.float.img_large'))
                        .height($r('app.float.img_large'))
                        .aspectRatio(1)
                        .objectFit(ImageFit.Contain)
                        .border({ radius: $r('app.float.border_radius_small') })
                      Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Column }) {
                        Column() {
                          Text(`${item.name}${item.desc}`)
                            .fontSize($r('app.float.font_large'))
                            .fontWeight(FontWeight.Bolder)
                            .width(Constants.HIGH_HALF)
                            .margin({ bottom: $r('app.float.margin_bottom_small') })

                          ForEach(JSON.parse(item.spu_attrs), ele => {
                            Row({ space: 10 }) {
                              Text(`${ele.name}`).fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
                              Text(`${ele.value}`).fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
                            }.margin({ bottom: $r('app.float.margin_bottom_small') })
                          })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ bottom: $r('app.float.margin_bottom_large') })

                        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                          Row() {
                            Text(`￥`).fontSize($r('app.float.font_large')).fontColor(Color.Red)
                            Text(`${item.price.toFixed(2)}`)
                              .fontSize($r('app.float.title_font'))
                              .fontColor(Color.Red)
                              .fontWeight(FontWeight.Medium)
                          }

                          if (!this.countKeys[item.sc_id]) {
                            Text(`x${this.quantityKeys[item.sc_id]}`)
                              .fontSize($r('app.float.font_small'))
                              .padding($r('app.float.padding_small'))
                              .border({ width: 1, radius: 5, color: Color.Grey })
                              .onClick(() => {
                                this.countKeys[item.sc_id] = true;
                              })
                          } else {
                            Counter() {
                              Text(`${this.quantityKeys[item.sc_id]}`)
                                .fontSize($r('app.float.font_spcification'))
                            }
                            .onInc(() => {
                              this.quantityKeys[item.sc_id]++;
                              this.updateQuantity(item.sc_id, this.quantityKeys[item.sc_id], item.selected);
                            })
                            .onDec(() => {
                              if (this.quantityKeys[item.sc_id] <= 1) {
                                this.quantityKeys[item.sc_id] = 1
                              } else {
                                this.quantityKeys[item.sc_id]--
                              }
                              this.updateQuantity(item.sc_id, this.quantityKeys[item.sc_id], item.selected);
                            })
                          }
                        }
                        .width(Constants.WIDTH_TWO_THIRD_FULL)
                      }.margin({ left: $r('app.float.margin_left_middle') })
                    }
                  }
                }
              }
              .width(Constants.WIDTH_FULL)
              .padding($r('app.float.padding_small'))
              .borderRadius($r('app.float.border_radius_small'))
              .backgroundColor(Color.White)
            }, item => item.sc_id)
          }.align(Alignment.Center)
          .edgeEffect(EdgeEffect.None)
          .onScrollIndex((start, end) => {
            Logger.info(domain, TAG, `start=${start},end=${end}`)
          })
        }
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        Logger.info(domain, TAG, 'Refresh onStatueChange state is ' + refreshStatus)
      })
      .onRefreshing(() => {
        this.loadShopCartData();
      })
    }.height(Constants.ADDRESS_HIGH)

    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ alignItems: ItemAlign.Center }) {
        Checkbox({ name: "checkboxgroup" })
          .select(this.isAllChecked)
          .onChange((value) => {
            this.selectUpdateWhenDelete(value);
            if (value) {
              this.spuListInShopCart = this.shopCartList;
              this.checkedNumber = this.spuListInShopCart.length;
            } else {
              this.spuListInShopCart = [];
              this.checkedNumber = 0;
            }
          })
        Text($r('app.string.shopCart_selectAll')).fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
      }

      Flex({ alignItems: ItemAlign.Center }) {
        if (this.isManageState) {
          Flex({ alignItems: ItemAlign.Center }) {
            Text($r('app.string.shopCart_total')).fontSize($r('app.float.font_small'))
            Text(`￥${this.settleMent}`)
              .fontSize($r('app.float.font_middle'))
              .fontColor(Color.Red)
              .fontWeight(FontWeight.Medium)
          }.margin({ right: $r('app.float.margin_right_small') })
        }

        if (this.isManageState) {
          Button(`结算${this.checkedNumber === 0 ? '' : `(${this.checkedNumber})`}`, { type: ButtonType.Capsule })
            .onClick(() => {
              if (!this.checkSpuList()) {
                return
              }

              this.confirmOrder()

              //清空待购物list
              this.onPageHide();
            })
            .fontSize($r('app.float.font_middle'))
            .button()
        } else {
          Button(`删除${this.checkedNumber === 0 ? '' : `(${this.checkedNumber})`}`, { type: ButtonType.Capsule })
            .backgroundColor(Color.Red)
            .onClick(() => {
              if (!this.checkSpuList()) {
                return
              }

              this.selectUpdateWhenDelete(0)

              let sc_list = this.getScList();
              //云数据库删除
              this.deleteShopCardRecords(sc_list);
              //本地删除
              this.shopCartList = this.shopCartList.filter(item => sc_list.indexOf(item.sc_id) === -1);
              //结算金额和购物车置空
              this.settleMent = 0
              this.spuListInShopCart = []
            })
            .button()
        }
      }
    }.height(Constants.SETTINGITEM_HIGH).backgroundColor(Color.White)
  }

  build() {
    Column() {
      this.ShopCartHeader()
      if (!this.shopCartList.length && this.isLoading) {
        Loading()
      } else if (!this.shopCartList.length && !this.isLoading) {
        Empty()
      } else {
        this.ShopCartInfo()
      }
    }
    .width(Constants.WIDTH_FULL)
    .height(Constants.HIGH_FULL)
    .backgroundColor($r('app.color.page_background'))
  }
}
