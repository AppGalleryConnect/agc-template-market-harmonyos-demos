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
import { CalculatorVM } from '../viewmodel/CalculatorVM';
import { ScienceCalcKeyboard } from './ScienceCalcKeyboard';
import { BreakpointModel, BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';

@ComponentV2
export struct StandardCalculator {
  @Local text: string = '科学计算器';
  @Local result: string = '0';
  @Local expression: string = '0';
  @Local showResultDialog: boolean = false;
  @Param routerModule: NavPathStack = new NavPathStack();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  scrollerResult: Scroller = new Scroller();
  scrollerExpression: Scroller = new Scroller();

  aboutToAppear(): void {
    CalculatorVM.setStack(this.routerModule);
  }

  build() {
    Column() {
      this.HeaderInfo();
      this.ResultBuilder();
      Column() {
        ScienceCalcKeyboard({
          result: this.result,
          expression: this.expression,
          changeResult: (result, expression) => {
            this.result = result || ' ';
            this.expression = expression;
          },
        });
      }.margin({
        top: new BreakpointModel<number>({
          [BreakpointTypeEnum.LG_WIDE]: 8,
          [BreakpointTypeEnum.LG_NORMAL]: 16,
        }).getValue(this.curBreakpoint.height),
      })
    }
    .padding({ left: 16, right: 16 });
  }

  @Builder
  ResultBuilder() {
    Row() {
      Column() {
        Scroll(this.scrollerExpression) {
          Text(this.expression)
            .textStyle()
            .fontSize(38)
            .onSizeChange(() => {
              this.scrollerExpression.scrollEdge(Edge.End);
            });
        }
        .margin({ bottom: 10 })
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.End)
        .scrollable(ScrollDirection.Horizontal);

        Scroll(this.scrollerResult) {
          Text(this.result)
            .textStyle()
            .fontSize(30).onSizeChange(() => {
            this.scrollerResult.scrollEdge(Edge.End);
          });
        }
        .width('100%')
        .alignSelf(ItemAlign.End)
        .scrollBar(BarState.Off)
        .align(Alignment.End)
        .scrollable(ScrollDirection.Horizontal);
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.End);
    }
    .height(new BreakpointModel<number>({
      [BreakpointTypeEnum.LG_WIDE]: 122,
      [BreakpointTypeEnum.LG_NORMAL]: 181,
    }).getValue(this.curBreakpoint.height))
    .backgroundColor($r('sys.color.background_tertiary'))
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16,
    })
    .borderRadius(16)
    .width('100%')
  }

  @Builder
  HeaderInfo() {
    Row() {
      Row() {
        Image($r('app.media.ic_calculations_record')).height(24).width(24)
          .onClick(() => {
            this.routerModule.pushPathByName('ScienceCalcHistoryResult', null);
          });
      }
      .width(40)
      .height(40)
      .borderRadius('50%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .height(60)
    .padding({ top: 10, bottom: 10 });
  }
}

@Extend(Text)
function textStyle() {
  .fontColor($r('sys.color.font_primary'))
  .maxLines(1);
}
