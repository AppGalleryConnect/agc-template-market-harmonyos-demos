/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { ComponentContent, promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';
import { AppStorageMap } from './Constant';

export enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<object>;
  popType: PopViewShowType;
}

export class PopViewUtils {
  private static popShare: PopViewUtils;
  private infoList: PopViewModel[] = [];

  static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  static showDialog<T extends object>(type: PopViewShowType, contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    let uiContext = AppStorage.get<UIContext>(AppStorageMap.UI_CONTEXT);
    if (uiContext) {
      // The promptAction object was obtained.
      let prompt = uiContext.getPromptAction();
      let componentContent = new ComponentContent(uiContext, contentView, args);
      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment || DialogAlignment.Bottom,
        autoCancel: options?.autoCancel || false,
        onWillDismiss: (v: DismissDialogAction) => {
          Logger.debug('dismiss reason:' + v.reason)
          if (options?.autoCancel) {
            v.dismiss();
          }
        },
      };
      // Open pop-ups using openCustomDialog
      prompt.openCustomDialog(componentContent, customOptions);
      let infoList = PopViewUtils.shareInstance().infoList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      infoList[0] = info;
    }
  }

  static closeDialog(type: PopViewShowType): void {
    let uiContext = AppStorage.get<UIContext>(AppStorageMap.UI_CONTEXT);
    if (uiContext) {
      // The promptAction object was obtained.
      let prompt = uiContext.getPromptAction();
      let sameTypeList = PopViewUtils.shareInstance().infoList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().infoList = PopViewUtils.shareInstance().infoList.filter((model) => {
          return model.com !== info.com;
        })
        // Close pop-ups using closeCustomDialog.
        prompt.closeCustomDialog(info.com);
      }
    }
  }

  static showPopView<T extends object>(contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    PopViewUtils.showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  static closePopView(): void {
    PopViewUtils.closeDialog(PopViewShowType.OPEN);
  }
}
