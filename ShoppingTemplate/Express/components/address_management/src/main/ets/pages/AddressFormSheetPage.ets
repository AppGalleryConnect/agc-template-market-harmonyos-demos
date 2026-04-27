import { common } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { sceneMap, site } from '@kit.MapKit';
import { shippingAddress } from '@kit.AccountKit';
import { PromptAction, UIContext } from '@kit.ArkUI';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { AddressFormSheetContext } from '../viewmodels/AddressFormSheetContext';
import { Operation, ShippingAddressErrorCode } from '../common/CustomTypes';
import { FormInputItem } from '../components/FormInputItem';
import { WindowListener } from '../utils/WindowListener';
import { LoadingMask } from '../utils/LoadingMask';
import { TextParser } from '../utils/TextParser';
import { ParsedAddressDTO } from '../models/ParsedAddressDTO';
import { AddressDTO } from '../models/AddressDTO';
import { RecognitionButton } from '../components/RecognitionButton';
import { AddressRecognitionUtil } from '../utils/AddressRecognitionUtil';

@ComponentV2
export struct AddressFormSheetPage {

  @Require @Param
  public ctx: AddressFormSheetContext;

  @Local
  private clipboardText: string = '';

  @Local
  private isResolvingClipboardText: boolean = false;

  @Local
  private isChoosingLocation: boolean = false;

  @Local
  private isSelectingDistrict: boolean = false;

  @Local
  private isSelectingAddress: boolean = false;

  @Local
  private isSaving: boolean = false;

  // 图片识别
  @Local showImgSheet: boolean = false;

  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  @Computed
  private get isProcessing(): boolean {
    return this.isResolvingClipboardText ||
    this.isChoosingLocation ||
    this.isSelectingDistrict ||
    this.isSelectingAddress ||
    this.isSaving;
  }

  private uiContext: UIContext = this.getUIContext();

  private abilityContext: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext;

  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  private formatNational: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat('CN', { type: 'NATIONAL' });

  private systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();

  private listener: WindowListener = new WindowListener(this.abilityContext);

  private loadingMask: LoadingMask = new LoadingMask(this.uiContext);

  public aboutToAppear(): void {
    this.listener.start();
  }

  public aboutToDisappear(): void {
    this.listener.stop();
  }

