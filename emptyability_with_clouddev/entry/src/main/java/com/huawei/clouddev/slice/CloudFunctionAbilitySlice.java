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

package com.huawei.clouddev.slice;

import com.huawei.agconnect.function.AGCFunctionException;
import com.huawei.agconnect.function.AGConnectFunction;
import com.huawei.agconnect.function.FunctionResult;
import com.huawei.clouddev.ResourceTable;
import com.huawei.hmf.tasks.HarmonyTask;
import com.huawei.hmf.tasks.OnHarmonyCompleteListener;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.components.Text;
import ohos.hiviewdfx.HiLog;
import ohos.hiviewdfx.HiLogLabel;
import ohos.utils.zson.ZSONObject;

public class CloudFunctionAbilitySlice extends AbilitySlice {
    private static final HiLogLabel LABEL = new HiLogLabel(HiLog.LOG_APP, 0, "Function");
    private AGConnectFunction function;

    private Text uuidOutput;
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_ability_cloud_function);
        initComponents();
    }

    private void initComponents() {
        findComponentById(ResourceTable.Id_generate_id).setClickedListener(component -> {
            getResult();
        });
    }

    private void getResult() {
        function = AGConnectFunction.getInstance();
        function.wrap("idgenerator-$latest").call()
                .addOnCompleteListener(new OnHarmonyCompleteListener<FunctionResult>() {
                    @Override
                    public void onComplete(HarmonyTask<FunctionResult> task) {
                        if (task.isSuccessful()) {
                            ZSONObject uuid = ZSONObject.stringToZSON(task.getResult().getValue());
                            if (uuid != null) {
                                uuidOutput = (Text) findComponentById(ResourceTable.Id_uuid);
                                uuidOutput.setText(uuid.getString("uuid"));
                            }
                        } else {
                            Exception e = task.getException();
                            if (e instanceof AGCFunctionException) {
                                AGCFunctionException functionException = (AGCFunctionException) e;
                                int errCode = functionException.getCode();
                                String message = functionException.getMessage();
                            }
                            HiLog.error(LABEL, "Get uuid error!");
                            uuidOutput = (Text) findComponentById(ResourceTable.Id_uuid);
                            uuidOutput.setText("Get uuid error!");
                        }
                    }
                });
    }
}
