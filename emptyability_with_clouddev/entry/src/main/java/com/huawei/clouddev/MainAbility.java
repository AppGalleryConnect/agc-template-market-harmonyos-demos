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

package com.huawei.clouddev;

import com.huawei.agconnect.AGConnectInstance;
import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.clouddev.slice.MainAbilitySlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;
import ohos.global.resource.RawFileEntry;
import ohos.global.resource.Resource;
import ohos.global.resource.ResourceManager;

public class MainAbility extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(MainAbilitySlice.class.getName());
        initComponents(intent);
    }

    private void initComponents(Intent intent) {
        try {
            AGConnectOptionsBuilder builder = new AGConnectOptionsBuilder();
            ResourceManager resourceManager = getResourceManager();
            // agconnect-services.json 文件路径
            RawFileEntry rawFileEntry = resourceManager.getRawFileEntry("resources/rawfile/agconnect-services.json");
            Resource resource = rawFileEntry.openRawFile();
            builder.setInputStream(resource);
            // 如果您的json文件中不存在client_id、client_secret和api_key参数，需通过以下接口设置
            AGConnectInstance.initialize(getAbilityPackage(), builder);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
