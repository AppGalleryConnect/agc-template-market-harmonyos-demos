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
import { LoginManageUtil, MAX_FREE_USE_TIME, MemberHint, MemberManageUtil, UPDATE_MEMBER_STATUS } from 'module_base';
import { LoginSheetUtils } from 'aggregated_login';
import { TuningPageVM } from '../viewModels/TuningPageVM';
import { NavTitle } from '../components/NavTitle';
import { setPathStack } from '../util/RouteUtil';
import { GuitarTunerTrajectory } from '../components/TunerUI';
import { GuitarInfo } from '../model/Index';

@Builder
export function TuningPageBuilder() {
  TuningPage();
}

@ComponentV2
export struct TuningPage {
  vm: TuningPageVM = TuningPageVM.instance;
  @Local loginManageUtil: LoginManageUtil = new LoginManageUtil(this.getUIContext());

  @Computed
  get isCanUse() {
    return this.vm.isMember || (!this.vm.isMember && this.vm.usedCount.count < MAX_FREE_USE_TIME)
  }

  @Computed
  get isShowHint() {
    if (!this.loginManageUtil.userInfoModel.isLogin) {
      return true;
    } else {
      return this.vm.isMember === false;
    }
  }

  async aboutToAppear(): Promise<void> {
    this.vm.isMember = await MemberManageUtil.queryMemberStatus(this.getUIContext());
    this.getUIContext().getHostContext()!.eventHub.on(UPDATE_MEMBER_STATUS, (status: boolean) => {
      this.vm.isMember = status;
    });
  }

  aboutToDisappear(): void {
    if (!this.vm.isMember) {
      this.vm.usedCount.count += 1;
    }
    this.vm.stopCapture();
    this.vm.releasePool();
    this.getUIContext().getHostContext()!.eventHub.off(UPDATE_MEMBER_STATUS);
  }

  @Builder
  MemberLimit() {
    Column() {
      MemberHint({
        fontColor: $r('sys.color.font_on_primary'),
        bgColor: 'rgba(255,255,255,0.1)',
        btnFontColor: $r('sys.color.multi_color_03'),
        count: this.vm.usedCount.count >= MAX_FREE_USE_TIME ? MAX_FREE_USE_TIME : this.vm.usedCount.count,
      });
    }.padding({ left: 16, right: 16 });
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        NavTitle({ title: '吉他调音器' });

        if (this.isShowHint) {
          this.MemberLimit();
        }
      };

      Column({ space: 16 }) {
        Column() {
          GuitarTunerTrajectory({
            currentFreq: this.vm.currentFreq,
            targetFreq: this.vm.currenNoteIndex === -1 ? 0 : this.vm.guitarStandard[this.vm.currenNoteIndex].freq,
          });
        }.width('100%').height(312);

        Text(this.vm.currentShowFreq === 0 ? '请拨动琴弦' : this.vm.tips)
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_on_primary'));

        Stack({ alignContent: Alignment.Center }) {
          Grid() {
            ForEach(this.vm.guitarStandard, (item: GuitarInfo, index) => {
              GridItem() {
                Column() {
                  Image(this.vm.currenNoteIndex === index ? item.activeIcon : item.icon)
                    .width(48)
                    .onClick(async () => {
                      if (!this.loginManageUtil.userInfoModel.isLogin) {
                        LoginSheetUtils.open(this.loginManageUtil.params, this.getUIContext());
                      } else {
                        if (!this.isCanUse) {
                          this.vm.showMemberSubscribeDialog(this.getUIContext());
                        } else {
                          // 检查麦克风权限
                          await this.vm.handlePermission(this.getUIContext().getHostContext() as Context);
                          this.vm.currenNoteIndex = index;
                          if (!this.vm.isCapturing) {
                            await this.vm.startCapture(this.getUIContext());
                          }
                          // 播放示例弦音
                          this.vm.playAudio(this.vm.soundMap.get(item.filePath));
                        }
                      }
                    });
                }.width('100%').alignItems(index % 2 === 0 ? HorizontalAlign.Start : HorizontalAlign.End);
              };
            }, (item: GuitarInfo) => item.note);
          }.columnsTemplate('1fr 1fr')
          .rowsGap(16)
          .height(176);

          Image($r('app.media.guitar_tuner')).width('calc(100% - 136vp)').objectFit(ImageFit.Contain);

        }.layoutWeight(1);
      }.layoutWeight(1).padding({ left: 16, right: 16 });
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Black)
    .systemBarStyle({ statusBarContentColor: '#FFFFFF' })
    .onReady(async (cxt) => {
      setPathStack(cxt.pathStack);
      await this.vm.handlePermission(this.getUIContext().getHostContext() as Context);
      await this.vm.startCapture(this.getUIContext());
      this.vm.initSoundPool(this.getUIContext());
    });
  }
}