  public build(): void {
    Column() {
      /**
       * 模态窗标题栏
       */
      Row() {
        Text(this.ctx.title)
          .layoutWeight(1)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Button() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(18)
            .fontColor([$r('sys.color.icon_primary')])
            .fontWeight(FontWeight.Normal)
            .renderingStrategy(SymbolRenderingStrategy.SINGLE)
        }
        .width(40)
        .height(40)
        .type(ButtonType.Circle)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => this.ctx.onWillDismiss(DismissReason.CLOSE_BUTTON, this.ctx.address.hasChanges()))
      }
      .width('100%')
      .height(56)
      .margin({ top: 8 })
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          /**
           * 表单编辑区
           */
          Column() {
            Column() {
              this.buildAddressParseInput()
              FormInputItem({
                text: this.ctx.address.name,
                title: '姓名',
                placeholder: '请输入',
                maxLength: 20,
                onChange: (value: string) => this.ctx.address.name = value,
                isFocusable: !this.isProcessing
              })
              FormInputItem({
                text: this.ctx.address.phone,
                title: '手机号码',
                placeholder: '请输入11位手机号码',
                maxLength: 11,
                type: TextAreaType.NUMBER,
                onChange: (value: string) => this.ctx.address.phone = value,
                isFocusable: !this.isProcessing
              })
              FormInputItem({
                text: this.ctx.address.region,
                title: '选择地区',
                placeholder: '省、市、区',
                isFocusable: false,
                onTextClick: () => this.handleSelectDistrict(),
                onChange: (value: string) => {
                  this.handleAutoFillRegin(value)
                }
              }) {
                this.buildLocationChooseButton()
              }

              FormInputItem({
                text: this.ctx.address.detail,
                title: '详细地址',
                placeholder: '街道、门牌号、小区楼栋号等',
                maxLength: 50,
                onChange: (value: string) => this.ctx.address.detail = value,
                isFocusable: !this.isProcessing
              })
            }
            .width('100%')
            .padding({ top: 12, bottom: 16 })
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))

            Row() {
              Text('设为默认地址')
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .padding({ top: 14, bottom: 14 })
              Toggle({ type: ToggleType.Switch, isOn: this.ctx.address.isDefault })
                .onChange((isOn: boolean) => this.ctx.address.isDefault = isOn)
            }
            .width('100%')
            .margin({ top: 12, bottom: 12 })
            .padding({ left: 12, right: 12 })
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .justifyContent(FlexAlign.SpaceBetween)
          }

          /**
           * 按钮交互区
           */
          Column() {
            Button('保存')
              .width('100%')
              .height(40)
              .margin({ bottom: 12 })
              .onClick(async () => {
                if (!this.isProcessing && this.verify()) {
                  this.uiContext.getFocusController().clearFocus();
                  if (!this.ctx.address.hasChanges()) {
                    this.ctx.close();
                    return;
                  }
                  this.isSaving = true;
                  this.loadingMask.show();
                  try {
                    const address: AddressDTO = this.ctx.address.toDTO();
                    if (this.ctx.operation === Operation.CREATE) {
                      if (this.ctx.controller.onAddAddress) {
                        await this.ctx.controller.onAddAddress(address);
                      }
                    } else {
                      if (this.ctx.controller.onModifyAddress) {
                        await this.ctx.controller.onModifyAddress(address);
                      }
                    }
                    this.ctx.onAddressListUpdate();
                    this.ctx.close();
                  } catch (e) {
                    this.showErrorToast(e);
                  } finally {
                    this.isSaving = false;
                    this.loadingMask.hide();
                  }
                }
              })
            Button() {
              Row() {
                if (this.isSelectingAddress) {
                  LoadingProgress()
                    .width(24)
                    .height(24)
                    .margin({ right: 5 })
                }
                Text('从华为账号导入')
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              }
            }
            .width('100%')
            .height(40)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .margin({ bottom: 12 })
            .stateEffect(!this.isSelectingAddress)
            .opacity(this.isSelectingAddress ? 0.4 : 1)
            .onClick(() => this.handleSelectAddress())
          }
          .padding(this.ctx.sheetType === SheetType.BOTTOM ?
            { bottom: this.listener.avoidArea.bottom + 'px' } : {}
          )
        }
        .constraintSize({ minHeight: '100%' })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .height('100%')
    .width('100%')
    .opacity(this.isSaving ? 0.4 : 1)
  }

  @Builder
  private buildLocationChooseButton(): void {
    if (this.isSelectingDistrict || this.isChoosingLocation) {
      Row() {
        LoadingProgress()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      Button() {
        SymbolGlyph($r('sys.symbol.local'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_secondary')])
      }
      .width('100%')
      .height('100%')
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .onClick(async () => {
        if (this.isProcessing) {
          return;
        }
        this.uiContext.getFocusController().clearFocus();
        this.isChoosingLocation = true;
        try {
          const options: sceneMap.LocationChoosingOptions = {
            searchEnabled: true,
            showNearbyPoi: true,
            cancelCallback: () => this.isChoosingLocation = false
          };
          const result: sceneMap.LocationChoosingResult = await sceneMap.chooseLocation(this.abilityContext, options);
          const site: site.AddressComponent | undefined = result.addressComponent;
          if (
            site &&
            site.countryCode &&
            site.countryName &&
            site.adminLevel1 &&
            site.adminLevel2 &&
            site.adminLevel3 &&
            result.address.includes(site.adminLevel3)
          ) {
            this.ctx.address.countryCode = site.countryCode;
            this.ctx.address.country = site.countryName;
            this.ctx.address.province = site.adminLevel1;
            this.ctx.address.city = site.adminLevel2;
            this.ctx.address.district = site.adminLevel3;
            this.ctx.address.street = site.adminLevel4 ?? '';
            let detail: string = this.trimPrefixes(result.address, [
              this.ctx.address.country,
              this.ctx.address.province,
              this.ctx.address.city,
              this.ctx.address.district,
              this.ctx.address.street
            ]);
            const name: string = result.name && !result.address.includes(result.name) ? result.name : '';
            if (name.includes(detail)) {
              detail = name;
            } else {
              detail = detail + name;
            }
            if (detail) {
              this.ctx.address.detail = detail;
            }
          } else {
            this.promptAction.showToast({ message: '所选地区信息不够详细' });
          }
        } catch (e) {
          this.showErrorToast(e);
        } finally {
          this.isChoosingLocation = false;
        }
      })
    }
  }

  @Builder
  private buildAddressParseInput(): void {
    Column() {
      Column() {
        Row() {
          TextInput({ text: this.clipboardText, placeholder: '粘贴文本到此处，将自动识别地址信息' })
            .layoutWeight(1)
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Regular)
            .maxLength(120)
            .showCounter(false)
            .barState(BarState.Off)
            .onChange((value: string) => this.clipboardText = value)
            .borderWidth(0)
            .borderRadius(0)
            .padding(0)
            .margin({ bottom: 8 })
            .backgroundColor(Color.Transparent)
            .focusable(!this.isProcessing)

          if (this.clipboardText) {
            SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_tertiary')])
              .onClick(() => this.clipboardText = '')
          }
        }
        .width('100%')
        .height(50)
        .alignItems(VerticalAlign.Top)


        Row() {
          RecognitionButton({
            symbolResource: $r('sys.symbol.picture'),
            label: '图片识别',
            clickAction: () => {
              this.showImgSheet = true;
            }
          })
            .bindSheet($$this.showImgSheet, this.builderImgMenus(), {
              height: 160,
              backgroundColor: Color.White,
              showClose: false,
              preferType: SheetType.BOTTOM,
            });

          RecognitionButton({
            symbolResource: $r('sys.symbol.mic'),
            label: '语音识别',
            clickAction: () => {
              AddressRecognitionUtil.speechRecognition(
                this.getUIContext(),
                (text: string) => {
                  this.clipboardText = text.replace('。', '');
                },
                () => {
                  this.autofillAddress();
                },
                () => {
                  this.isResolvingClipboardText = true;
                }
              )
            }
          }).margin({ left: 12 })

          Blank()

          if (this.clipboardText || this.isResolvingClipboardText) {
            Button() {
              if (this.isResolvingClipboardText) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color($r('sys.color.icon_on_primary'))
              } else {
                Text('识别')
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
              }
            }
            .size({ width: 72, height: 28 })
            .type(ButtonType.ROUNDED_RECTANGLE)
            .onClick(() => {
              if (this.isProcessing || !this.clipboardText.trim()) {
                return;
              }
              this.autofillAddress();
            })
          } else {
            PasteButton({
              text: PasteDescription.PASTE,
              buttonType: ButtonType.Normal,
            })
              .width(72)
              .height(28)
              .borderRadius(14)
              .fontSize($r('sys.float.Body_M'))
              .onClick((_: ClickEvent, result: PasteButtonOnClickResult) => {
                try {
                  if (!this.isResolvingClipboardText && this.systemPasteboard.hasDataSync()) {
                    const data: pasteboard.PasteData = this.systemPasteboard.getDataSync();
                    const text = data.getPrimaryText();
                    if (text) {
                      this.clipboardText = text;
                      // 识别地址并填充
                      this.autofillAddress();
                    } else if (result !== PasteButtonOnClickResult.SUCCESS) {
                      this.getUIContext().getFocusController().clearFocus();
                      this.showErrorToast('Failed to obtain temporary clipboard permission.');
                    }
                  }
                } catch (e) {
                  this.showErrorToast(e);
                }
              })
          }
        }
        .width('100%')
        .hitTestBehavior(this.isProcessing ? HitTestMode.Block : HitTestMode.Default)
      }
      .borderRadius(16)
      .padding({ top: 8, bottom: 8, right: 8, left: 12 })
      .margin({ bottom: 12 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .padding({ right: 12, left: 12 })
  }

  @Builder
  sheetMenuItem(label: string, action: () => void) {
    Text(label)
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor($r('sys.color.font_primary'))
      .padding(4)
      .onClick(() => {
        action();
        this.showImgSheet = false;
      })
  }

  @Builder
  builderImgMenus() {
    Column({ space: 12 }) {
      this.sheetMenuItem('拍照', () => {
        this.showImgSheet = false;
        AddressRecognitionUtil.takePhoto(this.context, () => {
          this.isResolvingClipboardText = true;
        }).then((resp) => {
          if (resp) {
            this.clipboardText = resp;
            this.autofillAddress();
          }
        })
      })

      this.sheetMenuItem('从相册中选择', () => {
        this.showImgSheet = false;
        AddressRecognitionUtil.imagePicker().then((resp) => {
          if (resp) {
            this.clipboardText = resp;
            this.autofillAddress();
          }
        })
      })

      Row().width('100%').height(6).backgroundColor($r('sys.color.comp_background_tertiary'))

      this.sheetMenuItem('取消', () => {
        this.showImgSheet = false;
      })
    }
    .width('100%')
    .padding({ top: 12, bottom: 24 })
  }

  private autofillAddress() {
    this.uiContext.getFocusController().clearFocus();
    this.isResolvingClipboardText = true;
    TextParser.parseAddress(this.clipboardText)
      .then((result: ParsedAddressDTO) => {
        let isSuccess: boolean = false;
        if (result.name) {
          this.ctx.address.name = result.name;
          isSuccess = true;
        }
        if (result.phone) {
          this.ctx.address.phone = result.phone;
          isSuccess = true;
        }
        if (result.hasCompleteLocation()) {
          this.ctx.address.countryCode = result.countryCode;
          this.ctx.address.country = result.country;
          this.ctx.address.province = result.province;
          this.ctx.address.city = result.city;
          this.ctx.address.district = result.district;
          this.ctx.address.street = result.street;
          this.ctx.address.detail = result.detail;
          isSuccess = true;
        }
        this.promptAction.showToast({ message: isSuccess ? '识别成功' : '识别失败' });
      })
      .catch((e: BusinessError<void>) => this.showErrorToast(e))
      .finally(() => {
        this.isResolvingClipboardText = false;
        TextParser.release();
      });
  }

  private handleSelectDistrict(): void {
    if (this.isProcessing) {
      return;
    }
    this.uiContext.getFocusController().clearFocus();
    this.isSelectingDistrict = true;
    // 当前 selectDistrict 在某些特殊情况下不会产生任何回调，因此 1 秒后无条件还原状态变量
    const timeoutId: number = setTimeout(() => this.isSelectingDistrict = false, 1000);
    const options: sceneMap.DistrictSelectOptions = {
      countryCode: 'CN',
      language: 'zh',
      cancelCallback: () => {
        clearTimeout(timeoutId);
        this.isSelectingDistrict = false;
      }
    };
    sceneMap.selectDistrict(this.getUIContext().getHostContext(), options)
      .then((result: sceneMap.DistrictSelectResult) => {
        this.ctx.address.clearRegion();
        for (let district of result.districts) {
          switch (district.adminLevel) {
            case 'COUNTRY':
              this.ctx.address.countryCode = district.countryCode ?? '';
              this.ctx.address.country = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_1':
              this.ctx.address.province = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_2':
              this.ctx.address.city = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_3':
              this.ctx.address.district = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_4':
              this.ctx.address.street = district.name ?? '';
              break;
          }
        }
      })
      .catch((e: BusinessError<void>) => this.showErrorToast(e))
      .finally(() => {
        clearTimeout(timeoutId);
        this.isSelectingDistrict = false;
      });
  }

  private async handleAutoFillRegin(value: string) {
    // 如果输入值为空，则直接返回
    if (!value) {
      return
    }
    // 获取当前地址中的地区信息
    const curentRegin = this.ctx.address.region;
    // 如果当前地区信息与输入值相同，则直接返回，避免重复处理
    if (curentRegin === value) {
      return
    }
    // 设置地区选择状态为进行中
    this.isSelectingDistrict = true;
    try {
      // 检查地理编码服务是否可用
      let isAvailable = geoLocationManager.isGeocoderAvailable();
      // 如果地理编码服务可用，则执行地址解析
      if (isAvailable) {
        // 获取结构化地址
        const results = await geoLocationManager.getAddressesFromLocationName({
          description: value,
          maxItems: 1
        });
        // 如果获取到地址结果，则进行信息填充
        if (results.length > 0) {
          // 清空当前地址中的地区信息
          this.ctx.address.clearRegion();
          // 获取第一个地址结果
          const info = results[0];
          // 填充国家代码，如果不存在则默认为'CN'
          this.ctx.address.countryCode = info.countryCode ?? 'CN';
          // 填充国家名称，如果不存在则默认为'中国'
          this.ctx.address.country = info.countryName ?? '中国';
          // 如果存在行政区域信息，则填充省份
          if (info.administrativeArea) {
            this.ctx.address.province = info.administrativeArea;
          }
          // 如果存在本地化信息，则填充城市
          if (info.locality) {
            this.ctx.address.city = info.locality;
          }
          // 如果存在子本地化信息，则填充区县
          if (info.subLocality) {
            this.ctx.address.district = info.subLocality;
          }

          this.isSelectingDistrict = false;
        } else {
          this.autoFillParseAddress(value)
        }
      } else {
        this.autoFillParseAddress(value)
      }
    } catch (e) {
      this.autoFillParseAddress(value)
      UtilLog.error('[AddressFormSheetPage]',  `handleAutoFillRegin failed. error: ${JSON.stringify(e)}`)
    }
  }

  // 智能填充解析地址
  private async autoFillParseAddress(value: string) {
    // 通过文本识别出所在地区
    const result = await TextParser.parseAddress(value);
    // 清空当前地址中的地区信息
    this.ctx.address.clearRegion();
    // 填充国家代码，如果不存在则默认为'CN'
    this.ctx.address.countryCode = result.countryCode ?? 'CN';
    // 填充国家名称，如果不存在则默认为'中国'
    this.ctx.address.country = result.country ?? '中国';
    // 如果存在行政区域信息，则填充省份
    if (result.province) {
      this.ctx.address.province = result.province;
    }
    // 如果存在本地化信息，则填充城市
    if (result.city) {
      this.ctx.address.city = result.city;
    }
    // 如果存在子本地化信息，则填充区县
    if (result.district) {
      this.ctx.address.district = result.district;
    }
    this.isSelectingDistrict = false;
    TextParser.release();
  }

  private handleSelectAddress(): void {
    if (this.isProcessing) {
      return;
    }
    this.isSelectingAddress = true;
    this.getUIContext().getFocusController().clearFocus();
    shippingAddress.chooseAddress(this.getUIContext().getHostContext())
      .then((info: shippingAddress.AddressInfo) => {
        // 根据官方文档，当前收货地址仅支持中国境内
        this.ctx.address.countryCode = 'CN';
        this.ctx.address.country = '中国';
        this.ctx.address.name = info.userName;
        this.ctx.address.phone = this.formatNational.format(info.mobileNumber).replace(/\s+/g, '');
        this.ctx.address.detail = info.detailedAddress ?? '';
        this.ctx.address.province = info.provinceName;
        this.ctx.address.city = info.cityName;
        this.ctx.address.district = info.districtName;
        this.ctx.address.street = info.streetName ?? '';
      })
      .catch((e: BusinessError<void>) => {
        // 用户取消了选址操作
        if (e.code === ShippingAddressErrorCode.USER_CANCELED) {
          return;
        }
        this.showErrorToast(e);
      })
      .finally(() => this.isSelectingAddress = false);
  }

  private verify(): boolean {
    if (!this.ctx.address.name) {
      this.promptAction.showToast({ message: '请输入联系人姓名' });
      return false;
    }
    if (!this.ctx.address.phone) {
      this.promptAction.showToast({ message: '请输入手机号码' });
      return false;
    }
    if (!this.formatNational.isValidNumber(this.ctx.address.phone)) {
      this.promptAction.showToast({ message: '手机号码不正确' });
      return false;
    }
    if (!this.ctx.address.region) {
      this.promptAction.showToast({ message: '请选择所在地区' });
      return false;
    }
    if (!this.ctx.address.district) {
      this.promptAction.showToast({ message: '地区信息不完整' });
      return false;
    }
    if (!this.ctx.address.detail) {
      this.promptAction.showToast({ message: '请输入详细地址' });
      return false;
    }
    return true;
  }

  private trimPrefixes(value: string, prefixes: string[]): string {
    let result: string = value;
    for (const prefix of prefixes) {
      if (result.startsWith(prefix)) {
        result = result.slice(prefix.length);
      }
    }
    return result;
  }

  private showErrorToast(error: ESObject): void {
    let message: string = '';
    if (error.message) {
      if (!error.code && error.code !== 0) {
        message = `error: ${error.message}`;
      } else {
        message = `code: ${error.code}, msg: ${error.message}`;
      }
    } else if (typeof error === 'string') {
      message = `error: ${error}`;
    }
    this.promptAction.showToast({
      message: message ? message : `error: ${JSON.stringify(error)}`,
      backgroundBlurStyle: BlurStyle.NONE,
      backgroundColor: '#FFFF9800',
      textColor: $r('sys.color.font_primary')
    });
  }
}
