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
import {
  CardRecognition,
  CardSide,
  CardType,
  ShootingMode,
  CardRecognitionResult,
} from '@kit.VisionKit';
import { getInstance } from '../util/Route';
import { CardRecognitionPageVM } from '../viewModels/CardRecognitionPageVM';


@Builder
export function CardRecognitionPageBuilder() {
  CardRecognitionPage();
}

@ComponentV2
export struct CardRecognitionPage {
  vm: CardRecognitionPageVM = CardRecognitionPageVM.instance;

  build() {
    NavDestination() {
      Stack() {
        if (canIUse('SystemCapability.AI.Component.CardRecognition')) {
          //身份证
          CardRecognition({
            supportType: CardType.CARD_AUTO,
            // 身份证可双面识别
            cardSide: CardSide.DEFAULT,
            cardRecognitionConfig: {
              defaultShootingMode: ShootingMode.MANUAL,
              isPhotoSelectionSupported: true,
            },
            callback: (res: CardRecognitionResult) => {
              if (res.code !== 200) {
                getInstance().pop();
                this.getUIContext().getPromptAction().showToast({ message: '识别失败！' });
              } else {
                const cardType = res.cardType as CardType;
                const cardInfo = res.cardInfo as Record<string, Record<string, string>>;
                this.vm.handleScanResult(cardType, cardInfo);
              }
            },
          });
        } else {
          Text('设备不支持该功能').fontColor($r('sys.color.font_secondary')).margin({ top: 80 });
        }

      };
    }.hideTitleBar(true);
  }
}
