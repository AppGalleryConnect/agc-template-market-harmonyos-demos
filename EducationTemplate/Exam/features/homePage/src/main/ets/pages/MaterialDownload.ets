/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BreakpointType, GlobalContextUtils, RouterMap, RouterModule, TopTabsBuilder } from 'commonlib';
import { CourseBookComponent } from '../components/CourseBookComponent';
import { CourseBook } from '../model/CourseBook';
import { HomeVM } from '../viewmodels/HomeVM';
import { AppStorageV2 } from '@kit.ArkUI';
import { DownloadInfo, SubjectExercises, Material } from '../model/MaterialModel';


@ComponentV2
export struct MaterialDownload {
  @Param courseBookArray: CourseBook[] = [new CourseBook('一级建造师精华题库', '三色速记手册', 423, 'pdf', 23),
    new CourseBook('二级建造师精华题库', '三色速记手册', 423, 'pdf', 23)];
  @Local materials: Material[] = [];
  @Local downloading: boolean = false;
  @Local subjectObj?: SubjectExercises;
  @Local isDownload: boolean = false;
  @Local downloadInfo: DownloadInfo = AppStorageV2.connect(DownloadInfo, () => new DownloadInfo())!;
  @Local downloadData: string[] = [];

  homeVM: HomeVM = HomeVM.instance;

  initMaterials() {
    this.subjectObj = RouterModule.getNavParam({ url: RouterMap.MATERIAL_DOWNLOAD_PAGE }) as SubjectExercises;
    this.courseBookArray.forEach((value: CourseBook) => {
      this.materials.push(new Material(value, false));
    });
    this.materials.forEach((val: Material) => {
      val.courseBook.type = this.subjectObj?.type ?? 'pdf';
      val.courseBook.bookName = this.subjectObj?.name ?? '一级建造师精华题库';
      if(this.downloadInfo.downloadMaterials.includes(val.courseBook.bookName)) {
        this.isDownload = true;
      }
    })
  }

  aboutToAppear(): void {
    this.initMaterials();
  }

  build() {
    Column() {
      TopTabsBuilder({ title: '资料下载', bgColor: $r('sys.color.background_secondary'), showBackButton: true })
        .margin({ bottom: '8vp' })
        .padding({ left: 16, right: 16 });
      // 待下载的资料列表
      this.courseListBuilder();
      // 下载按钮
      this.downloadButtonBuilder();
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  // 下载按钮
  @Builder
  downloadButtonBuilder() {
    Row() {
      Image($r('app.media.ic_public_download'))
        .height('24vp')
        .width('24vp')
        .margin({ right: 8 });
      Text(this.isDownload ? '已下载' : this.downloading ? '正在下载' : '下载')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'));
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.vp_40'))
    .width(new BreakpointType<number>({
      sm: 312,
      md: 448,
      lg: 448,
      xl: 448
    }).getValue(this.homeVM.breakPointModel.currentBreakpoint))
    .backgroundColor('#4c5dc4')
    .borderRadius($r('app.float.vp_20'))
    .opacity(this.downloadData.length && !this.isDownload ? 1 : 0.6)
    .onClick(() => {
      if(this.isDownload) {
        return;
      }
      // 表示处理下载逻辑
      if (this.downloadData.length !== 0 && !this.downloading) {
        this.downloading = true;
        let timer = setInterval(() => {
          GlobalContextUtils.showToast({ message: '下载完成' });
          if(!this.downloadInfo.downloadMaterials.includes(this.downloadData[0])) {
            this.downloadInfo.downloadMaterials.push(this.downloadData[0]);
          }
          this.downloading = false;
          this.isDownload = true;
          clearInterval(timer);
        }, 3000);
      }
    });
  }

  // 待下载的资料列表
  @Builder
  courseListBuilder() {
    Column() {
      Scroll() {
        List() {
          ForEach(this.materials, (item: Material) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    CourseBookComponent({ courseBook: item.courseBook, pageType: 'MaterialDownload' })
                      .margin({ bottom: '5vp' });
                  };

                  Checkbox({ name: item.courseBook.bookName, group: 'MaterialGroup' })
                    .select(item.isSelected)
                    .selectedColor('#4B5CC4')
                    .shape(CheckBoxShape.CIRCLE)
                    .onChange((value: boolean) => {
                      if(this.isDownload) {
                        return;
                      }
                      if (value) {
                        this.downloadData.push(item.courseBook.bookName)
                      } else {
                        this.downloadData = [];
                      }
                    });
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween);

                Divider()
                  .width('100%');
              }
              .padding({ left: 28, right: 28 })
              .width('100%');
            };
          }, (item: CourseBook, index: number) => item.bookName + index);
        }
        .height('100%')
        .width('100%')
        .alignListItem(ListItemAlign.Center);
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring);
    }
    .padding({ top: '17vp' })
    .layoutWeight(1)
    .width('100%');
  }
}

@Builder
export function MaterialDownloadBuilder() {
  MaterialDownload();
}

