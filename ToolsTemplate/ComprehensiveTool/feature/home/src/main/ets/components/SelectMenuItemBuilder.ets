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

export class MenuItemContentModifier implements ContentModifier<MenuItemConfiguration> {
  applyContent(): WrappedBuilder<[MenuItemConfiguration]> {
    return wrapBuilder(SelectMenuItemBuilder);
  }
}

@Builder
export function SelectMenuItemBuilder(configuration: MenuItemConfiguration) {
  Row() {
    Text(configuration.value).fontWeight(500);

    if (configuration.selected) {
      Image(configuration.icon).size({ width: 24, height: 24 })
    }
  }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(12).onClick(() => {
    configuration.triggerSelect(configuration.index, configuration.value.valueOf().toString());
  });
}