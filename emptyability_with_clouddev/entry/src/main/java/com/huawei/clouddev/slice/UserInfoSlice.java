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

import com.huawei.agconnect.auth.AGConnectAuth;
import com.huawei.agconnect.auth.AGConnectUser;
import com.huawei.agconnect.auth.AGConnectUserExtra;
import com.huawei.clouddev.ResourceTable;
import com.huawei.hmf.tasks.HarmonyTask;
import com.huawei.hmf.tasks.OnSuccessListener;
import com.huawei.hmf.tasks.TaskExecutors;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.components.Button;
import ohos.agp.components.Image;
import ohos.agp.components.Text;
import ohos.hiviewdfx.HiLog;
import ohos.hiviewdfx.HiLogLabel;

import java.text.SimpleDateFormat;
import java.util.Date;

public class UserInfoSlice extends AbilitySlice {
    private static final HiLogLabel LABEL = new HiLogLabel(HiLog.LOG_APP, 0, "Function");

    private Image userPhoto;
    private Text phoneNumber;
    private Text lastLogin;
    private Text registerTime;
    private Button deleteUser;
    private Button logout;

    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_login_user_info);
        initComponents(intent);
    }

    private void initComponents(Intent intent) {
        AGConnectUser user = AGConnectAuth.getInstance().getCurrentUser();
        // photo
        userPhoto = (Image) findComponentById(ResourceTable.Id_user_image);

        // phone
        phoneNumber = (Text) findComponentById(ResourceTable.Id_phone_number);
        phoneNumber.setText(user.getPhone());

        // register time and login time
        registerTime = (Text)  findComponentById(ResourceTable.Id_register_time);
        lastLogin = (Text) findComponentById(ResourceTable.Id_last_login_time);
        HarmonyTask<AGConnectUserExtra> task = AGConnectAuth.getInstance().getCurrentUser().getUserExtra();
        task.addOnSuccessListener(TaskExecutors.uiThread(),new OnSuccessListener<AGConnectUserExtra>() {
            @Override
            public void onSuccess(AGConnectUserExtra userExtra) {
                SimpleDateFormat date = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                registerTime.setText(date.format(new Date(Long.parseLong(userExtra.getCreateTime()))));
                lastLogin.setText(date.format(new Date(Long.parseLong(userExtra.getLastSignInTime()))));
            }
        });
        // delete user
        deleteUser = (Button) findComponentById(ResourceTable.Id_delete_user);
        deleteUser.setClickedListener(component ->deleteUser());

        // logout
        logout = (Button) findComponentById(ResourceTable.Id_log_out);
        logout.setClickedListener(component -> logout(intent));
    }

    private void deleteUser() {
        AGConnectAuth.getInstance().deleteUser();
    }

    private void logout(Intent intent) {
        AGConnectAuth.getInstance().signOut();
        present(new MainAbilitySlice(),intent);
    }
}
