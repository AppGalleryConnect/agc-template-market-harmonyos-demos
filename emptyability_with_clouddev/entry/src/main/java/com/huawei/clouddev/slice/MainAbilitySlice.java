package com.huawei.clouddev.slice;

import com.huawei.clouddev.ResourceTable;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;

public class MainAbilitySlice extends AbilitySlice {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_ability_main);
        initComponents();
    }

    private void initComponents() {
        findComponentById(ResourceTable.Id_botton_auth_service).setClickedListener(listener -> present(new AuthAbilitySlice(), new Intent()));
        findComponentById(ResourceTable.Id_botton_cloud_function).setClickedListener(listener -> present(new CloudFunctionAbilitySlice(), new Intent()));
    }

    @Override
    public void onActive() {
        super.onActive();
    }

    @Override
    public void onForeground(Intent intent) {
        super.onForeground(intent);
    }
}
