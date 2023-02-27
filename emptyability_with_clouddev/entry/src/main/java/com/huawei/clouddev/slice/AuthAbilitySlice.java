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

import com.huawei.agconnect.auth.*;
import com.huawei.clouddev.ResourceTable;
import com.huawei.hmf.tasks.HarmonyTask;
import com.huawei.hmf.tasks.OnFailureListener;
import com.huawei.hmf.tasks.OnSuccessListener;
import com.huawei.hmf.tasks.TaskExecutors;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.components.Button;
import ohos.agp.components.Component;
import ohos.agp.components.Text;
import ohos.agp.components.TextField;
import ohos.agp.utils.Color;
import ohos.hiviewdfx.HiLog;
import ohos.hiviewdfx.HiLogLabel;

import java.util.Locale;
public class AuthAbilitySlice extends AbilitySlice {
    private static final HiLogLabel LABEL = new HiLogLabel(HiLog.LOG_APP, 0, "AUTH");
    private Text titleText;
    private TextField countryCode;
    private TextField phoneNumber;
    private TextField verifyCode;
    private Button verifyButton;
    private Button dialogLogin;

    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_dialog_login);
        initComponents(intent);
    }

    private void initComponents(Intent intent) {
        titleText = (Text) findComponentById(ResourceTable.Id_title_text);
        countryCode = (TextField) findComponentById(ResourceTable.Id_country_code);
        phoneNumber = (TextField) findComponentById(ResourceTable.Id_phone_number);
        phoneNumber.setFocusChangedListener(new Component.FocusChangedListener() {
            @Override
            public void onFocusChange(Component component, boolean isFocus) {
                if(isFocus){
                    verifyButton.setHintColor(Color.BLACK);
                }else{
                    verifyButton.setHintColor(Color.WHITE);
                }
            }
        });
        verifyCode = (TextField) findComponentById(ResourceTable.Id_verify_code);
        verifyCode.setFocusChangedListener(new Component.FocusChangedListener() {
            @Override
            public void onFocusChange(Component component, boolean isFocus) {
                if(isFocus){
                    dialogLogin.setHintColor(Color.BLACK);
                }else{
                    dialogLogin.setHintColor(Color.WHITE);
                }
            }
        });
        verifyButton = (Button) findComponentById(ResourceTable.Id_get_verify_code);
        verifyButton.setClickedListener(component -> requestPhoneVerifyCode());

        dialogLogin = (Button) findComponentById(ResourceTable.Id_dialog_login);
        dialogLogin.setClickedListener(component -> login(intent));
    }

    private void requestPhoneVerifyCode() {
        HiLog.error(LABEL, "requestPhoneVerifyCode");
        VerifyCodeSettings settings = new VerifyCodeSettings.Builder()
                .action(VerifyCodeSettings.ACTION_REGISTER_LOGIN)
                .sendInterval(30)
                .locale(Locale.CHINA)
                .build();
        HarmonyTask<VerifyCodeResult> task =
                AGConnectAuth.getInstance().requestVerifyCode(countryCode.getText(), phoneNumber.getText(), settings);
        task.addOnSuccessListener(TaskExecutors.uiThread(), new OnSuccessListener<VerifyCodeResult>() {
            @Override
            public void onSuccess(VerifyCodeResult verifyCodeResult) {
                // 验证码申请成功
                HiLog.error(LABEL, "Get verify code success!");

            }
        }).addOnFailureListener(TaskExecutors.uiThread(), new OnFailureListener() {
            @Override
            public void onFailure(Exception e) {
                HiLog.error(LABEL, "Get verify code failed!");
            }
        });
    }

    private void login(Intent intent) {
        AGConnectAuthCredential credential =
                PhoneAuthProvider.credentialWithVerifyCode(countryCode.getText(), phoneNumber.getText(), null, verifyCode.getText());
        AGConnectAuth.getInstance().signIn(credential)
                .addOnSuccessListener(new OnSuccessListener<SignInResult>() {
                    @Override
                    public void onSuccess(SignInResult signInResult) {
                        // 获取登录信息
                        HiLog.error(LABEL, "Login success!");
                        present(new UserInfoSlice(), intent);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        HiLog.error(LABEL, "Login failed!");
                    }
                });
    }
}
