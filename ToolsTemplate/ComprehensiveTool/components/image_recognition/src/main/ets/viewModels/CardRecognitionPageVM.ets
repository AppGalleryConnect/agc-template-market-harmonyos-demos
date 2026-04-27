/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { CardType } from '@kit.VisionKit';
import { getInstance, RouterMap } from '../util/Route';


@ObservedV2
export class CardRecognitionPageVM {
  @Trace text: string = '';
  private static _instance: CardRecognitionPageVM;

  public static get instance() {
    if (!CardRecognitionPageVM._instance) {
      CardRecognitionPageVM._instance = new CardRecognitionPageVM();
    }
    return CardRecognitionPageVM._instance;
  }

  // 处理扫描结果
  public handleScanResult(cardType: CardType,
    cardInfo: Record<string, Record<string, string>>) {
    let front: Record<string, string>;
    let back: Record<string, string>;
    let main: Record<string, string>;
    switch (cardType) {
      case CardType.CARD_ID:
        front = cardInfo.front;
        back = cardInfo.back;
        this.text = `姓名:${front.name}` + '\n' + `性别:${front.sex}` + '\n' + `民族:${front.nationality}` + '\n' +
          `出生:${front.birth}` + '\n' +
          `住址:${front.address}` + '\n' + `公民身份号码:${front.idNumber}` + '\n' + `签发机关:${back.authority}` +
          '\n' + `有效期限:${back.validPeriod}`;
        break;
      case CardType.CARD_BANK:
        this.text = cardInfo.main.bankNum;
        break;
      case CardType.CARD_PASSPORT:
        main = cardInfo.main;
        this.text =
          `护照号码:${main.cardNum}` + '\n' + `姓名:${main.name}` + '\n' + `性别:${main.sex}` + '\n' +
            `国籍:${main.nationality}` + '\n' + `出生地点:${main.address}` + '\n' +
            `出生日期:${main.birth}` + '\n' + `签发日期:${main.issueDate}` + '\n' + `签发地点:${main.issuePlace}` +
            '\n' + `有效期至:${main.expiryDate}` + '\n' + `签发机关:${main.authority}` +
            '\n' + `${main.pochn}`;
        break;
      case CardType.CARD_DRIVER_LICENSE:
        front = cardInfo.front;
        back = cardInfo.back;
        this.text =
          `证号:${front.cardNum}` + '\n' + `姓名:${front.name}` + '\n' + `性别:${front.sex}` + '\n' +
            `国籍:${front.nationality}` + '\n' + `住址:${front.address}` +
            '\n' + `出生日期:${front.birth}` + '\n' + `初次领证日期:${front.dateOfFirstIssue}` + '\n' +
            `准驾车型:${front.carClass}` + '\n' +
            `有效期限-起始:${front.validPeriodStart}` + '\n' +
            `有效期限-终止:${front.validPeriodEnd}` + '\n' + `证号:${back.cardNum}` + '\n' + `姓名:${back.name}` +
            '\n' + `档案编号:${back.archivesNum}` + '\n' + `记录:${back.record}`;
        break;
      default:
        front = cardInfo.front;
        back = cardInfo.back;
        this.text =
          `号牌号码:${front.licensePlateNumber}` + '\n' + `车辆类型:${front.vehicleType}` + '\n' +
            `所有人:${front.owner}` + '\n' + `住址:${front.address}` + '\n' +
            `使用性质:${front.useCharacter}` + '\n' + `品牌型号:${front.model}` + '\n' + `车辆识别代码:${front.vin}` +
            '\n' + `发动机号码:${front.engineNum}` + '\n' +
            `注册日期:${front.registerDate}` + '\n' + `发证日期:${front.issueDate}` + '\n' +
            `号牌号码:${back.cardNum}` + '\n' + `外廓尺寸:${back.size}` + '\n' + `备注:${back.remark}` +
            '\n' + `检验记录:${back.record}`;
        break;
    }

    this.text = this.text.replaceAll('None', '');

    getInstance().replacePathByName(RouterMap.TEXT_RESULT, this.text);


  }
}